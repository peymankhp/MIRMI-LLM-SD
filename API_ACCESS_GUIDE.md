# How to Access the LLM API

## Good News! 🎉

Your Ollama API is **already accessible** at `http://localhost:11434`!

I tested it and it's working. You can use it right now with your existing models.

## Quick API Access Examples

### 1. Using cURL (Command Line)

#### List Available Models

```bash
curl http://localhost:11434/api/tags
```

#### Generate Text (Simple)

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "mistral:latest",
  "prompt": "Explain quantum computing in simple terms",
  "stream": false
}'
```

#### Chat Completion (Conversational)

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "mistral:latest",
  "messages": [
    {"role": "user", "content": "Hello! How are you?"}
  ],
  "stream": false
}'
```

#### OpenAI-Compatible API (for tools like Cursor)

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ollama" \
  -d '{
    "model": "mistral:latest",
    "messages": [
      {"role": "user", "content": "Write a Python function to calculate fibonacci"}
    ]
  }'
```

### 2. Using Python

#### Install OpenAI SDK

```bash
pip install openai
```

#### Python Code

```python
from openai import OpenAI

# Point to your local Ollama instance
client = OpenAI(
    base_url='http://localhost:11434/v1',
    api_key='ollama'  # Can be anything
)

# Chat completion
response = client.chat.completions.create(
    model="mistral:latest",
    messages=[
        {"role": "user", "content": "Hello! Write a haiku about coding."}
    ]
)

print(response.choices[0].message.content)
```

#### Using Requests Library

```python
import requests
import json

url = "http://localhost:11434/api/generate"
data = {
    "model": "mistral:latest",
    "prompt": "What is machine learning?",
    "stream": False
}

response = requests.post(url, json=data)
result = response.json()
print(result['response'])
```

### 3. Using JavaScript/Node.js

#### Install OpenAI SDK

```bash
npm install openai
```

#### JavaScript Code

```javascript
import OpenAI from 'openai';

const openai = new OpenAI({
	baseURL: 'http://localhost:11434/v1',
	apiKey: 'ollama' // Can be anything
});

async function chat() {
	const completion = await openai.chat.completions.create({
		model: 'mistral:latest',
		messages: [{ role: 'user', content: 'Explain async/await in JavaScript' }]
	});

	console.log(completion.choices[0].message.content);
}

chat();
```

#### Using Fetch API

```javascript
async function generateText() {
	const response = await fetch('http://localhost:11434/api/generate', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify({
			model: 'mistral:latest',
			prompt: 'Write a joke about programming',
			stream: false
		})
	});

	const data = await response.json();
	console.log(data.response);
}

generateText();
```

### 4. Configure Cursor IDE

Open Cursor Settings and add:

```json
{
	"models": [
		{
			"name": "Mistral Local",
			"provider": "openai",
			"baseURL": "http://localhost:11434/v1",
			"apiKey": "ollama",
			"model": "mistral:latest"
		}
	]
}
```

Or in Cursor's model settings:

- **Provider:** OpenAI Compatible
- **Base URL:** `http://localhost:11434/v1`
- **API Key:** `ollama` (or any value)
- **Model:** `mistral:latest` (or any model from your list)

### 5. Configure VS Code with Continue Extension

Install the Continue extension, then configure:

```json
{
	"models": [
		{
			"title": "Mistral Local",
			"provider": "ollama",
			"model": "mistral:latest",
			"apiBase": "http://localhost:11434"
		}
	]
}
```

## Your Available Models

Based on your current setup:

```
mistral:latest (4.4GB)
mistral:7b-instruct (4.4GB)
llama2:7b-chat (3.8GB)
llama2:13b-chat (7.4GB)
qwen2:7b-instruct (4.4GB)
mixtral:8x7b-instruct-v0.1-q4_0 (26GB)
vicuna:7b (3.8GB)
falcon:7b-instruct (4.2GB)
```

After running the installation script, you'll also have:

- `llama3:8b`
- `qwen2.5:7b`

## API Endpoints Reference

### Native Ollama API

| Endpoint        | Method | Purpose                       |
| --------------- | ------ | ----------------------------- |
| `/api/tags`     | GET    | List all models               |
| `/api/generate` | POST   | Generate text (completion)    |
| `/api/chat`     | POST   | Chat conversation             |
| `/api/pull`     | POST   | Download a model              |
| `/api/push`     | POST   | Upload a model                |
| `/api/create`   | POST   | Create a model from Modelfile |
| `/api/delete`   | DELETE | Delete a model                |
| `/api/show`     | POST   | Show model information        |
| `/api/copy`     | POST   | Copy a model                  |

