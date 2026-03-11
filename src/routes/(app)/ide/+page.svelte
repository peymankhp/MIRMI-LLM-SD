<script lang="ts">
	import { onMount } from 'svelte';
	import { WEBUI_API_BASE_URL } from '$lib/constants';
	
	let iframeUrl = '';
	let loading = true;
	let error = null;
	let message = 'Initializing IDE...';
	let isHuggingFaceDeployment = false;
	
	onMount(async () => {
		try {
			// Check if we're running on HuggingFace Spaces
			if (window.location.hostname.includes('huggingface.co') || window.location.hostname.includes('hf.space')) {
				isHuggingFaceDeployment = true;
				loading = false;
				return;
			}
			
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
	{#if isHuggingFaceDeployment}
		<div class="flex items-center justify-center h-full">
			<div class="text-center max-w-md mx-auto p-6">
				<svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 mx-auto mb-4 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
				</svg>
				<h2 class="text-2xl font-bold text-gray-800 dark:text-gray-200 mb-4">Agentic IDE</h2>
				<p class="text-gray-600 dark:text-gray-400 mb-6">
					The Agentic IDE is a powerful development environment with AI-powered coding assistance.
				</p>
				<div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4 mb-6">
					<p class="text-blue-800 dark:text-blue-200 text-sm">
						<strong>Coming Soon:</strong> The full IDE experience is currently available in self-hosted deployments. 
						We're working on bringing this feature to the hosted version.
					</p>
				</div>
				<div class="text-left space-y-3 text-sm text-gray-600 dark:text-gray-400">
					<h3 class="font-semibold text-gray-800 dark:text-gray-200">Features include:</h3>
					<ul class="space-y-2">
						<li class="flex items-center">
							<svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
								<path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
							</svg>
							Full VS Code environment in browser
						</li>
						<li class="flex items-center">
							<svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
								<path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
							</svg>
							AI-powered code generation and assistance
						</li>
						<li class="flex items-center">
							<svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
								<path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
							</svg>
							Integrated terminal and debugging
						</li>
						<li class="flex items-center">
							<svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
								<path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
							</svg>
							Seamless integration with chat interface
						</li>
					</ul>
				</div>
			</div>
		</div>
	{:else if loading}
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
