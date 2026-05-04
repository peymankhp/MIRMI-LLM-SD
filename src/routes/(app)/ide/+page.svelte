<script lang="ts">
	import { onMount } from 'svelte';
	import { getContext } from 'svelte';

	const i18n = getContext('i18n');

	const configJson = `{
  "name": "Complete Ubuntu Ollama Setup",
  "version": "0.0.1",
  "schema": "v1",
  "models": [
    {
      "name": "Llama 3 70B (Best Quality - Slower)",
      "provider": "ollama",
      "model": "llama3:70b",
      "apiBase": "http://10.157.174.177:11434",
      "roles": ["chat", "edit"],
      "contextLength": 8192
    },
    {
      "name": "Qwen 2.5 14B (High Quality)",
      "provider": "ollama",
      "model": "qwen2.5:14b",
      "apiBase": "http://10.157.174.177:11434",
      "roles": ["chat", "edit"],
      "contextLength": 131072
    },
    {
      "name": "Llama 3.1 8B (Best Balance)",
      "provider": "ollama",
      "model": "llama3.1:8b-instruct-q4_K_M",
      "apiBase": "http://10.157.174.177:11434",
      "roles": ["chat", "edit"],
      "contextLength": 131072
    },
    {
      "name": "Qwen 2.5 Coder 7B (Specialized for Code)",
      "provider": "ollama",
      "model": "qwen2.5-coder:7b",
      "apiBase": "http://10.157.174.177:11434",
      "roles": ["chat", "edit"],
      "contextLength": 131072
    },
    {
      "name": "Qwen 2.5 Latest (7.6B)",
      "provider": "ollama",
      "model": "qwen2.5:latest",
      "apiBase": "http://10.157.174.177:11434",
      "roles": ["chat", "edit"],
      "contextLength": 131072
    },
    {
      "name": "Mistral 7B (Fast Alternative)",
      "provider": "ollama",
      "model": "mistral:latest",
      "apiBase": "http://10.157.174.177:11434",
      "roles": ["chat", "edit"],
      "contextLength": 8192
    },
    {
      "name": "Qwen 2.5 Coder 1.5B (Fast Autocomplete)",
      "provider": "ollama",
      "model": "qwen2.5-coder:1.5b",
      "apiBase": "http://10.157.174.177:11434",
      "roles": ["autocomplete"],
      "contextLength": 32768
    },
    {
      "name": "Qwen 2.5 Coder 7B (Heavier Autocomplete)",
      "provider": "ollama",
      "model": "qwen2.5-coder:7b",
      "apiBase": "http://10.157.174.177:11434",
      "roles": ["autocomplete"],
      "contextLength": 131072
    },
    {
      "name": "Nomic Embed Text",
      "provider": "ollama",
      "model": "nomic-embed-text:latest",
      "apiBase": "http://10.157.174.177:11434",
      "embeddingOnly": true,
      "dimension": 768
    }
  ],
  "ui": {
    "defaultModel": "Llama 3.1 8B (Best Balance)",
    "defaultEmbeddingsModel": "Nomic Embed Text"
  },
  "tabAutocomplete": {
    "model": {
      "provider": "ollama",
      "model": "qwen2.5-coder:1.5b",
      "apiBase": "http://10.157.174.177:11434"
    },
    "debounceDelay": 300,
    "maxPromptTokens": 1024,
    "prefixPercentage": 0.5
  },
  "experimental": {
    "localRerank": false,
    "useChromiumForDocs": false
  }
}`;

	let copiedMap: Record<string, boolean> = {};

	function copyToClipboard(text: string, key: string) {
		navigator.clipboard.writeText(text).then(() => {
			copiedMap[key] = true;
			copiedMap = { ...copiedMap };
			setTimeout(() => {
				copiedMap[key] = false;
				copiedMap = { ...copiedMap };
			}, 2000);
		});
	}
</script>

