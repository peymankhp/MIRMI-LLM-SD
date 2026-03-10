#!/usr/bin/env python3
"""
Example: How to use Ollama API with Python
Run: python3 example_api_usage.py
"""

import requests
import json

# Configuration
OLLAMA_BASE_URL = "http://localhost:11434"
MODEL = "mistral:latest"

print("=" * 70)
print("Ollama API Usage Examples")
print("=" * 70)
print()

# Example 1: List available models
print("Example 1: List Available Models")
print("-" * 70)
response = requests.get(f"{OLLAMA_BASE_URL}/api/tags")
models = response.json()
print(f"Available models: {len(models['models'])}")
for model in models['models']:
    print(f"  - {model['name']} ({model['size'] / 1e9:.1f} GB)")
print()

# Example 2: Simple text generation
print("Example 2: Simple Text Generation")
print("-" * 70)
prompt = "Explain what an API is in one sentence."
print(f"Prompt: {prompt}")
print("Generating response...")

response = requests.post(
    f"{OLLAMA_BASE_URL}/api/generate",
    json={
        "model": MODEL,
        "prompt": prompt,
        "stream": False
    }
)
result = response.json()
print(f"Response: {result['response']}")
print()

# Example 3: Chat conversation
print("Example 3: Chat Conversation")
print("-" * 70)
messages = [
    {"role": "user", "content": "What is Python?"}
]
print(f"User: {messages[0]['content']}")

response = requests.post(
    f"{OLLAMA_BASE_URL}/api/chat",
    json={
        "model": MODEL,
        "messages": messages,
        "stream": False
    }
)
result = response.json()
print(f"Assistant: {result['message']['content']}")
print()

# Example 4: Using OpenAI-compatible API
print("Example 4: OpenAI-Compatible API")
print("-" * 70)
print("This works with OpenAI SDK!")

try:
    from openai import OpenAI
    
    client = OpenAI(
        base_url=f"{OLLAMA_BASE_URL}/v1",
        api_key="ollama"  # Can be anything
    )
    
    completion = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "user", "content": "Write a haiku about coding"}
        ]
    )
    
    print(f"Response: {completion.choices[0].message.content}")
    print()
    print("✓ OpenAI SDK works perfectly!")
    
except ImportError:
    print("OpenAI SDK not installed. Install with: pip install openai")
    print("Using requests library instead...")
    
    response = requests.post(
        f"{OLLAMA_BASE_URL}/v1/chat/completions",
        headers={
            "Content-Type": "application/json",
            "Authorization": "Bearer ollama"
        },
        json={
            "model": MODEL,
            "messages": [
                {"role": "user", "content": "Write a haiku about coding"}
            ]
        }
    )
    result = response.json()
    print(f"Response: {result['choices'][0]['message']['content']}")
print()

# Example 5: Streaming responses
print("Example 5: Streaming Response (Real-time)")
print("-" * 70)
print("Prompt: Tell me a short joke")
print("Response: ", end="", flush=True)

response = requests.post(
    f"{OLLAMA_BASE_URL}/api/generate",
    json={
        "model": MODEL,
        "prompt": "Tell me a short joke about programming",
        "stream": True
    },
    stream=True
)

for line in response.iter_lines():
    if line:
        chunk = json.loads(line)
        print(chunk.get('response', ''), end='', flush=True)
print("\n")

# Example 6: Custom parameters
print("Example 6: Custom Generation Parameters")
print("-" * 70)
print("Using temperature=0.1 for more focused response...")

response = requests.post(
    f"{OLLAMA_BASE_URL}/api/generate",
    json={
        "model": MODEL,
        "prompt": "What is 2+2?",
        "stream": False,
        "options": {
            "temperature": 0.1,  # Lower = more focused
            "top_p": 0.9,
            "num_predict": 50
        }
    }
)
result = response.json()
print(f"Response: {result['response']}")
print()

# Summary
print("=" * 70)
print("Summary: API Configuration")
print("=" * 70)
print(f"Base URL: {OLLAMA_BASE_URL}")
print(f"OpenAI-Compatible: {OLLAMA_BASE_URL}/v1")
print(f"Current Model: {MODEL}")
print()
print("For Cursor/VS Code/Other Tools:")
print(f"  Base URL: {OLLAMA_BASE_URL}/v1")
print("  API Key: ollama (or any value)")
print(f"  Model: {MODEL}")
print()
print("✓ All examples completed successfully!")
print("=" * 70)