### OpenAI-Compatible API

| Endpoint               | Method | Purpose             |
| ---------------------- | ------ | ------------------- |
| `/v1/models`           | GET    | List models         |
| `/v1/chat/completions` | POST   | Chat completion     |
| `/v1/completions`      | POST   | Text completion     |
| `/v1/embeddings`       | POST   | Generate embeddings |

## Testing Your API

Run this test script:

```bash
# Test 1: List models
echo "Test 1: Listing models..."
curl -s http://localhost:11434/api/tags | python3 -m json.tool | head -20

# Test 2: Simple generation
echo -e "\n\nTest 2: Generating text..."
curl -s http://localhost:11434/api/generate -d '{
  "model": "mistral:latest",
  "prompt": "Say hello in 3 words",
  "stream": false
}' | python3 -m json.tool

# Test 3: OpenAI-compatible endpoint
echo -e "\n\nTest 3: OpenAI-compatible API..."
curl -s http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistral:latest",
    "messages": [{"role": "user", "content": "Hi"}],
    "max_tokens": 50
  }' | python3 -m json.tool
```

## Streaming Responses

For real-time streaming (like ChatGPT):

### cURL with Streaming

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "mistral:latest",
  "prompt": "Write a story about a robot",
  "stream": true
}'
```

### Python with Streaming

```python
import requests
import json

url = "http://localhost:11434/api/generate"
data = {
    "model": "mistral:latest",
    "prompt": "Write a poem about the ocean",
    "stream": True
}

response = requests.post(url, json=data, stream=True)

for line in response.iter_lines():
    if line:
        chunk = json.loads(line)
        print(chunk.get('response', ''), end='', flush=True)
```

## Advanced: Custom Parameters

You can control generation with parameters:

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "mistral:latest",
  "prompt": "Explain AI",
  "stream": false,
  "options": {
    "temperature": 0.7,
    "top_p": 0.9,
    "top_k": 40,
    "num_predict": 100,
    "stop": ["\n\n"]
  }
}'
```

Parameters:

- `temperature`: 0.0-2.0 (lower = more focused, higher = more creative)
- `top_p`: 0.0-1.0 (nucleus sampling)
- `top_k`: Number of tokens to consider
- `num_predict`: Max tokens to generate
- `stop`: Stop sequences

## Remote Access (From Another Machine)

If you want to access from another computer on your network:

### 1. Find Your Server IP

```bash
hostname -I | awk '{print $1}'
```

### 2. Configure Firewall (if needed)

```bash
# Allow from specific IP
sudo ufw allow from 192.168.1.100 to any port 11434

# Or allow from entire local network
sudo ufw allow from 192.168.1.0/24 to any port 11434
```

### 3. Use Remote URL

```python
client = OpenAI(
    base_url='http://192.168.1.50:11434/v1',  # Your server IP
    api_key='ollama'
)
```

## Common Issues & Solutions

### Issue: Connection Refused

```bash
# Check if Ollama is running
docker ps | grep ollama

# Check if port is exposed
docker port ollama

# If not exposed, run the installation script
./install-models-safe.sh
```

### Issue: Model Not Found

```bash
# List available models
curl http://localhost:11434/api/tags

# Pull a model if needed
docker exec ollama ollama pull llama3:8b
```

### Issue: Slow Response

```bash
# Check GPU usage
nvidia-smi

# Check if model is loaded
docker logs ollama | tail -20
```

## API Documentation

Full Ollama API documentation:

- https://github.com/ollama/ollama/blob/main/docs/api.md

OpenAI API compatibility:

- https://github.com/ollama/ollama/blob/main/docs/openai.md

## Next Steps

1. **Test the API** with the examples above
2. **Run the installation script** to add Llama 3 and Qwen 2.5:
   ```bash
   ./install-models-safe.sh
   ```
3. **Configure your IDE** (Cursor, VS Code, etc.)
4. **Start building** with your local LLMs!

## Quick Reference Card

```
API Base URL:     http://localhost:11434
OpenAI-Compatible: http://localhost:11434/v1
API Key:          ollama (or any value)
Models:           mistral:latest, llama2:13b-chat, qwen2:7b-instruct, etc.

Test Command:
curl http://localhost:11434/api/tags

Generate Text:
curl http://localhost:11434/api/generate -d '{"model":"mistral:latest","prompt":"Hello","stream":false}'
```

Your API is ready to use right now! 🚀
