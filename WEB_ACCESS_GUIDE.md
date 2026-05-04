# Web Access Guide: Access Each Model via Browser

## 🎉 Two Ways to Access Your Models via Web

I've created two web interfaces for you to access your LLM models through a browser:

### Option 1: Simple HTML Interface (No Installation Required) ⭐ EASIEST

### Option 2: Flask Web App (More Features)

---

## Option 1: Simple HTML Interface (Recommended)

### How to Use

1. **Open the HTML file in your browser:**

   ```bash
   # On Linux
   xdg-open web-interface.html

   # Or just open it manually in your browser
   firefox web-interface.html
   # or
   google-chrome web-interface.html
   ```

2. **That's it!** The interface will:
   - Automatically load all your available models
   - Let you select any model with a click
   - Send messages and get responses
   - Show real-time statistics

### Features

✅ No installation required - just open in browser  
✅ Beautiful, modern interface  
✅ Select any model with one click  
✅ Real-time or batch responses  
✅ Adjustable parameters (temperature, tokens, etc.)  
✅ Response statistics (tokens, time, model used)  
✅ Streaming support for real-time responses

### Screenshots of Features

**Model Selection:**

- Click any model card to select it
- Active model is highlighted in purple
- Shows model size for each

**Chat Interface:**

- Type your message
- Press Enter or click "Send Message"
- See response in real-time (if streaming enabled)
- View statistics after each response

**Advanced Options:**

- Temperature: Control creativity (0.0 = focused, 2.0 = creative)
- Max Tokens: Limit response length
- Top P: Nucleus sampling
- Streaming: Real-time vs complete response

---

## Option 2: Flask Web App

### Installation

```bash
# Install Flask (if not already installed)
pip install flask requests

# Or
pip3 install flask requests
```

### How to Run

```bash
# Start the Flask server
python3 web_app.py
```

You'll see:

```
🚀 Starting Ollama Web Interface
📡 Ollama API: http://localhost:11434
🌐 Web Interface: http://localhost:5000
```

### Access the Interface

Open your browser and go to:

```
http://localhost:5000
```

### Features

✅ Server-side processing (more secure)  
✅ Can be accessed from other devices on your network  
✅ Better for production use  
✅ Easier to extend with custom features  
✅ API endpoints for integration

### Access from Other Devices

If you want to access from another computer/phone on your network:

1. Find your server IP:

   ```bash
   hostname -I | awk '{print $1}'
   ```

2. Open in browser on other device:

   ```
   http://<your-server-ip>:5000
   ```

3. Configure firewall (if needed):
   ```bash
   sudo ufw allow 5000
   ```

---

## Comparison: Which One to Use?

| Feature      | HTML Interface   | Flask App          |
| ------------ | ---------------- | ------------------ |
| Installation | None             | Requires Flask     |
| Setup        | Just open file   | Run Python script  |
| Access       | Local only       | Network accessible |
| Speed        | Direct API calls | Via Flask server   |
| Security     | Browser-based    | Server-based       |
| Best For     | Quick testing    | Production use     |

**Recommendation:** Start with the HTML interface for simplicity!

---

## Using the Web Interface

### 1. Select a Model

Click on any model card to select it. The selected model will be highlighted.

Your available models:

- mistral:latest (4.4 GB)
- llama2:13b-chat (7.4 GB)
- qwen2:7b-instruct (4.4 GB)
- mixtral:8x7b-instruct (26 GB)
- And more...

### 2. Type Your Message

Enter your prompt in the text area. Examples:

- "Explain quantum computing in simple terms"
- "Write a Python function to sort a list"
- "Tell me a joke about programming"
- "Summarize the benefits of AI"

### 3. Adjust Settings (Optional)

**Temperature (0.0 - 2.0):**

- 0.0-0.3: Very focused, deterministic
- 0.4-0.7: Balanced (default: 0.7)
- 0.8-1.2: Creative
- 1.3-2.0: Very creative, random

**Max Tokens:**

- Controls maximum response length
- Default: 500 tokens (~375 words)

**Streaming:**

- Yes: See response word-by-word in real-time
- No: Wait for complete response

### 4. Send and View Response

Click "Send Message" or press Enter. The response will appear in the response box.

Statistics shown:

- **Tokens:** Number of words in response
- **Response Time:** How long it took
- **Model:** Which model was used

---

## API Endpoints (Flask App)

If you're using the Flask app, you can also access it programmatically:

### Get Available Models

```bash
curl http://localhost:5000/api/models
```

### Generate Text

```bash
curl -X POST http://localhost:5000/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistral:latest",
    "prompt": "Hello!",
    "temperature": 0.7
  }'
```

