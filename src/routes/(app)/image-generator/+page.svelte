<script lang="ts">
	import { getContext, onMount } from 'svelte';
	import { WEBUI_API_BASE_URL } from '$lib/constants';
	import { toast } from 'svelte-sonner';

	const i18n = getContext('i18n');

	type GeneratedImage = {
		url: string;
		prompt: string;
	};

	let prompt = '';
	let negativePrompt = '';
	let size = '512x512';
	let steps = 20;
	let n = 1;
	let loading = false;
	let images: GeneratedImage[] = [];
	let showAdvanced = false;
	let textareaRef: HTMLTextAreaElement;

	const sizes = ['512x512', '768x768', '1024x1024', '512x768', '768x512'];

	async function generate() {
		if (!prompt.trim() || loading) return;

		loading = true;
		const currentPrompt = prompt.trim();

		try {
			const res = await fetch(`${WEBUI_API_BASE_URL}/images/generations`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					Authorization: `Bearer ${localStorage.token}`
				},
				body: JSON.stringify({
					prompt: currentPrompt,
					negative_prompt: negativePrompt.trim() || undefined,
					size,
					steps,
					n
				})
			});

			if (!res.ok) {
				const err = await res.json().catch(() => ({}));
				throw new Error(err?.detail || `Error ${res.status}`);
			}

			const data = await res.json();

			// API returns [{ url: "..." }, ...] directly as an array
			const list = Array.isArray(data) ? data : (data?.data ?? []);
			const newImages: GeneratedImage[] = list.map((img: { url: string }) => ({
				url: img.url,
				prompt: currentPrompt
			}));

			images = [...newImages, ...images];
		} catch (e: any) {
			toast.error(e?.message ?? 'Image generation failed');
		} finally {
			loading = false;
		}
	}

	function handleKeydown(e: KeyboardEvent) {
		if (e.key === 'Enter' && !e.shiftKey) {
			e.preventDefault();
			generate();
		}
	}

	function downloadImage(url: string, index: number) {
		const a = document.createElement('a');
		a.href = url;
		a.download = `generated-${index + 1}.png`;
		a.click();
	}

	onMount(() => {
		textareaRef?.focus();
	});
</script>

