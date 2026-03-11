<script lang="ts">
	import { onMount } from 'svelte';
	import { WEBUI_API_BASE_URL } from '$lib/constants';
	
	let iframeUrl = '';
	let loading = true;
	let error = null;
	let message = 'Initializing IDE...';
	
	onMount(async () => {
		try {
			message = 'Creating IDE session...';
			
			// Request IDE session from backend
			const response = await fetch(`${WEBUI_API_BASE_URL}/api/v1/ide/session`, {
				method: 'POST',
				headers: { 
					'Content-Type': 'application/json',
					'Authorization': `Bearer ${localStorage.getItem('token')}`
				},
				credentials: 'include'
			});
			
			if (!response.ok) {
				const errorData = await response.json().catch(() => ({}));
				throw new Error(errorData.detail || `HTTP ${response.status}: Failed to create IDE session`);
			}
			
			const data = await response.json();
			iframeUrl = data.url;
			message = 'IDE ready!';
			
			// Small delay to show the success message
			setTimeout(() => {
				loading = false;
			}, 1000);
			
		} catch (e) {
			console.error('IDE initialization error:', e);
			error = e.message;
			loading = false;
		}
	});
</script>

<div class="h-screen w-full flex flex-col bg-white dark:bg-gray-900">
	{#if loading}
		<div class="flex items-center justify-center h-full">
			<div class="text-center">
				<div class="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 dark:border-white mx-auto"></div>
				<p class="mt-4 text-gray-700 dark:text-gray-300">{message}</p>
			</div>
		</div>
	{:else if error}
		<div class="flex items-center justify-center h-full">
			<div class="text-center max-w-md mx-auto p-6">
				<svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto mb-4 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
				</svg>
				<p class="font-semibold text-red-600 dark:text-red-400">IDE Initialization Failed</p>
				<p class="mt-2 text-sm text-gray-600 dark:text-gray-400">{error}</p>
				<button 
					class="mt-4 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
					on:click={() => window.location.reload()}
				>
					Retry
				</button>
			</div>
		</div>
	{:else}
		<iframe 
			src={iframeUrl} 
			class="w-full h-full border-0"
			title="Agentic IDE"
			sandbox="allow-same-origin allow-scripts allow-forms allow-downloads allow-modals allow-popups"
		/>
	{/if}
</div>
