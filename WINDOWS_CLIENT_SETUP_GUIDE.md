# 🪟 Windows Client Setup Guide
## Connect to Remote LLM Server from VSCode

This guide shows Windows users how to use the LLM server at **10.157.174.177** as an AI coding assistant in VSCode.

---

## 📋 What You'll Get

- ✅ AI coding assistant in VSCode (like GitHub Copilot)
- ✅ Free and unlimited usage
- ✅ Uses powerful LLMs from the server
- ✅ Code completion, chat, refactoring
- ✅ Works on your Windows computer

---

## 🎯 Prerequisites

- Windows 10 or 11
- Internet connection to the network (10.157.174.0/23)
- Administrator access (for installation)

---

## 📥 Step 1: Install VSCode

### Option A: Download from Website

1. Open your web browser
2. Go to: https://code.visualstudio.com/
3. Click the big blue "Download for Windows" button
4. Run the downloaded file: `VSCodeUserSetup-x64-*.exe`
5. Follow the installation wizard:
   - ✅ Accept the license agreement
   - ✅ Check "Add to PATH"
   - ✅ Check "Create a desktop icon"
   - ✅ Check "Add 'Open with Code' action"
6. Click "Install"
7. Click "Finish"

### Option B: Using Winget (Windows 11)

1. Open PowerShell or Command Prompt
2. Run:
   ```powershell
   winget install Microsoft.VisualStudioCode
   ```

### Verify Installation

1. Open VSCode (double-click desktop icon or search "Visual Studio Code")
2. You should see the VSCode welcome screen

---

## 🔌 Step 2: Install Continue Extension

### Method 1: Via VSCode UI (Recommended)

1. Open VSCode
2. Click the Extensions icon in the left sidebar (or press `Ctrl+Shift+X`)
3. In the search box, type: `Continue`
4. Find "Continue - Codestral, Claude, and more"
5. Click the blue "Install" button
6. Wait for installation to complete (30 seconds)

### Method 2: Via Command Line

1. Open Command Prompt or PowerShell
2. Run:
   ```powershell
   code --install-extension Continue.continue
   ```

### Verify Installation

1. Look for the Continue icon in the left sidebar (looks like ">_")
2. Or press `Ctrl+L` - Continue chat should open

---

## ⚙️ Step 3: Configure Continue to Use Remote LLMs

### Open Configuration File

1. In VSCode, press `Ctrl+Shift+P` (Command Palette)
2. Type: `Continue: Open Config`
3. Press Enter
4. A file named `config.ts` will open

### Replace Configuration

**Delete everything** in the file and paste this:

```typescript
import { defineConfig } from "continue";

export default defineConfig({
  models: [
    {
      title: "Qwen 2.5 Coder 7B ⭐ (Best for Coding)",
      provider: "ollama",
      model: "qwen2.5-coder:7b",
      apiBase: "http://10.157.174.177:11434"
    },
    {
      title: "Qwen 2.5 14B (Best Overall)",
      provider: "ollama",
      model: "qwen2.5:14b",
      apiBase: "http://10.157.174.177:11434"
    },
    {
      title: "Llama 3.1 8B (Fast)",
      provider: "ollama",
      model: "llama3.1:8b-instruct-q4_K_M",
      apiBase: "http://10.157.174.177:11434"
    },
    {
      title: "Mistral 7B (Efficient)",
      provider: "ollama",
      model: "mistral:latest",
      apiBase: "http://10.157.174.177:11434"
    }
  ],
  tabAutocompleteModel: {
    title: "Qwen 2.5 Coder 1.5B (Autocomplete)",
    provider: "ollama",
    model: "qwen2.5-coder:1.5b",
    apiBase: "http://10.157.174.177:11434"
  },
  embeddingsProvider: {
    provider: "ollama",
    model: "nomic-embed-text",
    apiBase: "http://10.157.174.177:11434"
  },
  systemMessage: "You are an expert programmer. Provide concise, production-ready code with proper error handling."
});
```

