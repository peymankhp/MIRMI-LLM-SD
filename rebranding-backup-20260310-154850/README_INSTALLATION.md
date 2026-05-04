# Quick Start: Install Llama 3 & Qwen 2.5

## What I've Prepared for You

I've analyzed your MIRMI LLM setup and created a safe installation solution. Your project is running with Docker Compose, and I've corrected the approach from the instructions you received.

## The Problem with Original Instructions

The instructions you received were for manual `docker run` commands, but you're using `docker-compose`. Also:

- Your network is set to `internal: true` (completely isolated)
- Ollama port 11434 is NOT exposed to the host
- You have a host-level Ollama service running that will conflict

## My Solution

I've created an automated script that will:

1. ✅ Create full backups (docker-compose.yaml + all data)
2. ✅ Safely reconfigure your setup to expose Ollama API
3. ✅ Stop the conflicting host-level Ollama service
4. ✅ Install Llama 3 (8B) and Qwen 2.5 (7B)
5. ✅ Verify everything works
6. ✅ Provide rollback instructions if needed

## Installation (Recommended Method)

Simply run:

```bash
./install-models-safe.sh
```

The script will:

- Ask for confirmation before each major step
- Show you exactly what it's doing
- Create backups automatically
- Test everything after installation

**Time required:** 10-15 minutes (mostly downloading models)

## What You'll Get

After installation:

### MIRMI LLM

- Still accessible at `http://localhost:8081`
- New models appear in the dropdown automatically
- All existing data and models preserved

### Ollama API (for Cursor, etc.)

```
Base URL: http://localhost:11434/v1
API Key: ollama (or any value)
Models: llama3:8b, qwen2.5:7b, and all your existing models
```

### For Remote Access

```
Base URL: http://<your-server-ip>:11434/v1
Note: Configure firewall for security
```

## Files Created

1. **install-models-safe.sh** - Automated installation script (RECOMMENDED)
2. **INSTALLATION_GUIDE.md** - Detailed manual instructions
3. **backup-and-install-models.sh** - Alternative backup script

## Manual Installation (If You Prefer)

If you want to do it step-by-step manually, see `INSTALLATION_GUIDE.md` for detailed instructions.

## Key Changes to Your Setup

The script will modify your `docker-compose.yaml`:

1. Add port exposure for Ollama:

   ```yaml
   ports:
     - '11434:11434'
   ```

2. Change network from isolated to accessible:

   ```yaml
   networks:
     internal_net:
       driver: bridge
       internal: false # Changed from true
   ```

3. Stop host-level Ollama service to avoid conflicts

## Safety Features

- ✅ Full backup before any changes
- ✅ Preserves all existing data and models
- ✅ No downtime for MIRMI LLM
- ✅ Rollback instructions provided
- ✅ Verification tests after installation

## System Requirements Check

Your system:

- ✅ GPU: NVIDIA RTX 2080 SUPER (8GB VRAM) - Perfect for 8B models
- ✅ Disk: 167GB available - Enough for new models (~10GB needed)
- ✅ Existing models: Will be preserved

## Rollback (If Needed)

If something goes wrong, the script creates backups in `backups/<timestamp>/`:

```bash
# Quick rollback
docker-compose down
cp backups/<timestamp>/docker-compose.yaml ./
docker-compose up -d
```

Full restoration instructions are provided by the script.

## What About Llama 3.3 or Qwen 3?

The script installs:

- **Llama 3 (8B)** - Latest stable Llama 3 model
- **Qwen 2.5 (7B)** - Latest Qwen 2.5 model

Note: "Qwen 3" doesn't exist yet. Qwen 2.5 is the latest version (as of Feb 2026).

If you want different variants:

```bash
# After installation, you can add more models:
docker exec ollama ollama pull llama3:70b  # Larger version (needs more VRAM)
docker exec ollama ollama pull qwen2.5:14b  # Larger Qwen
docker exec ollama ollama list  # See all available
```

## Firewall Configuration (Optional)

If you want to access from other machines:

```bash
# Allow from specific IP
sudo ufw allow from 192.168.1.100 to any port 11434

# Allow from entire local network
sudo ufw allow from 192.168.1.0/24 to any port 11434

# Check status
sudo ufw status
```

## Testing After Installation

```bash
# Test API access
curl http://localhost:11434/api/tags

# Test model generation
curl http://localhost:11434/api/generate -d '{
  "model": "llama3:8b",
  "prompt": "Hello!",
  "stream": false
}'

# List all models
docker exec ollama ollama list
```

## Troubleshooting

If you encounter issues:

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Check Ollama specifically
docker logs ollama

# Verify network
docker network inspect open-webui_internal_net

# Test internal connectivity
docker exec open-webui curl http://ollama:11434/api/tags
```

## Support

If you need help:

1. Check the logs: `docker-compose logs -f`
2. Review `INSTALLATION_GUIDE.md` for detailed explanations
3. All backups are in `backups/<timestamp>/`

## Ready to Install?

Run the installation script:

```bash
./install-models-safe.sh
```

The script will guide you through each step and ask for confirmation before making changes.

---

**Note:** Your MIRMI LLM project will continue running normally throughout this process. The script is designed to be safe and non-disruptive.
