<script lang="ts">
	import { onMount } from 'svelte';

	let isHuggingFaceDeployment = false;

	onMount(async () => {
		// Check if we're running on HuggingFace Spaces
		if (
			window.location.hostname.includes('huggingface.co') ||
			window.location.hostname.includes('hf.space')
		) {
			isHuggingFaceDeployment = true;
		}
	});
</script>

<div class="h-screen w-full flex flex-col bg-white dark:bg-gray-900">
	<div class="flex items-center justify-center h-full">
		<div class="text-center max-w-md mx-auto p-6">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				class="h-16 w-16 mx-auto mb-4 text-blue-500"
				fill="none"
				viewBox="0 0 24 24"
				stroke="currentColor"
			>
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"
				/>
			</svg>
			<h2 class="text-2xl font-bold text-gray-800 dark:text-gray-200 mb-4">Agentic IDE</h2>
			<p class="text-gray-600 dark:text-gray-400 mb-6">
				The Agentic IDE is a powerful development environment with AI-powered coding assistance.
			</p>
			<div
				class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4 mb-6"
			>
				<p class="text-blue-800 dark:text-blue-200 text-sm">
					<strong>Coming Soon:</strong> The full IDE experience is currently in development. We're working
					on bringing this feature to you soon!
				</p>
			</div>
			<div class="text-left space-y-3 text-sm text-gray-600 dark:text-gray-400">
				<h3 class="font-semibold text-gray-800 dark:text-gray-200">Features coming soon:</h3>
				<ul class="space-y-2">
					<li class="flex items-center">
						<svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
							<path
								fill-rule="evenodd"
								d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
								clip-rule="evenodd"
							></path>
						</svg>
						AI-powered code generation and assistance
					</li>
					<li class="flex items-center">
						<svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
							<path
								fill-rule="evenodd"
								d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
								clip-rule="evenodd"
							></path>
						</svg>
						Code completion and bug fixing
					</li>
					<li class="flex items-center">
						<svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
							<path
								fill-rule="evenodd"
								d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
								clip-rule="evenodd"
							></path>
						</svg>
						Integrated development workspace
					</li>
					<li class="flex items-center">
						<svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
							<path
								fill-rule="evenodd"
								d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
								clip-rule="evenodd"
							></path>
						</svg>
						Seamless integration with chat interface
					</li>
				</ul>
			</div>
		</div>
	</div>
</div>
