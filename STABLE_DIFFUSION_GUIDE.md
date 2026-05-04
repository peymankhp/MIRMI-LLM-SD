# Stable Diffusion Integration Guide for MIRMI LLM

## 🎨 Overview

This guide explains how to add Stable Diffusion v1.5 image generation to your MIRMI LLM without disrupting existing services.

## 📊 Your System

```
GPU:     RTX 2080 SUPER (8GB VRAM)
RAM:     32GB
Status:  Perfect for Stable Diffusion v1.5
```

### Performance Expectations

- **Image generation time:** 5-15 seconds per image
- **Resolution:** Up to 768x768 (recommended for 8GB VRAM)
- **Batch size:** 1-2 images at a time
- **Quality:** Excellent with SD v1.5

## 🚀 Quick Installation

### Option 1: Automated (Recommended)

```bash
sudo ./install-stable-diffusion.sh
```

**Time:** 15-30 minutes (mostly downloading model)  
**Downtime:** Zero (runs alongside existing services)

### Option 2: Manual Installation

See detailed steps below.

## 📋 What Gets Installed

1. **AUTOMATIC1111 Stable Diffusion WebUI**
   - Industry standard SD interface
   - Full API support
   - Compatible with MIRMI LLM

2. **Stable Diffusion v1.5 Model**
   - Size: ~4GB
   - Best balance of quality and speed
   - Proven and stable

3. **Docker Container**
   - Isolated from existing services
   - GPU accelerated
   - Auto-restart enabled

## 🔧 Manual Installation Steps

### Step 1: Create Docker Compose File

The file `docker-compose-stable-diffusion.yaml` is already created with:

- AUTOMATIC1111 WebUI
- GPU support
- API enabled
- Connected to your internal network

### Step 2: Start Stable Diffusion

```bash
# Start the service
docker-compose -f docker-compose-stable-diffusion.yaml up -d automatic1111

# Check status
docker ps | grep automatic1111

# View logs
docker logs automatic1111 --tail 50
```

### Step 3: Download SD v1.5 Model

```bash
# Download Stable Diffusion v1.5 (4GB)
docker exec automatic1111 bash -c "
cd /data/models/Stable-diffusion && \
wget -c https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors \
-O sd_v1-5-pruned-emaonly.safetensors
"
```

**Alternative models you can try:**

- SD v1.5 Inpainting: For image editing
- SD v2.1: Higher quality but slower
- Custom models from Civitai.com

### Step 4: Configure MIRMI LLM

1. **Access Admin Panel:**
   - Go to: https://mirmi-llm.mirmi.tum.de
   - Click your profile → Admin Panel

2. **Navigate to Image Settings:**
   - Settings → Images → Image Generation

3. **Configure Image Generation:**

   ```
   Image Generation Engine: AUTOMATIC1111
   OpenAI API Base URL: http://automatic1111:7860
   OpenAI API Key: (leave empty)
   ```

4. **Configure Image Editing (Optional):**

   ```
   Image Edit Engine: AUTOMATIC1111
   OpenAI API Base URL: http://automatic1111:7860
   OpenAI API Key: (leave empty)
   ```

5. **Click Save**

### Step 5: Test Image Generation

**In MIRMI LLM chat:**

```
Generate an image of a beautiful sunset over mountains
```

Or use the image generation button in the chat interface.

## 🎯 Configuration Options

### For Your RTX 2080 SUPER (8GB VRAM)

**Recommended settings in AUTOMATIC1111:**

```yaml
CLI_ARGS: >
  --api 
  --listen 
  --port 7860 
  --medvram          # Optimize for 8GB VRAM
  --xformers         # Memory efficient attention
  --no-half-vae      # Better quality
  --enable-insecure-extension-access
```

### Image Generation Parameters

**In MIRMI LLM, you can specify:**