<div class="h-screen w-full overflow-y-auto bg-white dark:bg-gray-900 text-gray-800 dark:text-gray-200">
	<div class="max-w-3xl mx-auto px-6 py-10">

		<!-- Header -->
		<div class="flex items-center gap-3 mb-2">
			<svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-blue-500 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
			</svg>
			<h1 class="text-2xl font-bold">Add Local AI Models to VSCode</h1>
		</div>
		<p class="text-gray-500 dark:text-gray-400 mb-6 text-sm">
			Follow these steps to connect VSCode to the shared Ollama server using the Continue extension.
			No programming experience needed.
		</p>

		<!-- Warning banner -->
		<div class="flex gap-3 bg-amber-50 dark:bg-amber-900/20 border border-amber-300 dark:border-amber-700 rounded-lg p-4 mb-8">
			<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-amber-500 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" />
			</svg>
			<div class="text-sm text-amber-800 dark:text-amber-200 space-y-1">
				<p><strong>Before you start — please read:</strong></p>
				<ul class="list-disc list-inside space-y-1 ml-1">
					<li>Do <strong>not</strong> stop or restart the Ollama service at <code class="bg-amber-100 dark:bg-amber-800/40 px-1 rounded text-xs">http://10.157.174.177:11434</code> — it is shared.</li>
					<li>Do <strong>not</strong> edit any other file in this project.</li>
					<li>Do <strong>not</strong> run <code class="bg-amber-100 dark:bg-amber-800/40 px-1 rounded text-xs">ollama pull</code> — models are already on the server.</li>
					<li>Only the file <code class="bg-amber-100 dark:bg-amber-800/40 px-1 rounded text-xs">~/.continue/config.json</code> will be changed.</li>
				</ul>
			</div>
		</div>

		<!-- Steps -->
		<div class="space-y-6">

			<!-- Step 1 -->
			<div class="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden">
				<div class="flex items-center gap-3 bg-gray-50 dark:bg-gray-800 px-5 py-4">
					<span class="flex-shrink-0 w-7 h-7 rounded-full bg-blue-500 text-white text-sm font-bold flex items-center justify-center">1</span>
					<h2 class="font-semibold text-base">Install the Continue Extension</h2>
				</div>
				<div class="px-5 py-4 space-y-3 text-sm">
					<ol class="list-decimal list-inside space-y-2 text-gray-700 dark:text-gray-300">
						<li>Open VSCode.</li>
						<li>Click the <strong>Extensions</strong> icon in the left sidebar (four squares icon).</li>
						<li>In the search box, type:</li>
					</ol>
					<div class="relative">
						<pre class="bg-gray-100 dark:bg-gray-800 rounded-lg px-4 py-3 text-sm font-mono overflow-x-auto">Continue</pre>
						<button
							on:click={() => copyToClipboard('Continue', 'step1')}
							class="absolute top-2 right-2 text-xs px-2 py-1 rounded bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition"
						>
							{copiedMap['step1'] ? '✓ Copied' : 'Copy'}
						</button>
					</div>
					<ol class="list-decimal list-inside space-y-2 text-gray-700 dark:text-gray-300" start="4">
						<li>Find <strong>Continue</strong> by <em>Continue.dev</em> and click <strong>Install</strong>.</li>
						<li>Wait for it to finish. A Continue icon will appear in the left sidebar.</li>
					</ol>
				</div>
			</div>

			<!-- Step 2 -->
			<div class="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden">
				<div class="flex items-center gap-3 bg-gray-50 dark:bg-gray-800 px-5 py-4">
					<span class="flex-shrink-0 w-7 h-7 rounded-full bg-blue-500 text-white text-sm font-bold flex items-center justify-center">2</span>
					<h2 class="font-semibold text-base">Open the Continue Config File</h2>
				</div>
				<div class="px-5 py-4 space-y-3 text-sm text-gray-700 dark:text-gray-300">
					<p>Press <kbd class="bg-gray-200 dark:bg-gray-700 px-1.5 py-0.5 rounded text-xs font-mono">Ctrl+Shift+P</kbd> to open the Command Palette, then type:</p>
					<div class="relative">
						<pre class="bg-gray-100 dark:bg-gray-800 rounded-lg px-4 py-3 text-sm font-mono overflow-x-auto">Continue: Open Config File</pre>
						<button
							on:click={() => copyToClipboard('Continue: Open Config File', 'step2')}
							class="absolute top-2 right-2 text-xs px-2 py-1 rounded bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition"
						>
							{copiedMap['step2'] ? '✓ Copied' : 'Copy'}
						</button>
					</div>
					<p>Click the result. A file called <code class="bg-gray-100 dark:bg-gray-800 px-1 rounded">config.json</code> will open.</p>
					<p class="text-gray-500 dark:text-gray-400">If that doesn't work, open the file manually at:</p>
					<div class="relative">
						<pre class="bg-gray-100 dark:bg-gray-800 rounded-lg px-4 py-3 text-sm font-mono overflow-x-auto">~/.continue/config.json</pre>
						<button
							on:click={() => copyToClipboard('~/.continue/config.json', 'step2b')}
							class="absolute top-2 right-2 text-xs px-2 py-1 rounded bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition"
						>
							{copiedMap['step2b'] ? '✓ Copied' : 'Copy'}
						</button>
					</div>
				</div>
			</div>

			<!-- Step 3 -->
			<div class="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden">
				<div class="flex items-center gap-3 bg-gray-50 dark:bg-gray-800 px-5 py-4">
					<span class="flex-shrink-0 w-7 h-7 rounded-full bg-blue-500 text-white text-sm font-bold flex items-center justify-center">3</span>
					<h2 class="font-semibold text-base">Replace the Config Content</h2>
				</div>
				<div class="px-5 py-4 space-y-3 text-sm text-gray-700 dark:text-gray-300">
					<ol class="list-decimal list-inside space-y-2">
						<li>Select <strong>all</strong> the text in the file with <kbd class="bg-gray-200 dark:bg-gray-700 px-1.5 py-0.5 rounded text-xs font-mono">Ctrl+A</kbd>.</li>
						<li>Delete it, then paste the config below.</li>
					</ol>
					<div class="relative">
						<pre class="bg-gray-100 dark:bg-gray-800 rounded-lg px-4 py-3 text-xs font-mono overflow-x-auto max-h-64">{configJson}</pre>
						<button
							on:click={() => copyToClipboard(configJson, 'step3')}
							class="absolute top-2 right-2 text-xs px-2 py-1 rounded bg-blue-500 hover:bg-blue-600 text-white transition font-medium"
						>
							{copiedMap['step3'] ? '✓ Copied!' : 'Copy Config'}
						</button>
					</div>
					<p>Save the file with <kbd class="bg-gray-200 dark:bg-gray-700 px-1.5 py-0.5 rounded text-xs font-mono">Ctrl+S</kbd>.</p>
				</div>
			</div>

			<!-- Step 4 -->
			<div class="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden">
				<div class="flex items-center gap-3 bg-gray-50 dark:bg-gray-800 px-5 py-4">
					<span class="flex-shrink-0 w-7 h-7 rounded-full bg-blue-500 text-white text-sm font-bold flex items-center justify-center">4</span>
					<h2 class="font-semibold text-base">Reload VSCode</h2>
				</div>
				<div class="px-5 py-4 space-y-3 text-sm text-gray-700 dark:text-gray-300">
					<p>Press <kbd class="bg-gray-200 dark:bg-gray-700 px-1.5 py-0.5 rounded text-xs font-mono">Ctrl+Shift+P</kbd>, then type:</p>
					<div class="relative">
						<pre class="bg-gray-100 dark:bg-gray-800 rounded-lg px-4 py-3 text-sm font-mono overflow-x-auto">Developer: Reload Window</pre>
						<button
							on:click={() => copyToClipboard('Developer: Reload Window', 'step4')}
							class="absolute top-2 right-2 text-xs px-2 py-1 rounded bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition"
						>
							{copiedMap['step4'] ? '✓ Copied' : 'Copy'}
						</button>
					</div>
					<p>Click it. VSCode will restart in a few seconds. Your project and files will be exactly as you left them.</p>
				</div>
			</div>

			<!-- Step 5 -->
			<div class="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden">
				<div class="flex items-center gap-3 bg-gray-50 dark:bg-gray-800 px-5 py-4">
					<span class="flex-shrink-0 w-7 h-7 rounded-full bg-blue-500 text-white text-sm font-bold flex items-center justify-center">5</span>
					<h2 class="font-semibold text-base">Verify It Works</h2>
				</div>
				<div class="px-5 py-4 space-y-3 text-sm text-gray-700 dark:text-gray-300">
					<ol class="list-decimal list-inside space-y-2">
						<li>Click the <strong>Continue</strong> icon in the left sidebar.</li>
						<li>At the bottom of the panel you should see <strong>Llama 3.1 8B (Best Balance)</strong>.</li>
						<li>Type a simple question in the chat box, for example:</li>
					</ol>
					<div class="relative">
						<pre class="bg-gray-100 dark:bg-gray-800 rounded-lg px-4 py-3 text-sm font-mono overflow-x-auto">What is Python?</pre>
						<button
							on:click={() => copyToClipboard('What is Python?', 'step5')}
							class="absolute top-2 right-2 text-xs px-2 py-1 rounded bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition"
						>
							{copiedMap['step5'] ? '✓ Copied' : 'Copy'}
						</button>
					</div>
					<p>If you get a response, everything is working.</p>
					<p>To check the Ollama server is reachable, open a terminal in VSCode (<kbd class="bg-gray-200 dark:bg-gray-700 px-1.5 py-0.5 rounded text-xs font-mono">Ctrl+`</kbd>) and run:</p>
					<div class="relative">
						<pre class="bg-gray-100 dark:bg-gray-800 rounded-lg px-4 py-3 text-sm font-mono overflow-x-auto">curl http://10.157.174.177:11434</pre>
						<button
							on:click={() => copyToClipboard('curl http://10.157.174.177:11434', 'step5b')}
							class="absolute top-2 right-2 text-xs px-2 py-1 rounded bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition"
						>
							{copiedMap['step5b'] ? '✓ Copied' : 'Copy'}
						</button>
					</div>
					<p>You should see: <code class="bg-gray-100 dark:bg-gray-800 px-1 rounded">Ollama is running</code></p>
				</div>
			</div>

		</div>

		<!-- Models summary -->
		<div class="mt-8 border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden">
			<div class="bg-gray-50 dark:bg-gray-800 px-5 py-3">
				<h2 class="font-semibold text-sm">Available Models</h2>
			</div>
			<div class="px-5 py-4 grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs text-gray-700 dark:text-gray-300">
				<div class="flex items-center gap-2">
					<span class="w-2 h-2 rounded-full bg-blue-400 flex-shrink-0"></span>
					<span>Llama 3 70B — Best quality, slower</span>
				</div>
				<div class="flex items-center gap-2">
					<span class="w-2 h-2 rounded-full bg-blue-400 flex-shrink-0"></span>
					<span>Qwen 2.5 14B — High quality</span>
				</div>
				<div class="flex items-center gap-2">
					<span class="w-2 h-2 rounded-full bg-green-400 flex-shrink-0"></span>
					<span>Llama 3.1 8B — Best balance (default)</span>
				</div>
				<div class="flex items-center gap-2">
					<span class="w-2 h-2 rounded-full bg-blue-400 flex-shrink-0"></span>
					<span>Qwen 2.5 Coder 7B — Specialized for code</span>
				</div>
				<div class="flex items-center gap-2">
					<span class="w-2 h-2 rounded-full bg-blue-400 flex-shrink-0"></span>
					<span>Qwen 2.5 Latest 7.6B — General purpose</span>
				</div>
				<div class="flex items-center gap-2">
					<span class="w-2 h-2 rounded-full bg-blue-400 flex-shrink-0"></span>
					<span>Mistral 7B — Fast alternative</span>
				</div>
				<div class="flex items-center gap-2">
					<span class="w-2 h-2 rounded-full bg-purple-400 flex-shrink-0"></span>
					<span>Qwen 2.5 Coder 1.5B — Fast autocomplete</span>
				</div>
				<div class="flex items-center gap-2">
					<span class="w-2 h-2 rounded-full bg-purple-400 flex-shrink-0"></span>
					<span>Qwen 2.5 Coder 7B — Heavier autocomplete</span>
				</div>
			</div>
		</div>

		<p class="text-center text-xs text-gray-400 dark:text-gray-600 mt-8 pb-4">
			If something looks wrong, redo Step 3 and paste the config again.
		</p>

	</div>
</div>
