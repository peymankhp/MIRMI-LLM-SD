# 🎯 Enable Ollama Models in VSCode Native Chat

## Configure Your Local LLMs as VSCode Language Model Providers

This guide shows how to make your Ollama models selectable in VSCode's native chat (the "Language Models" panel you're looking at).

---

## ⚙️ Step 1: Configure VSCode Settings

### Open Settings JSON

1. Press `Ctrl+Shift+P` (Command Palette)
2. Type: `Preferences: Open User Settings (JSON)`
3. Press Enter

### Add This Configuration

Paste this into your `settings.json`:

```json
{
  "chat.languageModels": [
    {
      "id": "ollama-qwen-coder-7b",
      "name": "Qwen 2.5 Coder 7B",
      "vendor": "ollama",
      "family": "qwen2.5-coder",
      "version": "7b",
      "maxInputTokens": 32000,
      "maxOutputTokens": 4096,
      "endpoint": "http://localhost:11434/v1/chat/completions",
      "apiKeyCommand": "echo 'ollama'"
    },
    {
      "id": "ollama-qwen-14b",
      "name": "Qwen 2.5 14B",
      "vendor": "ollama",
      "family": "qwen2.5",
      "version": "14b",
      "maxInputTokens": 32000,
      "maxOutputTokens": 4096,
      "endpoint": "http://localhost:11434/v1/chat/completions",
      "apiKeyCommand": "echo 'ollama'"
    },
    {
      "id": "ollama-llama-8b",
      "name": "Llama 3.1 8B",
      "vendor": "ollama",
      "family": "llama3.1",
      "version": "8b",
      "maxInputTokens": 128000,
      "maxOutputTokens": 4096,
      "endpoint": "http://localhost:11434/v1/chat/completions",
      "apiKeyCommand": "echo 'ollama'"
    },
    {
      "id": "ollama-mistral-7b",
      "name": "Mistral 7B",
      "vendor": "ollama",
      "family": "mistral",
      "version": "7b",
      "maxInputTokens": 32000,
      "maxOutputTokens": 4096,
      "endpoint": "http://localhost:11434/v1/chat/completions",
      "apiKeyCommand": "echo 'ollama'"
    }
  ],
  "github.copilot.chat.localization": "auto",
  "github.copilot.chat.useProjectTemplates": true
}
```

### Save and Reload

1. Press `Ctrl+S` to save
2. Press `Ctrl+Shift+P`
3. Type: `Developer: Reload Window`
4. Press Enter

---

## 🔧 Alternative: Use OpenAI-Compatible API

Ollama provides an OpenAI-compatible API endpoint. Configure it like this:

### Settings JSON Configuration

```json
{
  "chat.languageModels": [
    {
      "id": "ollama-local",
      "name": "Ollama Local Models",
      "provider": "openai-compatible",
      "endpoint": "http://localhost:11434/v1",
      "apiKey": "ollama",
      "models": [
        {
          "id": "qwen2.5-coder:7b",
          "name": "Qwen 2.5 Coder 7B"
        },
        {
          "id": "qwen2.5:14b",
          "name": "Qwen 2.5 14B"
        },
        {
          "id": "llama3.1:8b-instruct-q4_K_M",
          "name": "Llama 3.1 8B"
        },
        {
          "id": "mistral:latest",
          "name": "Mistral 7B"
        }
      ]
    }
  ]
}
```

---

## 🎯 Step 2: Install Required Extension

VSCode's native chat requires the **GitHub Copilot Chat** extension to work with custom language models.

### Check if Installed