<div class="flex flex-col h-screen w-full bg-white dark:bg-gray-900 text-gray-800 dark:text-gray-200">

	<!-- Header -->
	<div class="flex items-center px-4 py-3 border-b border-gray-100 dark:border-gray-800 shrink-0">
		<div class="flex items-center gap-2">
			<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 text-purple-500">
				<path stroke-linecap="round" stroke-linejoin="round" d="m2.25 15.75 5.159-5.159a2.25 2.25 0 0 1 3.182 0l5.159 5.159m-1.5-1.5 1.409-1.409a2.25 2.25 0 0 1 3.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 0 0 1.5-1.5V6a1.5 1.5 0 0 0-1.5-1.5H3.75A1.5 1.5 0 0 0 2.25 6v12a1.5 1.5 0 0 0 1.5 1.5Zm10.5-11.25h.008v.008h-.008V8.25Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z" />
			</svg>
			<span class="font-semibold text-sm">{$i18n.t('Image Generator')}</span>
		</div>
	</div>

	<!-- Images area -->
	<div class="flex-1 overflow-y-auto px-4 py-6">
		{#if images.length === 0 && !loading}
			<div class="flex flex-col items-center justify-center h-full gap-3 text-gray-400 dark:text-gray-600">
				<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1" stroke="currentColor" class="size-16">
					<path stroke-linecap="round" stroke-linejoin="round" d="m2.25 15.75 5.159-5.159a2.25 2.25 0 0 1 3.182 0l5.159 5.159m-1.5-1.5 1.409-1.409a2.25 2.25 0 0 1 3.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 0 0 1.5-1.5V6a1.5 1.5 0 0 0-1.5-1.5H3.75A1.5 1.5 0 0 0 2.25 6v12a1.5 1.5 0 0 0 1.5 1.5Zm10.5-11.25h.008v.008h-.008V8.25Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z" />
				</svg>
				<p class="text-sm">{$i18n.t('Enter a prompt below to generate an image')}</p>
			</div>
		{/if}

		{#if loading}
			<div class="flex flex-col items-center justify-center py-16 gap-4">
				<div class="relative size-16">
					<div class="absolute inset-0 rounded-full border-4 border-purple-200 dark:border-purple-900"></div>
					<div class="absolute inset-0 rounded-full border-4 border-transparent border-t-purple-500 animate-spin"></div>
				</div>
				<p class="text-sm text-gray-500 dark:text-gray-400">{$i18n.t('Generating image...')}</p>
			</div>
		{/if}

		{#if images.length > 0}
			<div class="max-w-3xl mx-auto space-y-6">
				{#each images as img, i}
					<div class="rounded-2xl overflow-hidden border border-gray-100 dark:border-gray-800 bg-gray-50 dark:bg-gray-850">
						<img
							src={img.url}
							alt={img.prompt}
							class="w-full object-contain max-h-[70vh]"
						/>
						<div class="px-4 py-3 flex items-start justify-between gap-3">
							<p class="text-xs text-gray-500 dark:text-gray-400 flex-1 leading-relaxed">{img.prompt}</p>
							<button
								on:click={() => downloadImage(img.url, i)}
								class="shrink-0 p-1.5 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition"
								title={$i18n.t('Download')}
							>
								<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
									<path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3" />
								</svg>
							</button>
						</div>
					</div>
				{/each}
			</div>
		{/if}
	</div>

	<!-- Input area -->
	<div class="shrink-0 border-t border-gray-100 dark:border-gray-800 px-4 py-4">
		<div class="max-w-3xl mx-auto">

			<!-- Advanced toggle -->
			<div class="mb-2 flex items-center justify-between">
				<button
					on:click={() => (showAdvanced = !showAdvanced)}
					class="text-xs text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 flex items-center gap-1 transition"
				>
					<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5 transition-transform {showAdvanced ? 'rotate-180' : ''}">
						<path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
					</svg>
					{$i18n.t('Advanced options')}
				</button>
			</div>

			<!-- Advanced options -->
			{#if showAdvanced}
				<div class="mb-3 grid grid-cols-2 sm:grid-cols-3 gap-2 p-3 rounded-xl bg-gray-50 dark:bg-gray-850 border border-gray-100 dark:border-gray-800">
					<div class="flex flex-col gap-1">
						<label class="text-xs text-gray-500">{$i18n.t('Size')}</label>
						<select
							bind:value={size}
							class="text-xs bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-lg px-2 py-1.5 outline-none"
						>
							{#each sizes as s}
								<option value={s}>{s}</option>
							{/each}
						</select>
					</div>

					<div class="flex flex-col gap-1">
						<label class="text-xs text-gray-500">{$i18n.t('Steps')}</label>
						<input
							type="number"
							bind:value={steps}
							min="1"
							max="150"
							class="text-xs bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-lg px-2 py-1.5 outline-none"
						/>
					</div>

					<div class="flex flex-col gap-1">
						<label class="text-xs text-gray-500">{$i18n.t('Count')}</label>
						<input
							type="number"
							bind:value={n}
							min="1"
							max="4"
							class="text-xs bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-lg px-2 py-1.5 outline-none"
						/>
					</div>

					<div class="col-span-2 sm:col-span-3 flex flex-col gap-1">
						<label class="text-xs text-gray-500">{$i18n.t('Negative prompt')}</label>
						<input
							type="text"
							bind:value={negativePrompt}
							placeholder={$i18n.t('What to avoid in the image...')}
							class="text-xs bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-lg px-2 py-1.5 outline-none"
						/>
					</div>
				</div>
			{/if}

			<!-- Prompt input -->
			<div class="flex items-end gap-2 rounded-2xl border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-850 px-4 py-3 focus-within:border-purple-400 dark:focus-within:border-purple-600 transition">
				<textarea
					bind:this={textareaRef}
					bind:value={prompt}
					on:keydown={handleKeydown}
					placeholder={$i18n.t('Describe the image you want to generate...')}
					rows="1"
					class="flex-1 resize-none bg-transparent outline-none text-sm leading-relaxed placeholder-gray-400 dark:placeholder-gray-600 max-h-40 overflow-y-auto"
					style="field-sizing: content;"
					disabled={loading}
				></textarea>

				<button
					on:click={generate}
					disabled={!prompt.trim() || loading}
					class="shrink-0 p-2 rounded-xl bg-purple-500 hover:bg-purple-600 disabled:opacity-40 disabled:cursor-not-allowed text-white transition"
					aria-label={$i18n.t('Generate')}
				>
					{#if loading}
						<svg class="size-4 animate-spin" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
							<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
							<path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
						</svg>
					{:else}
						<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4">
							<path stroke-linecap="round" stroke-linejoin="round" d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5" />
						</svg>
					{/if}
				</button>
			</div>

			<p class="mt-2 text-center text-xs text-gray-400 dark:text-gray-600">
				{$i18n.t('Press Enter to generate · Shift+Enter for new line')}
			</p>
		</div>
	</div>
</div>
