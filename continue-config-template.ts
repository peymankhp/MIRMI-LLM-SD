import { defineConfig } from 'continue';

// Configuration for connecting to LLM Server at 10.157.174.177
// Copy this entire file content and paste into your Continue config

export default defineConfig({
	models: [
		{
			title: 'Qwen 2.5 Coder 7B ⭐ (Best for Coding)',
			provider: 'ollama',
			model: 'qwen2.5-coder:7b',
			apiBase: 'http://10.157.174.177:11434'
		},
		{
			title: 'Qwen 2.5 14B (Best Overall Quality)',
			provider: 'ollama',
			model: 'qwen2.5:14b',
			apiBase: 'http://10.157.174.177:11434'
		},
		{
			title: 'Llama 3.1 8B (Fast Responses)',
			provider: 'ollama',
			model: 'llama3.1:8b-instruct-q4_K_M',
			apiBase: 'http://10.157.174.177:11434'
		},
		{
			title: 'Mistral 7B (Efficient)',
			provider: 'ollama',
			model: 'mistral:latest',
			apiBase: 'http://10.157.174.177:11434'
		}
	],
	tabAutocompleteModel: {
		title: 'Qwen 2.5 Coder 1.5B (Autocomplete)',
		provider: 'ollama',
		model: 'qwen2.5-coder:1.5b',
		apiBase: 'http://10.157.174.177:11434'
	},
	embeddingsProvider: {
		provider: 'ollama',
		model: 'nomic-embed-text',
		apiBase: 'http://10.157.174.177:11434'
	},
	reranker: {
		name: 'llm',
		params: {
			modelTitle: 'Llama 3.1 8B (Fast Responses)'
		}
	},
	systemMessage:
		'You are an expert programmer. Provide concise, production-ready code with proper error handling and type hints.'
});
