# Open WebUI LLM Not Responding - NGINX Fix Guide

## 🔍 Problem Identified

Your Open WebUI panel loads correctly at `https://mirmi-llm.mirmi.tum.de`, but the LLMs don't respond when you send messages.

### Root Cause

The nginx configuration is **missing WebSocket support**, which is critical for Open WebUI's real-time communication. The logs show repeated errors:

```
GET /ws/socket.io/?EIO=4&transport=websocket HTTP/1.0" 400
```

This means WebSocket connections are being rejected, preventing the UI from communicating with the LLM backend.

## ✅ What's Working

- ✅ Open WebUI container is running and healthy
- ✅ Ollama is running with 9 models loaded
- ✅ Internal connectivity works (container can reach Ollama)
- ✅ HTTPS is configured correctly
- ✅ The web panel loads successfully

## ❌ What's Broken

- ❌ WebSocket connections fail (HTTP 400 errors)
- ❌ No `Upgrade` header in nginx config
- ❌ No `Connection "upgrade"` header
- ❌ Buffering enabled (blocks streaming responses)
- ❌ Short timeouts (may cut off long LLM responses)

## 🔧 The Fix

### Quick Fix (Recommended)

Run the automated fix script:

```bash
sudo ./fix-nginx.sh
```

This will:
1. Backup your current nginx configuration
2. Apply the fixed configuration with WebSocket support
3. Test the configuration
4. Reload nginx
5. Verify everything works

**Time:** 10 seconds

### Manual Fix

If you prefer to fix it manually:

1. **Backup current config:**
   ```bash
   sudo cp /etc/nginx/sites-available/openwebui /etc/nginx/sites-available/openwebui.backup
   ```

2. **Apply the fix:**
   ```bash
   sudo cp nginx-openwebui-fixed.conf /etc/nginx/sites-available/openwebui
   ```

3. **Test configuration:**
   ```bash
   sudo nginx -t
   ```

4. **Reload nginx:**
   ```bash
   sudo systemctl reload nginx
   ```

## 📋 What Changed

