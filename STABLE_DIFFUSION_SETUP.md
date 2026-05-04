# Stable Diffusion Setup Guide

This guide covers setting up Stable Diffusion (AUTOMATIC1111) with MIRMI-LLM for the Image Generator feature.

---

## Requirements

- NVIDIA GPU with 8GB+ VRAM (tested on RTX 2080 SUPER)
- NVIDIA Container Toolkit installed on the host
- Docker Compose

---

## 1. Start the Stable Diffusion container

```bash
docker compose -f docker-compose-stable-diffusion.yaml up -d
```

The container will:

- Download the base SD v1.5 model on first run (~4GB, takes ~5 minutes)
- Start the WebUI with `--api` flag enabled
- Join the `open-webui_default` Docker network

Wait for it to be ready (check logs):

```bash
docker logs automatic1111 -f
# Ready when you see: "Running on local URL: http://0.0.0.0:7860"
```

---

## 2. (Recommended) Download a better model

The default SD v1.5 produces basic results. For photorealistic output, download **Realistic Vision v5.1**:

```bash
# Download directly into the persistent volume
sudo wget -O /var/lib/docker/volumes/open-webui_automatic1111-data/_data/Stable-diffusion/realisticVision.safetensors \
  "https://civitai.com/api/download/models/130072"

# Copy into the running container
sudo docker cp \
  /var/lib/docker/volumes/open-webui_automatic1111-data/_data/Stable-diffusion/realisticVision.safetensors \
  automatic1111:/opt/stable-diffusion-webui/models/Stable-diffusion/realisticVision.safetensors

# Refresh model list
docker exec automatic1111 curl -s -X POST http://localhost:7860/sdapi/v1/refresh-checkpoints

# Switch to the new model
docker exec automatic1111 curl -s -X POST http://localhost:7860/sdapi/v1/options \
  -H "Content-Type: application/json" \
  -d '{"sd_model_checkpoint":"realisticVision.safetensors","CLIP_stop_at_last_layers":2}'
```

---

## 3. Connect Docker networks

If MIRMI-LLM and Stable Diffusion are on different Docker networks, connect them:

```bash
docker network connect open-webui_default mirmi-llm
```

Verify connectivity:

```bash
docker exec mirmi-llm curl -s -o /dev/null -w "%{http_code}" http://automatic1111:7860/sdapi/v1/sd-models
# Should return: 200
```

---

## 4. Configure MIRMI-LLM

Log in as admin at `https://your-domain/`:

1. **Admin Panel → Settings → Images**
   - Image Generation Engine: `AUTOMATIC1111`
   - AUTOMATIC1111 Base URL: `http://automatic1111:7860`
   - Enable Image Generation: `ON`
   - Click **Save**

2. **Admin Panel → Settings → Users → Default User Permissions → Features**
   - Image Generation: `ON`
   - Click **Save**

---

## 5. Performance tuning

The container is configured with these flags for best performance on 8GB VRAM:

```
--api --listen --port 7860 --xformers --opt-sdp-attention --no-half-vae
```

| Flag                  | Effect                                   |
| --------------------- | ---------------------------------------- |
| `--xformers`          | Memory-efficient attention (~30% faster) |
| `--opt-sdp-attention` | PyTorch scaled dot-product attention     |
| `--no-half-vae`       | Prevents VAE NaN errors                  |
| ~~`--medvram`~~       | Removed — was limiting speed by 28x      |

**Recommended generation settings:**
| Setting | Value |
|---|---|
| Sampler | DPM++ 2M Karras |
| Steps | 25–30 |
| CFG Scale | 7 |
| Size | 768×768 |
| Negative prompt | `cartoon, anime, sketch, ugly, blurry, low quality, deformed, watermark, text` |

---

## 6. Verify everything works

```bash
# Test the API directly
docker exec automatic1111 curl -s -X POST http://localhost:7860/sdapi/v1/txt2img \
  -H "Content-Type: application/json" \
  -d '{"prompt":"a red apple, photorealistic","steps":20,"width":512,"height":512}' \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('OK, images:', len(d.get('images',[])))"
```

---

## Troubleshooting

**"Connection refused" from MIRMI-LLM to Stable Diffusion:**

```bash
# Check both containers are on the same network
docker inspect mirmi-llm | grep -A3 Networks
docker inspect automatic1111 | grep -A3 Networks
# If different, connect them:
docker network connect open-webui_default mirmi-llm
```

**"Enable Image Generation" save loops:**

- The backend tries to verify the URL on save
- Make sure the URL is `http://automatic1111:7860` (container name), not `http://127.0.0.1:7860`

**Slow generation (>30s per image):**

- Remove `--medvram` flag from `docker-compose-stable-diffusion.yaml`
- Add `--opt-sdp-attention`
- Restart: `docker compose -f docker-compose-stable-diffusion.yaml up -d --force-recreate`

**Model resets to v1.5 after restart:**

- Copy the model into the container after each restart (see step 2)
- Or mount a host directory as the models volume in `docker-compose-stable-diffusion.yaml`

---

## Generated images location

Images are saved inside the MIRMI-LLM container at:

```
/app/backend/data/uploads/*_generated-image.png
```

On the host (Docker volume):

```
/var/lib/docker/volumes/open-webui_mirmi-llm/_data/uploads/
```