- **Size:** 512x512 (fast), 768x768 (balanced), 1024x1024 (slow)
- **Steps:** 20-30 (good quality), 50+ (best quality)
- **CFG Scale:** 7-12 (how closely to follow prompt)
- **Sampler:** Euler a, DPM++ 2M Karras (recommended)

### Example Prompts

**Good prompts:**

```
a beautiful landscape with mountains and a lake, sunset, highly detailed, 8k, photorealistic

portrait of a cat wearing a hat, studio lighting, professional photography, sharp focus

futuristic city at night, neon lights, cyberpunk style, detailed architecture
```

**Negative prompts (what to avoid):**

```
blurry, low quality, distorted, ugly, bad anatomy, watermark
```

## 📊 Architecture

### Before Adding Stable Diffusion

```
┌─────────────────────────────────────┐
│  MIRMI LLM (port 8080)             │
│  ↓                                   │
│  Ollama (LLMs)                      │
└─────────────────────────────────────┘
```

### After Adding Stable Diffusion

```
┌─────────────────────────────────────┐
│  MIRMI LLM (port 8080)             │
│  ↓                    ↓              │
│  Ollama (LLMs)    Stable Diffusion  │
│                   (port 7860)        │
└─────────────────────────────────────┘
```

Both services run independently on the same internal network.

## 🔍 Verification & Testing

### Check Service Status

```bash
# Check if running
docker ps | grep automatic1111

# Check GPU usage
nvidia-smi

# Check logs
docker logs automatic1111 --tail 50

# Test API
curl http://localhost:7860/sdapi/v1/sd-models
```

### Test Image Generation via API

```bash
# Generate a test image
curl -X POST http://localhost:7860/sdapi/v1/txt2img \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "a beautiful sunset",
    "steps": 20,
    "width": 512,
    "height": 512
  }'
```

### Access Web Interface (Optional)

```bash
# Create SSH tunnel from your computer
ssh -L 7860:localhost:7860 mirmi@10.157.174.177

# Then open in browser
http://localhost:7860
```

## 💡 Usage Tips

### For Best Results

1. **Use descriptive prompts:**
   - Good: "a red sports car on a mountain road, sunset, photorealistic"
   - Bad: "car"

2. **Add quality keywords:**
   - "highly detailed", "8k", "professional", "sharp focus"

3. **Use negative prompts:**
   - "blurry, low quality, distorted, ugly"

4. **Adjust settings:**
   - Start with 512x512 for speed
   - Use 20-30 steps for good quality
   - CFG scale 7-12 for balanced results

### For Your 8GB VRAM

**Optimal settings:**

- Resolution: 512x512 or 768x768
- Batch size: 1
- Steps: 20-30
- Use `--medvram` flag (already configured)

**Avoid:**

- Resolution above 1024x1024
- Batch size > 2
- Multiple simultaneous generations

## 🔧 Troubleshooting

### Issue: Service won't start

**Check:**

```bash
# View logs
docker logs automatic1111

# Check GPU
nvidia-smi

# Check port
netstat -tlnp | grep 7860
```

**Fix:**

```bash
# Restart service
docker-compose -f docker-compose-stable-diffusion.yaml restart automatic1111
```

### Issue: Out of memory errors

**Solution:**

```bash
# Edit docker-compose-stable-diffusion.yaml
# Add to CLI_ARGS: --lowvram

# Restart
docker-compose -f docker-compose-stable-diffusion.yaml restart automatic1111
```

### Issue: Slow generation

**Causes:**

- Resolution too high
- Too many steps
- Other processes using GPU

**Solutions:**

- Reduce resolution to 512x512
- Use 20 steps instead of 50
- Close other GPU applications
- Check: `nvidia-smi`

### Issue: MIRMI LLM can't connect

**Check:**

```bash
# Are they on same network?
docker network inspect mirmi-llm_internal_net

# Test connectivity
docker exec mirmi-llm curl http://automatic1111:7860
```

**Fix:**

