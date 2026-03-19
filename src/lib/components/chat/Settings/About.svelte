<script lang="ts">
	import { getOllamaVersion } from '$lib/apis/ollama';
	import { WEBUI_BUILD_HASH } from '$lib/constants';
	import { WEBUI_NAME, showChangelog } from '$lib/stores';
	import { onMount, getContext } from 'svelte';

	import Tooltip from '$lib/components/common/Tooltip.svelte';

	const i18n = getContext('i18n');

	let ollamaVersion = '';

	onMount(async () => {
		ollamaVersion = await getOllamaVersion(localStorage.token).catch(() => '');
	});
</script>

<div id="tab-about" class="flex flex-col h-full justify-between space-y-3 text-sm mb-6">
	<div class="space-y-3 overflow-y-scroll max-h-[28rem] md:max-h-full">
		<div>
			<div class="mb-2.5 text-sm font-medium flex space-x-2 items-center">
				<div>
					{$WEBUI_NAME} {$i18n.t('Version')}
				</div>
			</div>

			<div class="flex w-full justify-between items-center">
				<div class="flex flex-col text-xs text-gray-700 dark:text-gray-200">
					<div class="flex gap-1">
						<Tooltip content={WEBUI_BUILD_HASH}>
							v0.1.0
						</Tooltip>
						<span>{$i18n.t('(latest)')}</span>
					</div>

					<button
						class="underline flex items-center space-x-1 text-xs text-gray-500 dark:text-gray-500"
						on:click={() => showChangelog.set(true)}
					>
						<div>{$i18n.t("See what's new")}</div>
					</button>
				</div>
			</div>
		</div>

		{#if ollamaVersion}
			<hr class="border-gray-100/30 dark:border-gray-850/30" />
			<div>
				<div class="mb-2.5 text-sm font-medium">{$i18n.t('Ollama Version')}</div>
				<div class="flex w-full">
					<div class="flex-1 text-xs text-gray-700 dark:text-gray-200">
						{ollamaVersion ?? 'N/A'}
					</div>
				</div>
			</div>
		{/if}

		<hr class="border-gray-100/30 dark:border-gray-850/30" />

		<div class="mt-2 text-xs text-gray-400 dark:text-gray-500">
			<strong>MIRMI-LLM</strong><br>
			Created by MIRMI IT Team<br>
			<a href="https://mirmi.tum.de" target="_blank" class="underline">mirmi.tum.de</a>
		</div>

		<div>
			<pre class="text-xs text-gray-400 dark:text-gray-500">
Copyright (c) {new Date().getFullYear()} MIRMI IT Team. All rights reserved.
			</pre>
		</div>

		<div class="mt-2">
			<a
				href="https://github.com/peymankhp/MIRMI-LLM"
				target="_blank"
				class="inline-flex items-center gap-2 px-3 py-1.5 bg-gray-100 hover:bg-gray-200 dark:bg-gray-800 dark:hover:bg-gray-700 rounded-lg transition text-xs font-medium text-gray-800 dark:text-gray-200"
			>
				<svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
					<path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v 3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
				</svg>
				GitHub
			</a>
		</div>
	</div>
</div>