1. Press `Ctrl+Shift+X`
2. Search: `GitHub Copilot Chat`
3. Should show "Disable" (meaning it's installed)

### If Not Installed

1. Click "Install"
2. Reload VSCode

---

## ⚠️ Important Limitations

### VSCode Native Chat Limitations:

1. **Requires GitHub Copilot Extension**
   - Even for local models
   - May require GitHub account

2. **Limited Custom Model Support**
   - VSCode's chat is primarily designed for Copilot
   - Custom model support is experimental

3. **API Compatibility**
   - Ollama must provide OpenAI-compatible API
   - Some features may not work

---

## 🔄 Alternative Approach: Use LiteLLM Proxy

If direct Ollama integration doesn't work, use LiteLLM as a proxy:

### Step 1: Install LiteLLM

```bash
pip install litellm
```

### Step 2: Start LiteLLM Proxy

```bash
litellm --model ollama/qwen2.5-coder:7b \
        --api_base http://localhost:11434 \
        --port 8000
```

### Step 3: Configure VSCode

```json
{
  "chat.languageModels": [
    {
      "id": "litellm-proxy",
      "name": "Local LLMs via LiteLLM",
      "provider": "openai",
      "endpoint": "http://localhost:8000/v1",
      "apiKey": "sk-1234",
      "models": [
        {
          "id": "ollama/qwen2.5-coder:7b",
          "name": "Qwen 2.5 Coder 7B"
        }
      ]
    }
  ]
}
```

---

## 📋 Step 3: Verify Configuration

### Check Language Models Panel

1. Open the "Language Models" panel (you already have it open)
2. Look for your models under a new section
3. They should now be selectable

### Test in Chat

1. Open VSCode Chat (usually in sidebar or `Ctrl+Alt+I`)
2. Select your model from dropdown
3. Type a test message
4. Should respond using your local LLM

---

## 🔧 Troubleshooting

### Problem: Models don't appear

**Solution 1: Check Ollama API**
```bash
curl http://localhost:11434/v1/models
```

Should return list of models.

**Solution 2: Check VSCode Output**
1. View → Output
2. Select "Language Models" or "GitHub Copilot"
3. Look for errors

**Solution 3: Verify Settings**
1. `Ctrl+Shift+P` → "Preferences: Open User Settings (JSON)"
2. Check `chat.languageModels` is configured
3. Reload window

### Problem: Can't select models

**Possible causes:**
- GitHub Copilot Chat not installed
- Ollama API not compatible
- VSCode version too old

**Solution:**
- Update VSCode to latest version
- Ensure GitHub Copilot Chat extension is installed
- Try LiteLLM proxy approach

### Problem: Models show but don't respond

**Solution:**
1. Check Ollama is running: `ollama list`
2. Test API: `curl http://localhost:11434/v1/chat/completions -d '{"model":"qwen2.5-coder:7b","messages":[{"role":"user","content":"hi"}]}'`
3. Check VSCode logs for errors

---

## 💡 Why This is Complex

VSCode's native chat is designed primarily for GitHub Copilot (cloud models). Adding local models requires:

1. OpenAI-compatible API endpoint
2. Proper authentication (even if fake)
3. GitHub Copilot extension
4. Correct model configuration

**This is why Continue extension exists** - it's specifically designed for local LLMs and much easier to configure.

---

## ✅ Recommended Configuration

Here's the complete `settings.json` that should work:

```json
{
  "chat.languageModels": [
    {
      "id": "ollama-provider",
      "name": "Ollama Local",
      "provider": "openai-compatible",
      "endpoint": "http://localhost:11434/v1",
      "apiKey": "ollama",
      "models": [
        "qwen2.5-coder:7b",
        "qwen2.5:14b",
        "llama3.1:8b-instruct-q4_K_M",
        "mistral:latest"
      ]
    }
  ],
  "github.copilot.enable": {
    "*": true
  }
}
```

---

## 🎯 Quick Setup Script

Save this as `configure-vscode-ollama.sh`:

```bash
#!/bin/bash

echo "Configuring VSCode for Ollama models..."

# Backup existing settings
cp ~/.config/Code/User/settings.json ~/.config/Code/User/settings.json.backup 2>/dev/null || true

# Create settings
cat > ~/.config/Code/User/settings.json << 'EOF'
{
  "chat.languageModels": [
    {
      "id": "ollama-local",
      "name": "Ollama Local Models",
      "provider": "openai-compatible",
      "endpoint": "http://localhost:11434/v1",
      "apiKey": "ollama",
      "models": [
        {
          "id": "qwen2.5-coder:7b",
          "name": "Qwen 2.5 Coder 7B"
        },
        {
          "id": "qwen2.5:14b",
          "name": "Qwen 2.5 14B"
        },
        {
          "id": "llama3.1:8b-instruct-q4_K_M",
          "name": "Llama 3.1 8B"
        },
        {
          "id": "mistral:latest",
          "name": "Mistral 7B"
        }
      ]
    }
  ]
}
EOF

echo "✅ Configuration created!"
echo "Now reload VSCode: Ctrl+Shift+P → 'Developer: Reload Window'"
```

Run it:
```bash
chmod +x configure-vscode-ollama.sh
./configure-vscode-ollama.sh
```

---

## 📚 Additional Resources

- VSCode Language Models API: https://code.visualstudio.com/api/extension-guides/language-model
- Ollama OpenAI Compatibility: https://github.com/ollama/ollama/blob/main/docs/openai.md
- GitHub Copilot Chat: https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat

---

## ⚠️ Final Note

If this doesn't work after trying all approaches, it's because:

1. VSCode's native chat has limited support for custom models
2. It's primarily designed for GitHub Copilot
3. The API may not be fully compatible

**In that case, Continue extension is the better solution** - it's specifically built for local LLMs and works reliably.

But try the configurations above first! 🚀