```bash
# Ensure both containers on same network
docker-compose -f docker-compose-stable-diffusion.yaml restart
```

## 📈 Performance Optimization

### For RTX 2080 SUPER (8GB)

**Fast mode (5-8 seconds):**

```
Resolution: 512x512
Steps: 20
Sampler: Euler a
```

**Balanced mode (10-15 seconds):**

```
Resolution: 768x768
Steps: 30
Sampler: DPM++ 2M Karras
```

**Quality mode (20-30 seconds):**

```
Resolution: 768x768
Steps: 50
Sampler: DPM++ 2M Karras
CFG Scale: 10
```

## 🎨 Advanced Features

### Image-to-Image

Generate variations of existing images:

1. Upload an image in MIRMI LLM
2. Describe desired changes
3. Adjust denoising strength (0.3-0.7)

### Inpainting

Edit specific parts of images:

1. Upload image
2. Mark area to edit
3. Describe what to generate

### ControlNet (Advanced)

For precise control over composition:

- Requires additional models
- More VRAM needed
- See AUTOMATIC1111 documentation

## 🔒 Security Considerations

### Network Isolation

Stable Diffusion runs on your internal network:

- ✅ No internet access (same as Ollama)
- ✅ Only accessible from local network
- ✅ Isolated from external threats

### Resource Usage

Monitor GPU and RAM:

```bash
# GPU usage
nvidia-smi

# Container resources
docker stats automatic1111
```

## 📊 Model Management

### Installed Models Location

```bash
# Models directory
docker exec automatic1111 ls /data/models/Stable-diffusion/

# Add new models
docker cp model.safetensors automatic1111:/data/models/Stable-diffusion/
```

### Recommended Additional Models

1. **Realistic Vision** - Photorealistic images
2. **DreamShaper** - Artistic style
3. **Anything V5** - Anime/illustration style

Download from: https://civitai.com

## 🔄 Maintenance

### Update Stable Diffusion

```bash
# Pull latest image
docker pull universonic/stable-diffusion-webui:latest

# Restart with new image
docker-compose -f docker-compose-stable-diffusion.yaml up -d automatic1111
```

### Backup Models

```bash
# Backup models directory
docker cp automatic1111:/data/models ./stable-diffusion-models-backup
```

### Clean Up Old Images

```bash
# Remove old generated images
docker exec automatic1111 rm -rf /output/txt2img-images/*
```

## 📝 Integration with MIRMI LLM

### How It Works

1. User requests image in MIRMI LLM
2. MIRMI LLM sends request to Stable Diffusion API
3. Stable Diffusion generates image
4. Image returned to MIRMI LLM
5. User sees image in chat

### API Endpoints Used

- `/sdapi/v1/txt2img` - Text to image
- `/sdapi/v1/img2img` - Image to image
- `/sdapi/v1/sd-models` - List models
- `/sdapi/v1/options` - Get/set options

## ✅ Success Checklist

- [ ] Stable Diffusion container running
- [ ] SD v1.5 model downloaded
- [ ] API responding on port 7860
- [ ] MIRMI LLM configured
- [ ] Test image generated successfully
- [ ] GPU being utilized
- [ ] No errors in logs

## 🎉 You're Ready!

Your MIRMI LLM now has image generation capabilities!

**Test it:**

1. Go to https://mirmi-llm.mirmi.tum.de
2. In chat, type: "Generate an image of a sunset"
3. Wait 10-15 seconds
4. Enjoy your AI-generated image!

---

## 📞 Support

**Check status:**

```bash
docker ps | grep automatic1111
docker logs automatic1111 --tail 50
```

**Restart if needed:**

```bash
docker-compose -f docker-compose-stable-diffusion.yaml restart automatic1111
```

**Remove if needed:**

```bash
docker-compose -f docker-compose-stable-diffusion.yaml down
docker volume rm automatic1111-data automatic1111-output
```