### Save Configuration

1. Press `Ctrl+S` to save
2. Close the config file

---

## 🔄 Step 4: Reload VSCode

1. Press `Ctrl+Shift+P`
2. Type: `Reload Window`
3. Press Enter
4. VSCode will restart

---

## ✅ Step 5: Test Your Setup

### Test 1: Chat with AI

1. Press `Ctrl+L` to open Continue chat
2. You should see a dropdown at the top showing:
   ```
   [Qwen 2.5 Coder 7B ⭐ (Best for Coding) ▼]
   ```
3. Type in the chat:
   ```
   Write a Python function to calculate fibonacci numbers
   ```
4. Wait 3-5 seconds
5. You should see AI-generated code!

### Test 2: Inline Code Editing

1. Create a new file: `Ctrl+N`
2. Select language: Click "Select a language" → Choose "Python"
3. Write some code:
   ```python
   def add(a, b):
       return a + b
   ```
4. Select the function (click and drag)
5. Press `Ctrl+I`
6. Type: `Add type hints and error handling`
7. Press Enter
8. AI will modify the code!

### Test 3: Code Completion

1. In a Python file, start typing:
   ```python
   def calculate_sum
   ```
2. Wait 1-2 seconds
3. You should see AI suggestions appear
4. Press `Tab` to accept

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+L` | Open Chat | Ask questions, generate code |
| `Ctrl+I` | Inline Edit | Modify selected code |
| `Tab` | Accept | Accept autocomplete suggestion |
| `Ctrl+Shift+L` | New Chat | Start fresh conversation |
| `Esc` | Cancel | Close chat or cancel operation |

---

## 🎯 Available Models

Click the model name in Continue chat to switch between:

| Model | Speed | Best For |
|-------|-------|----------|
| **Qwen 2.5 Coder 7B** ⭐ | 3-5s | Code generation, debugging |
| **Qwen 2.5 14B** | 5-8s | Complex refactoring |
| **Llama 3.1 8B** | 2-4s | Quick questions |
| **Mistral 7B** | 2-4s | Simple tasks |

**Autocomplete**: Qwen 2.5 Coder 1.5B (automatic, very fast)

---

## 💡 Example Usage

### Generate Code
```
Ctrl+L → "Create a REST API endpoint using Flask"
```

### Explain Code
```
Select code → Ctrl+L → "Explain what this does"
```

### Add Documentation
```
Select function → Ctrl+I → "Add docstring with examples"
```

### Fix Bugs
```
Select buggy code → Ctrl+I → "Fix the bug in this code"
```

### Refactor
```
Select code → Ctrl+I → "Refactor to use list comprehension"
```

### Search Codebase
```
Ctrl+L → "@codebase where is the authentication logic?"
```

---

## 🔧 Troubleshooting

### Problem: "Failed to connect to server"

**Solution 1: Check Network Connection**
1. Open Command Prompt
2. Run:
   ```cmd
   ping 10.157.174.177
   ```
3. You should see replies. If not, check your network connection.

**Solution 2: Test API Access**
1. Open web browser
2. Go to: http://10.157.174.177:11434/api/tags
3. You should see JSON data with model names
4. If you see an error, contact your network administrator

**Solution 3: Check Firewall**
1. Windows Firewall might be blocking the connection
2. Open Windows Defender Firewall
3. Click "Allow an app through firewall"
4. Find "Visual Studio Code" and check both Private and Public
5. Click OK

### Problem: Models not showing

**Solution:**
1. Press `Ctrl+Shift+P`
2. Type: `Continue: Open Config`
3. Verify `apiBase` is: `http://10.157.174.177:11434`
4. Save and reload: `Ctrl+Shift+P` → `Reload Window`

### Problem: Slow responses

