# MIRMI-LLM Complete Setup Guide

This guide walks through setting up the entire MIRMI-LLM stack from scratch on a fresh Linux server.

---

## Table of Contents

1. [Server Requirements](#1-server-requirements)
2. [Install Dependencies](#2-install-dependencies)
3. [Clone the Project](#3-clone-the-project)
4. [Configure Environment](#4-configure-environment)
5. [Start Core Services](#5-start-core-services)
6. [Stable Diffusion Setup](#6-stable-diffusion-setup)
7. [Configure Image Generator in UI](#7-configure-image-generator-in-ui)
8. [HTTPS with Nginx](#8-https-with-nginx)
9. [Add LLM Models](#9-add-llm-models)
10. [Performance Tuning](#10-performance-tuning)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Server Requirements

| Component  | Minimum         | Recommended      |
| ---------- | --------------- | ---------------- |
| OS         | Ubuntu 20.04    | Ubuntu 22.04 LTS |
| CPU        | 4 cores         | 8+ cores         |
| RAM        | 16 GB           | 32 GB            |
| Disk       | 100 GB          | 500 GB SSD       |
| GPU        | NVIDIA 8GB VRAM | RTX 2080 / 3080+ |
| GPU Driver | 525+            | Latest           |

---

## 2. Install Dependencies

### Docker

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
```

### Docker Compose v2

```bash
sudo apt-get install docker-compose-plugin
docker compose version  # should show v2.x
```

### NVIDIA Container Toolkit (for GPU / Stable Diffusion)

```bash
# Add NVIDIA repo
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verify
docker run --rm --gpus all nvidia/cuda:12.0-base-ubuntu22.04 nvidia-smi
```

---

## 3. Clone the Project

```bash
git clone https://github.com/peymankhp/MIRMI-LLM-SD.git
cd MIRMI-LLM-SD
```

---

## 4. Configure Environment

```bash
cp .env.example .env
nano .env
```

Key variables to set:

```env
# Required — change this to a random secret
WEBUI_SECRET_KEY=your-random-secret-key-here

# Optional — set your domain
WEBUI_URL=https://your-domain.com

# Optional — OpenAI API key if using OpenAI models
OPENAI_API_KEY=sk-...
```

Generate a secure secret key:

```bash
openssl rand -hex 32
```

---

## 5. Start Core Services

```bash
docker compose up -d
```

This starts:

| Container    | Port  | Description       |
| ------------ | ----- | ----------------- |
| `mirmi-llm`  | 8080  | Main web UI + API |
| `ollama`     | 11434 | Local LLM runner  |
| `deepagents` | 8000  | DeepAgents API    |
| `redis`      | 6379  | Session store     |

Check all containers are running:

```bash
docker compose ps
```

Open `http://localhost:8080` — the first user to register becomes admin.

---

## 6. Stable Diffusion Setup

### Start the container

```bash
docker compose -f docker-compose-stable-diffusion.yaml up -d
```

The container downloads SD v1.5 (~4GB) on first run. Watch progress:

```bash
docker logs automatic1111 -f
# Ready when you see: "Running on local URL: http://0.0.0.0:7860"
# This takes 5-10 minutes on first run
```

### Connect to the same Docker network

```bash
docker network connect open-webui_default mirmi-llm
```

Verify connectivity:

```bash
docker exec mirmi-llm curl -s -o /dev/null -w "%{http_code}" http://automatic1111:7860/
# Should return: 200
```

### (Recommended) Download a better model

The default SD v1.5 produces basic results. **Realistic Vision v5.1** gives photorealistic output:

```bash
# Download to persistent volume (survives container restarts)
sudo wget -O \
  /var/lib/docker/volumes/$(basename $PWD)_automatic1111-data/_data/Stable-diffusion/realisticVision.safetensors \
  "https://civitai.com/api/download/models/130072"

# Copy into the running container
sudo docker cp \
  /var/lib/docker/volumes/$(basename $PWD)_automatic1111-data/_data/Stable-diffusion/realisticVision.safetensors \
  automatic1111:/opt/stable-diffusion-webui/models/Stable-diffusion/realisticVision.safetensors

# Refresh model list and switch
docker exec automatic1111 curl -s -X POST http://localhost:7860/sdapi/v1/refresh-checkpoints

docker exec automatic1111 curl -s -X POST http://localhost:7860/sdapi/v1/options \
  -H "Content-Type: application/json" \
  -d '{"sd_model_checkpoint":"realisticVision.safetensors","CLIP_stop_at_last_layers":2}'
```

---

## 7. Configure Image Generator in UI

Log in as admin at `http://localhost:8080`:

### Enable Image Generation

1. Click your avatar → **Admin Panel**
2. **Settings** → **Images**
3. Set:
   - Image Generation Engine: `AUTOMATIC1111`
   - AUTOMATIC1111 Base URL: `http://automatic1111:7860`
   - Image Size: `768x768`
   - Steps: `25`
4. Toggle **Enable Image Generation** → ON
5. Click **Save**

### Grant permission to users

1. **Admin Panel** → **Settings** → **Users**
2. Scroll to **Default User Permissions**
3. Under **Features** → enable **Image Generation**
4. Click **Save**

### Use the Image Generator

Users will see **Image Generator** in the left sidebar (between Search and IDE).

- Type a prompt and press **Enter**
- Click **Advanced options** for size, steps, count, negative prompt
- Generated images are saved to `/app/backend/data/uploads/` inside the container

**Tips for better results:**

```
# Good prompt structure:
a sunset over the ocean, photorealistic, 8k, RAW photo, sharp focus, cinematic lighting

# Negative prompt (paste into Advanced options):
cartoon, anime, sketch, ugly, blurry, low quality, deformed, watermark, text
```

---

## 8. HTTPS with Nginx

### Install Nginx and Certbot

```bash
sudo apt install nginx certbot python3-certbot-nginx -y
```

### Create Nginx config

```bash
sudo nano /etc/nginx/sites-available/mirmi-llm
```

Paste:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
        client_max_body_size 100M;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/mirmi-llm /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Get SSL certificate

```bash
sudo certbot --nginx -d your-domain.com
```

---

## 9. Add LLM Models

Pull models via Ollama:

```bash
# List available models
docker exec ollama ollama list

# Pull a model (examples)
docker exec ollama ollama pull llama3.2
docker exec ollama ollama pull mistral
docker exec ollama ollama pull codellama
docker exec ollama ollama pull llava  # multimodal (vision)
```

Or pull from the UI: **Admin Panel** → **Settings** → **Models** → pull by name.

---

## 10. Performance Tuning

### Stable Diffusion

The `docker-compose-stable-diffusion.yaml` is configured for best performance:

```yaml
WEBUI_FLAGS=--api --listen --port 7860 --xformers --opt-sdp-attention --no-half-vae
```

| Flag                  | Effect                                   |
| --------------------- | ---------------------------------------- |
| `--xformers`          | Memory-efficient attention (~30% faster) |
| `--opt-sdp-attention` | PyTorch scaled dot-product attention     |
| `--no-half-vae`       | Prevents VAE NaN/black image errors      |

> ⚠️ Do NOT add `--medvram` unless you have less than 6GB VRAM — it reduces speed by up to 28x.

### Recommended generation settings

| Setting   | Value           |
| --------- | --------------- |
| Sampler   | DPM++ 2M Karras |
| Steps     | 25–30           |
| CFG Scale | 7               |
| Size      | 768×768         |

### MIRMI-LLM

For multi-user deployments, scale workers in `docker-compose.yaml`:

```yaml
environment:
  - WEBUI_WORKERS=4
```

---

## 11. Troubleshooting

### Image generation shows "You do not have permission"

Two checks must pass:

1. Admin Panel → Settings → Images → Enable Image Generation must be ON
2. Admin Panel → Settings → Users → Default Permissions → Features → Image Generation must be ON

### "Connection refused" to Stable Diffusion

```bash
# Check both containers are on the same network
docker inspect mirmi-llm | grep -A5 Networks
docker inspect automatic1111 | grep -A5 Networks

# Fix: connect them
docker network connect open-webui_default mirmi-llm

# Test
docker exec mirmi-llm curl -s -o /dev/null -w "%{http_code}" http://automatic1111:7860/
```

### Save loops when enabling Image Generation

The backend verifies the URL on save. Make sure you use the container name:

- ✅ `http://automatic1111:7860`
- ❌ `http://127.0.0.1:7860` (only works on host, not inside Docker)

### Stable Diffusion model resets to v1.5 after restart

The model file inside the container is lost on restart. To persist it, copy it to the volume AND the container after each restart, or mount a host directory:

```yaml
# In docker-compose-stable-diffusion.yaml, add to volumes:
volumes:
  - /your/host/models:/opt/stable-diffusion-webui/models/Stable-diffusion
```

### Black or corrupted images

Add `--no-half-vae` to `WEBUI_FLAGS` in `docker-compose-stable-diffusion.yaml`.

### Check container logs

```bash
docker logs mirmi-llm --tail 50
docker logs automatic1111 --tail 50
docker logs ollama --tail 50
docker logs deepagents --tail 50
```

### Restart all services

```bash
docker compose restart
docker compose -f docker-compose-stable-diffusion.yaml restart
```

---

## File Structure

```
MIRMI-LLM-SD/
├── docker-compose.yaml                    # Core services
├── docker-compose-stable-diffusion.yaml   # Stable Diffusion
├── .env.example                           # Environment template
├── backend/
│   └── mirmi_llm/                         # FastAPI backend
│       └── routers/
│           └── images.py                  # Image generation API
├── src/
│   ├── lib/components/
│   │   └── layout/Sidebar.svelte          # Sidebar with Image Generator link
│   └── routes/(app)/
│       └── image-generator/
│           └── +page.svelte               # Image Generator page
├── deepagents/                            # DeepAgents service
├── README.md
└── SETUP.md                               # This file
```
