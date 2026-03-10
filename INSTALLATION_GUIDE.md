# Safe Installation Guide: Llama 3 & Qwen 2.5 with API Access

## Current Setup Analysis

Your Open WebUI is running with:
- **Docker Compose** deployment (not manual docker run)
- **Internal network** (`internal: true`) - isolated from host
- **No port exposure** for Ollama container
- **Host-level Ollama service** running on port 11434
- **GPU**: NVIDIA RTX 2080 SUPER (8GB VRAM)
- **Existing models**: qwen2:7b-instruct, llama2:13b-chat, mixtral:8x7b, and others

## Problem with the Provided Instructions

The instructions you received assume manual `docker run` commands, but you're using `docker-compose`. The key issues:

1. Your network is `internal: true` - completely isolated
2. Ollama port 11434 is NOT exposed to host
3. Host-level Ollama service conflicts with container

## Safe Solution

### Option 1: Expose Ollama API (Recommended)

This allows both Open WebUI and external tools (like Cursor) to use the same Ollama instance.

**Pros:**
- Single Ollama instance
- No model duplication
- External API access
- Clean architecture

**Cons:**
- Requires network reconfiguration
- Need to manage firewall rules

### Option 2: Keep Current Setup + Use Host Ollama

Use the existing host-level Ollama for external API access.

**Pros:**
- No changes to Open WebUI
- Simpler setup

**Cons:**
- Two separate Ollama instances
- Models duplicated (uses more disk space)
- More resource usage

## Recommended: Option 1 Implementation

### Step 1: Create Backup

```bash
# Create backup directory
mkdir -p backups/$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"

# Backup docker-compose.yaml
cp docker-compose.yaml "$BACKUP_DIR/"

# Backup Open WebUI data
docker run --rm -v open-webui:/data -v "$(pwd)/$BACKUP_DIR":/backup alpine tar czf /backup/open-webui-data.tar.gz -C /data .

# Backup Ollama models (large, may take time)
docker run --rm -v ollama:/data -v "$(pwd)/$BACKUP_DIR":/backup alpine tar czf /backup/ollama-models.tar.gz -C /data .

echo "Backup completed: $BACKUP_DIR"
```

### Step 2: Update docker-compose.yaml

Modify your `docker-compose.yaml`:

```yaml
services:
  ollama:
    image: ollama/ollama:${OLLAMA_DOCKER_TAG-latest}
    container_name: ollama
    pull_policy: always
    tty: true
    restart: unless-stopped
    volumes:
      - ollama:/root/.ollama
    ports:
      - "11434:11434"  # ADD THIS LINE
    networks:
      - internal_net

  open-webui:
    build:
      context: .
      dockerfile: Dockerfile
    image: ghcr.io/open-webui/open-webui:${WEBUI_DOCKER_TAG-main}
    container_name: open-webui
    volumes:
      - open-webui:/app/backend/data
    depends_on:
      - ollama
    ports:
      - "127.0.0.1:8081:8080"
    environment:
      - 'OLLAMA_BASE_URL=http://ollama:11434'
      - 'WEBUI_SECRET_KEY='
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped
    networks:
      - internal_net

volumes:
  ollama: {}
  open-webui: {}

networks:
  internal_net:
    driver: bridge
    internal: false  # CHANGE THIS FROM true TO false
```

### Step 3: Stop Host-Level Ollama (Avoid Conflicts)

```bash
# Check if running
systemctl status ollama

# Stop and disable
sudo systemctl stop ollama
sudo systemctl disable ollama
```

### Step 4: Recreate Containers

```bash
# Recreate with new configuration
docker-compose up -d

# Wait for services to start
sleep 10

# Verify Ollama is accessible
curl http://localhost:11434/api/tags
```

### Step 5: Install Models

```bash
# Install Llama 3 (8B model, ~4.7GB)
docker exec -it ollama ollama pull llama3:8b

# Install Qwen 2.5 (7B model, ~4.7GB)
docker exec -it ollama ollama pull qwen2.5:7b

# Verify installation
docker exec ollama ollama list
```

### Step 6: Test API Access

```bash
# Test from host
curl http://localhost:11434/api/tags

# Test model generation
curl http://localhost:11434/api/generate -d '{
  "model": "llama3:8b",
  "prompt": "Hello, world!",
  "stream": false
}'
```

## Configuration for External Tools (Cursor, etc.)

### Local Machine Access
```
Base URL: http://localhost:11434/v1
API Key: ollama (or any value)
Models:
  - llama3:8b
  - qwen2.5:7b
  - qwen2:7b-instruct
  - (all your existing models)
```

### Remote Machine Access
```
Base URL: http://<your-server-ip>:11434/v1
API Key: ollama (or any value)

Note: Configure firewall to allow port 11434 from trusted IPs only
```

### Firewall Configuration (if needed)

```bash
# Allow from specific IP
sudo ufw allow from <trusted-ip> to any port 11434

# Or allow from local network only
sudo ufw allow from 192.168.1.0/24 to any port 11434

# Check status
sudo ufw status
```

## Rollback Instructions

If something goes wrong:

```bash
# Stop containers
docker-compose down

# Remove volumes
docker volume rm open-webui ollama

# Restore from backup
BACKUP_DIR="backups/<your-backup-timestamp>"
docker run --rm -v open-webui:/data -v "$(pwd)/$BACKUP_DIR":/backup alpine tar xzf /backup/open-webui-data.tar.gz -C /data
docker run --rm -v ollama:/data -v "$(pwd)/$BACKUP_DIR":/backup alpine tar xzf /backup/ollama-models.tar.gz -C /data

# Restore docker-compose.yaml
cp "$BACKUP_DIR/docker-compose.yaml" ./

# Start containers
docker-compose up -d
```

## GPU Memory Considerations

Your RTX 2080 SUPER has 8GB VRAM. Model memory usage:
- llama3:8b: ~5GB VRAM
- qwen2.5:7b: ~4.5GB VRAM
- mixtral:8x7b: ~24GB VRAM (will use CPU/RAM fallback)

You can run one 8B model at a time comfortably. For concurrent usage, Ollama will automatically manage memory.

## Alternative: Option 2 (Simpler but Less Efficient)

If you want to avoid reconfiguring Open WebUI:

1. Keep current docker-compose setup unchanged
2. Use host-level Ollama for external API access
3. Install models on host Ollama:
   ```bash
   ollama pull llama3:8b
   ollama pull qwen2.5:7b
   ```
4. Configure external tools to use `http://localhost:11434/v1`

**Downside**: Models will be duplicated between container and host, using ~10GB extra disk space per model.

## Verification Checklist

After installation:
- [ ] Open WebUI accessible at http://localhost:8081
- [ ] Open WebUI shows new models in dropdown
- [ ] Ollama API responds: `curl http://localhost:11434/api/tags`
- [ ] Can generate text with new models
- [ ] External tools can connect to API
- [ ] No port conflicts (check `sudo netstat -tlnp | grep 11434`)

## Support

If you encounter issues:
1. Check container logs: `docker-compose logs -f`
2. Check Ollama logs: `docker logs ollama`
3. Verify network: `docker network inspect open-webui_internal_net`
4. Test connectivity: `docker exec open-webui curl http://ollama:11434/api/tags`