---

## Troubleshooting

### Problem: "Cannot connect to Ollama API"

**Solution:**

```bash
# Check if Ollama is running
docker ps | grep ollama

# Test API directly
curl http://localhost:11434/api/tags

# If not working, check the installation guide
./install-models-safe.sh
```

### Problem: "No models found"

**Solution:**

```bash
# List models
docker exec ollama ollama list

# Pull a model if needed
docker exec ollama ollama pull mistral:latest
```

### Problem: Flask app won't start

**Solution:**

```bash
# Install Flask
pip3 install flask requests

# Check if port 5000 is available
sudo netstat -tlnp | grep 5000

# Use different port if needed
# Edit web_app.py and change port=5000 to port=8000
```

### Problem: Slow responses

**Solution:**

- Check GPU usage: `nvidia-smi`
- Use smaller models (7B instead of 13B)
- Reduce max_tokens setting
- Check if other processes are using GPU

---

## Advanced: Customize the Interface

### Change API URL

If your Ollama is on a different server:

**HTML Interface:**
Edit `web-interface.html`, line ~200:

```javascript
const API_BASE = 'http://your-server-ip:11434';
```

**Flask App:**
Edit `web_app.py`, line ~15:

```python
OLLAMA_BASE_URL = "http://your-server-ip:11434"
```

### Change Flask Port

Edit `web_app.py`, last line:

```python
app.run(host='0.0.0.0', port=8000, debug=True)  # Changed from 5000 to 8000
```

### Add Custom Styling

Both interfaces use CSS that you can customize. Look for the `<style>` section in the HTML.

---

## Security Considerations

### HTML Interface

- Runs entirely in your browser
- Direct connection to Ollama API
- Safe for local use
- Don't expose Ollama port to internet

### Flask App

- Acts as a proxy to Ollama
- Can add authentication if needed
- Better for multi-user scenarios
- Configure firewall for network access

### Recommended Security

```bash
# Allow Flask only from local network
sudo ufw allow from 192.168.1.0/24 to any port 5000

# Or specific IP
sudo ufw allow from 192.168.1.100 to any port 5000

# Check firewall status
sudo ufw status
```

---

## Quick Start Commands

### HTML Interface

```bash
# Just open in browser
xdg-open web-interface.html
```

### Flask App

```bash
# Install dependencies
pip3 install flask requests

# Run the app
python3 web_app.py

# Open in browser
xdg-open http://localhost:5000
```

---

## Example Use Cases

### 1. Code Assistant

- Select: `mistral:latest` or `llama2:13b-chat`
- Prompt: "Write a Python function to..."
- Temperature: 0.3 (focused)

### 2. Creative Writing

- Select: `mixtral:8x7b-instruct`
- Prompt: "Write a short story about..."
- Temperature: 1.0 (creative)

### 3. Question Answering

- Select: `qwen2:7b-instruct`
- Prompt: "Explain how..."
- Temperature: 0.5 (balanced)

### 4. Translation

- Select: Any model
- Prompt: "Translate to Spanish: ..."
- Temperature: 0.2 (accurate)

### 5. Summarization

- Select: `mistral:latest`
- Prompt: "Summarize this text: ..."
- Temperature: 0.4 (focused)

---

## Files Created

1. **web-interface.html** - Simple HTML interface (no installation)
2. **web_app.py** - Flask web application (requires Flask)
3. **WEB_ACCESS_GUIDE.md** - This guide

---

## Next Steps

1. **Try the HTML interface first:**

   ```bash
   xdg-open web-interface.html
   ```

2. **Test with different models:**
   - Click each model to see how they respond
   - Compare response quality and speed

3. **Experiment with parameters:**
   - Try different temperature values
   - Enable/disable streaming
   - Adjust max tokens

4. **Install more models (optional):**
   ```bash
   ./install-models-safe.sh
   ```

---

## Support

If you encounter issues:

- Check that Ollama is running: `docker ps | grep ollama`
- Test API: `curl http://localhost:11434/api/tags`
- View logs: `docker logs ollama`
- Read: `API_ACCESS_GUIDE.md` for more details

---

## Summary

You now have two ways to access your LLM models via web browser:

1. **HTML Interface** - Open `web-interface.html` in your browser (easiest!)
2. **Flask App** - Run `python3 web_app.py` and visit http://localhost:5000

Both interfaces let you:

- Select any model with a click
- Chat with the model
- Adjust parameters
- View statistics
- Get real-time responses

**Start now:** Just open `web-interface.html` in your browser! 🚀