**Possible causes:**
- Network congestion (many users)
- Server is busy with other requests
- Try switching to faster model (Llama 3.1 8B)

**Solution:**
1. Click model name in chat
2. Select "Llama 3.1 8B (Fast)"
3. Responses should be faster (2-4 seconds)

### Problem: Autocomplete not working

**Solution:**
1. Wait 2-3 seconds after typing
2. Try pressing `Tab` manually
3. Check Continue output: `View` → `Output` → Select "Continue"

---

## 🔒 Security & Privacy

### What Data is Sent to the Server?

- ✅ Your code snippets (for AI processing)
- ✅ Your prompts and questions
- ❌ No personal information
- ❌ No files are uploaded (only selected code)

### Is it Private?

- ✅ All processing happens on the local server (10.157.174.177)
- ✅ No data sent to external cloud services
- ✅ No internet connection required (except to the server)
- ✅ Your code stays within the network

### Best Practices

- Don't share sensitive credentials in code you send to AI
- Use for code generation, not for processing confidential data
- The server administrator can see usage logs

---

## 📊 Performance Tips

### For Best Performance:

1. **Use the right model for the task:**
   - Quick questions → Llama 3.1 8B
   - Code generation → Qwen 2.5 Coder 7B
   - Complex refactoring → Qwen 2.5 14B

2. **Be specific in prompts:**
   - ✅ "Add error handling for network requests"
   - ❌ "improve this"

3. **Use context providers:**
   - `@codebase` - Search entire project
   - `@folder` - Search specific folder
   - `@terminal` - Include terminal output

4. **Keep prompts concise:**
   - Shorter prompts = faster responses
   - Break complex tasks into smaller steps

---

## 🎨 Advanced Features

### Context Providers

Use `@` to add context to your prompts:

```
@codebase where is the database connection setup?
@folder src/utils what utility functions exist?
@terminal why did this command fail?
@problems help me fix these errors
```

### Slash Commands

```
/edit - Edit code in place
/comment - Add comments
/share - Share conversation
```

### Multiple File Editing

Continue can edit multiple files at once:
```
Ctrl+L → "Refactor the authentication system across all files"
```

---

## 📞 Getting Help

### Check Continue Logs

1. In VSCode: `View` → `Output`
2. Select "Continue" from dropdown
3. Look for error messages

### Test Server Connection

Open Command Prompt and run:
```cmd
curl http://10.157.174.177:11434/api/tags
```

If this doesn't work, contact your network administrator.

### Common Issues

| Issue | Solution |
|-------|----------|
| Can't connect | Check network, ping server |
| Slow responses | Switch to faster model |
| No autocomplete | Wait 2-3 seconds, press Tab |
| Models not showing | Check config, reload window |

---

## 📚 Additional Resources

### Continue Documentation
- Official docs: https://docs.continue.dev/
- Keyboard shortcuts: https://docs.continue.dev/features/shortcuts

### VSCode Documentation
- Getting started: https://code.visualstudio.com/docs
- Tips and tricks: https://code.visualstudio.com/docs/getstarted/tips-and-tricks

---

## ✅ Quick Setup Checklist

- [ ] Install VSCode
- [ ] Install Continue extension
- [ ] Configure with server IP (10.157.174.177)
- [ ] Save configuration
- [ ] Reload VSCode
- [ ] Test with Ctrl+L
- [ ] Try code generation
- [ ] Test autocomplete

---

## 🎉 You're All Set!

You now have a powerful AI coding assistant in VSCode, powered by the LLM server!

**Quick Start:**
1. Press `Ctrl+L` to chat
2. Press `Ctrl+I` to edit code
3. Press `Tab` to accept suggestions

**Need help?** Contact your IT administrator or check the troubleshooting section above.

---

**Server Information:**
- Server IP: 10.157.174.177
- Port: 11434
- Network: 10.157.174.0/23
- Available 24/7

Enjoy coding with AI! 🚀
