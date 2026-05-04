# Architecture Changes: Before & After

## Current Setup (BEFORE)

```
┌─────────────────────────────────────────────────────────┐
│ Host System (Ubuntu)                                    │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Host Ollama Service (systemd)                    │  │
│  │ Port: 11434 (localhost only)                     │  │
│  │ Status: RUNNING ⚠️                                │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Docker: mirmi-llm_internal_net                  │  │
│  │ Type: INTERNAL (isolated) ⚠️                      │  │
│  │                                                    │  │
│  │  ┌─────────────────┐    ┌──────────────────┐    │  │
│  │  │ mirmi-llm      │───▶│ ollama           │    │  │
│  │  │ Port: 8081→8080 │    │ Port: 11434      │    │  │
│  │  │ (localhost only)│    │ (internal only)  │    │  │
│  │  └─────────────────┘    └──────────────────┘    │  │
│  │                                                    │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ❌ External tools CANNOT access container Ollama       │
│  ❌ Port 11434 conflict between host and container      │
│  ❌ Models would need to be duplicated                  │
└─────────────────────────────────────────────────────────┘
```

## New Setup (AFTER)

```
┌─────────────────────────────────────────────────────────┐
│ Host System (Ubuntu)                                    │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Host Ollama Service                               │  │
│  │ Status: STOPPED & DISABLED ✅                      │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Docker: mirmi-llm_internal_net                  │  │
│  │ Type: BRIDGE (accessible) ✅                       │  │
│  │                                                    │  │
│  │  ┌─────────────────┐    ┌──────────────────┐    │  │
│  │  │ mirmi-llm      │───▶│ ollama           │    │  │
│  │  │ Port: 8081→8080 │    │ Port: 11434→11434│◀───┼──┼─ External Access ✅
│  │  │ (localhost only)│    │ (exposed)        │    │  │
│  │  └─────────────────┘    └──────────────────┘    │  │
│  │                                                    │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ✅ External tools CAN access Ollama API                │
│  ✅ No port conflicts                                   │
│  ✅ Single model storage (no duplication)               │
└─────────────────────────────────────────────────────────┘

External Tools (Cursor, etc.)
      │
      └──▶ http://localhost:11434/v1
           or
           http://<server-ip>:11434/v1
```

## What Changes?

### docker-compose.yaml Changes

#### BEFORE:

```yaml
services:
  ollama:
    # ... other config ...
    networks:
      - internal_net
    # ❌ No ports exposed

networks:
  internal_net:
    driver: bridge
    internal: true # ❌ Isolated network
```

#### AFTER:

```yaml
services:
  ollama:
    # ... other config ...
    ports:
      - '11434:11434' # ✅ Port exposed to host
    networks:
      - internal_net

networks:
  internal_net:
    driver: bridge
    internal: false # ✅ Accessible network
```

## Access Patterns

### MIRMI LLM Access (Unchanged)

```
Browser → http://localhost:8081 → MIRMI LLM Container → Ollama Container
```

### External API Access (NEW)

```
Cursor/Other Tools → http://localhost:11434/v1 → Ollama Container
```

### Remote API Access (NEW, Optional)

```
Remote Machine → http://<server-ip>:11434/v1 → Ollama Container
                 (requires firewall configuration)
```

## Models After Installation

```
Ollama Container Models:
├── llama3:8b              ← NEW (4.7GB)
├── qwen2.5:7b             ← NEW (4.7GB)
├── qwen2:7b-instruct      ← EXISTING
├── llama2:13b-chat        ← EXISTING
├── llama2:7b-chat         ← EXISTING
├── mixtral:8x7b-instruct  ← EXISTING
├── mistral:7b-instruct    ← EXISTING
├── vicuna:7b              ← EXISTING
└── falcon:7b-instruct     ← EXISTING

Total New Download: ~9.4GB
Total Storage After: ~60GB (all models)
```

## Security Considerations

### Current (BEFORE)

- ✅ Ollama completely isolated (very secure)
- ❌ Cannot use API externally

### New (AFTER)

- ✅ Ollama accessible on localhost (secure for local use)
- ⚠️ Can be accessed from network (configure firewall!)
- ✅ Still isolated from internet (bound to localhost by default)

### Recommended Firewall Rules

```bash
# Allow only from specific trusted IPs
sudo ufw allow from 192.168.1.100 to any port 11434

# Or allow from local network only
sudo ufw allow from 192.168.1.0/24 to any port 11434

# Check what's allowed
sudo ufw status
```

## Resource Usage

### GPU Memory (RTX 2080 SUPER - 8GB VRAM)

```
Single Model Usage:
├── llama3:8b          → ~5GB VRAM    ✅ Fits comfortably
├── qwen2.5:7b         → ~4.5GB VRAM  ✅ Fits comfortably
├── llama2:13b         → ~7GB VRAM    ✅ Fits (tight)
└── mixtral:8x7b       → ~24GB VRAM   ⚠️ Uses CPU fallback

Concurrent Usage:
└── Ollama automatically manages memory
    └── Unloads inactive models to fit new requests
```

### Disk Space

```
Current Usage: 267GB / 457GB (58%)
New Models:    ~9.4GB
After Install: ~276GB / 457GB (60%)
Remaining:     ~167GB available ✅
```

## API Compatibility

The Ollama API is OpenAI-compatible, so you can use it with:

```javascript
// OpenAI SDK
const openai = new OpenAI({
  baseURL: 'http://localhost:11434/v1',
  apiKey: 'ollama' // Can be anything
});

// Cursor Configuration
{
  "baseURL": "http://localhost:11434/v1",
  "apiKey": "ollama",
  "model": "llama3:8b"
}

// cURL
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3:8b",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Rollback Plan

If anything goes wrong:

```bash
# 1. Stop containers
docker-compose down

# 2. Restore configuration
cp backups/<timestamp>/docker-compose.yaml ./

# 3. Restore data (if needed)
docker volume rm mirmi-llm ollama
docker run --rm -v mirmi-llm:/data \
  -v $(pwd)/backups/<timestamp>:/backup alpine \
  tar xzf /backup/mirmi-llm-data.tar.gz -C /data

docker run --rm -v ollama:/data \
  -v $(pwd)/backups/<timestamp>:/backup alpine \
  tar xzf /backup/ollama-models.tar.gz -C /data

# 4. Restart
docker-compose up -d
```

## Testing Checklist

After installation, verify:

- [ ] MIRMI LLM accessible: `http://localhost:8081`
- [ ] New models appear in MIRMI LLM dropdown
- [ ] Ollama API responds: `curl http://localhost:11434/api/tags`
- [ ] Can generate text: `curl http://localhost:11434/api/generate -d '{"model":"llama3:8b","prompt":"Hi"}'`
- [ ] No port conflicts: `sudo netstat -tlnp | grep 11434`
- [ ] Containers healthy: `docker-compose ps`
- [ ] GPU accessible: `docker exec ollama nvidia-smi`

## Summary

| Aspect        | Before              | After                |
| ------------- | ------------------- | -------------------- |
| Network Type  | Internal (isolated) | Bridge (accessible)  |
| Ollama Port   | Not exposed         | Exposed (11434)      |
| Host Ollama   | Running (conflict)  | Stopped              |
| External API  | ❌ Not possible     | ✅ Available         |
| MIRMI LLM     | ✅ Working          | ✅ Working           |
| Security      | Very high           | High (with firewall) |
| Model Storage | Single location     | Single location      |
| GPU Access    | ✅ Available        | ✅ Available         |

The changes are minimal but enable full API access while maintaining security and functionality.