### Before (Broken)
```nginx
location / {
    proxy_pass http://10.157.174.177:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

### After (Fixed)
```nginx
location / {
    proxy_pass http://10.157.174.177:8080;
    proxy_http_version 1.1;
    
    # WebSocket support - CRITICAL
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    # Standard headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Key Additions

1. **WebSocket Support:**
   - `proxy_http_version 1.1` - Required for WebSocket
   - `Upgrade $http_upgrade` - Enables protocol upgrade
   - `Connection "upgrade"` - Maintains persistent connection

2. **Streaming Optimization:**
   - `proxy_buffering off` - Disables buffering for real-time streaming
   - `proxy_cache off` - Prevents caching of API responses

3. **Timeout Increases:**
   - `proxy_read_timeout 600s` - Allows 10 minutes for LLM generation
   - `proxy_connect_timeout 600s` - Connection timeout
   - `proxy_send_timeout 600s` - Send timeout

4. **Dedicated WebSocket Endpoint:**
   - Explicit `/ws/` location block
   - Extended timeouts (3600s = 1 hour)
   - Optimized for long-running connections

## 🧪 Testing After Fix

### 1. Check nginx status
```bash
sudo systemctl status nginx
```

### 2. Test WebSocket connection
Open browser console (F12) at `https://mirmi-llm.mirmi.tum.de` and check for:
- ✅ No WebSocket errors
- ✅ Connection established messages

### 3. Test LLM response
1. Open: https://mirmi-llm.mirmi.tum.de
2. Select a model: `mistral:latest` or `llama2:7b-chat`
3. Send a simple message: "Hello, how are you?"
4. You should see a streaming response appear word-by-word

### 4. Check logs
```bash
# Should show successful WebSocket connections
docker logs open-webui --tail 20

# Should show no more 400 errors on /ws/ endpoints
sudo tail -f /var/log/nginx/access.log
```

## 📊 Your Current Setup

- **Domain:** https://mirmi-llm.mirmi.tum.de
- **Open WebUI:** Running on 10.157.174.177:8080 (container IP: 172.18.0.3)
- **Ollama:** Running with 9 models
- **SSL:** Let's Encrypt certificate (valid)
- **Nginx:** Version 1.18.0 (Ubuntu)

### Available Models
- mistral:latest (4.4 GB)
- llama2:7b-chat (3.8 GB)
- llama2:13b-chat (7.4 GB)
- qwen2:7b-instruct (4.4 GB)
- mixtral:8x7b-instruct (26 GB)
- vicuna:7b (3.8 GB)
- falcon:7b-instruct (4.2 GB)
- And more...

## 🔄 Rollback (If Needed)

If something goes wrong:

```bash
# Restore backup
sudo cp /etc/nginx/sites-available/openwebui.backup /etc/nginx/sites-available/openwebui

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

## 🔍 Troubleshooting

### Issue: Still getting 400 errors

**Check:**
```bash
# Verify the config was applied
sudo cat /etc/nginx/sites-available/openwebui | grep -A 2 "Upgrade"

# Should show:
# proxy_set_header Upgrade $http_upgrade;
# proxy_set_header Connection "upgrade";
```

**Fix:**
```bash
# Reload nginx again
sudo systemctl reload nginx

# Or restart if reload doesn't work
sudo systemctl restart nginx
```

### Issue: LLM responds but very slowly

**Possible causes:**
- GPU not being used (check with `nvidia-smi`)
- Model too large for VRAM
- Multiple models loaded simultaneously

**Solutions:**
```bash
# Check GPU usage
nvidia-smi

# Restart Ollama to free memory
docker restart ollama

# Use smaller models (7B instead of 13B)
```

### Issue: Connection timeout

**Increase timeouts further:**
Edit `/etc/nginx/sites-available/openwebui` and change:
```nginx
proxy_read_timeout 1200s;  # 20 minutes
```

Then reload:
```bash
sudo systemctl reload nginx
```

## 📝 Technical Details

### Why WebSocket is Required

Open WebUI uses WebSocket for:
1. **Real-time streaming** - LLM responses appear word-by-word
2. **Bidirectional communication** - UI can send/receive simultaneously
3. **Connection persistence** - Maintains state during long generations
4. **Event notifications** - Model loading, progress updates

Without WebSocket:
- ❌ Streaming doesn't work
- ❌ UI appears frozen
- ❌ No real-time feedback
- ❌ Connection drops during generation

### HTTP vs WebSocket

**HTTP (old config):**
- Request → Response → Close
- No streaming
- New connection for each message

**WebSocket (new config):**
- Request → Upgrade → Persistent Connection
- Bidirectional streaming
- Single connection for entire session

## 🎯 Expected Behavior After Fix

### Before Fix
1. Type message → Send
2. UI shows "thinking" animation
3. Nothing happens (WebSocket fails)
4. Eventually timeout or error

### After Fix
1. Type message → Send
2. UI shows "thinking" animation
3. Response starts appearing word-by-word
4. Complete response displayed
5. Ready for next message

## 🔒 Security Notes

The fixed configuration maintains all security features:
- ✅ HTTPS with Let's Encrypt
- ✅ Proper forwarding headers
- ✅ No exposed internal IPs
- ✅ Timeout limits prevent abuse
- ✅ No unnecessary ports opened

## 📞 Support

If you still have issues after applying the fix:

1. **Check logs:**
   ```bash
   docker logs open-webui --tail 50
   sudo tail -f /var/log/nginx/error.log
   ```

2. **Verify connectivity:**
   ```bash
   # From inside container
   docker exec open-webui curl -s http://ollama:11434/api/tags
   
   # From host
   curl -s http://10.157.174.177:8080/health
   ```

3. **Test WebSocket directly:**
   ```bash
   # Install websocat if needed
   # sudo apt install websocat
   
   websocat wss://mirmi-llm.mirmi.tum.de/ws/socket.io/
   ```

## ✅ Summary

**Problem:** LLMs not responding due to missing WebSocket support in nginx

**Solution:** Apply fixed nginx configuration with WebSocket headers

**Command:** `sudo ./fix-nginx.sh`

**Result:** LLMs will respond with streaming text in real-time

**Time:** 10 seconds to fix

---

**Ready to fix it?** Run: `sudo ./fix-nginx.sh`
