# Open WebUI Image Generation - Complete Settings Guide

## 📍 Location in Open WebUI

1. Go to: **https://mirmi-llm.mirmi.tum.de**
2. Login as admin
3. Click profile icon → **Admin Panel**
4. Navigate to: **Settings → Images**

---

## 🎨 IMAGE GENERATION SETTINGS

### Create Image Section

#### **Image Generation Engine**
```
AUTOMATIC1111
```
Select from dropdown: AUTOMATIC1111

#### **AUTOMATIC1111 Base URL**
```
http://automatic1111:7860
```
**Important:** 
- Use `automatic1111` (container name) not `localhost`
- Port is `7860`
- No trailing slash
- The `--api` flag is already included in the container startup

#### **AUTOMATIC1111 Api Auth String**
```
(leave empty)
```
**Why:** We're not using authentication for internal network access. If you want to add auth later, you would enter: `username:password`

#### **Model** (Optional)
```
sd_v1-5-pruned-emaonly.safetensors
```
Or leave empty to use default model

#### **Image Size** (Optional)
```
512x512
```
Recommended sizes for RTX 2080 SUPER:
- `512x512` - Fast (5-8 seconds)
- `768x768` - Balanced (10-15 seconds)
- `1024x1024` - Slow (20-30 seconds)

#### **Steps** (Optional)
```
30
```
Recommended:
- `20` - Fast
- `30` - Balanced (recommended)
- `50` - High quality

#### **Additional Parameters** (Optional)
```json
{
  "cfg_scale": 7,
  "sampler_name": "DPM++ 2M Karras",
  "negative_prompt": "blurry, low quality, distorted, ugly, bad anatomy, watermark"
}
```

---

## ✏️ IMAGE EDIT SETTINGS

### Edit Image Section

#### **Image Edit Engine**
```
AUTOMATIC1111
```

#### **AUTOMATIC1111 Base URL**
```
http://automatic1111:7860
```
Same as above

#### **Model** (Optional)
```
sd_v1-5-pruned-emaonly.safetensors
```

#### **Image Size** (Optional)
```
512x512
```

---

## 📋 COMPLETE CONFIGURATION CHECKLIST

### Required Fields (Must Fill)
- [x] Image Generation Engine: `AUTOMATIC1111`
- [x] AUTOMATIC1111 Base URL: `http://automatic1111:7860`

### Optional Fields (Can Leave Empty)
- [ ] AUTOMATIC1111 Api Auth String: (empty for no auth)
- [ ] Model: (uses default if empty)
- [ ] Image Size: (uses 512x512 if empty)
- [ ] Steps: (uses 20 if empty)
- [ ] Additional Parameters: (uses defaults if empty)

---

## 🎯 RECOMMENDED CONFIGURATION

### For Your RTX 2080 SUPER (8GB VRAM)

**Fast Mode (5-8 seconds per image):**
```
Image Generation Engine: AUTOMATIC1111
AUTOMATIC1111 Base URL: http://automatic1111:7860
AUTOMATIC1111 Api Auth String: (empty)
Model: (empty - uses default)
Image Size: 512x512
Steps: 20
Additional Parameters:
{
  "cfg_scale": 7,
  "sampler_name": "Euler a"
}
```

**Balanced Mode (10-15 seconds per image):**
```
Image Generation Engine: AUTOMATIC1111
AUTOMATIC1111 Base URL: http://automatic1111:7860
AUTOMATIC1111 Api Auth String: (empty)
Model: (empty)
Image Size: 768x768
Steps: 30
Additional Parameters:
{
  "cfg_scale": 8,
  "sampler_name": "DPM++ 2M Karras",
  "negative_prompt": "blurry, low quality, distorted"
}
```

**Quality Mode (20-30 seconds per image):**
```
Image Generation Engine: AUTOMATIC1111
AUTOMATIC1111 Base URL: http://automatic1111:7860
AUTOMATIC1111 Api Auth String: (empty)
Model: (empty)
Image Size: 768x768
Steps: 50
Additional Parameters:
{
  "cfg_scale": 10,
  "sampler_name": "DPM++ 2M Karras",
  "negative_prompt": "blurry, low quality, distorted, ugly, bad anatomy, watermark, text"
}
```

---

## 🔧 ADDITIONAL PARAMETERS EXPLAINED

### Available Parameters

```json
{
  "cfg_scale": 7,              // How closely to follow prompt (1-20, default 7)
  "sampler_name": "DPM++ 2M Karras",  // Sampling algorithm
  "steps": 30,                 // Number of steps (overrides Steps field)
  "width": 512,                // Image width (overrides Image Size)
  "height": 512,               // Image height (overrides Image Size)
  "negative_prompt": "blurry, low quality",  // What to avoid
  "seed": -1,                  // Random seed (-1 for random)
  "restore_faces": false,      // Face restoration
  "tiling": false,             // Tileable image
  "enable_hr": false,          // High-res fix
  "denoising_strength": 0.7    // For img2img (0.0-1.0)
}
```

### Common Samplers

- **Euler a** - Fast, good for most cases
- **DPM++ 2M Karras** - Best quality (recommended)
- **DDIM** - Consistent results
- **LMS** - Good for landscapes
- **Heun** - High quality but slower

### CFG Scale Guide

- **1-5:** Very creative, may ignore prompt
- **7-9:** Balanced (recommended)
- **10-15:** Very literal to prompt
- **15+:** May produce artifacts

---

## 🧪 TESTING AFTER CONFIGURATION

### Test 1: Simple Generation

In Open WebUI chat, type:
```
Generate an image of a sunset
```

Expected: Image appears in 10-15 seconds

### Test 2: Detailed Prompt

```
Generate an image of a beautiful mountain landscape with a lake, sunset, highly detailed, photorealistic
```

Expected: High-quality landscape image

### Test 3: With Style

```
Generate an image of a futuristic city at night, neon lights, cyberpunk style, detailed architecture
```

Expected: Stylized cityscape

---

## 🔍 TROUBLESHOOTING

### Issue: "Connection Error" or "Failed to generate image"

**Check:**
```bash
# Is Stable Diffusion running?
docker ps | grep automatic1111

# Check logs
docker logs automatic1111 --tail 50

# Test API directly
curl http://localhost:7860/sdapi/v1/sd-models
```

**Fix:**
```bash
# Restart Stable Diffusion
docker restart automatic1111

# Wait 30 seconds
sleep 30

# Try again in Open WebUI
```

### Issue: "Model not found"

**Solution:**
1. Leave Model field empty (uses default)
2. Or check available models:
```bash
docker exec automatic1111 ls /data/models/Stable-diffusion/
```

### Issue: Images are blurry or low quality

**Solution:**
1. Increase Steps to 30-50
2. Add quality keywords to prompt: "highly detailed, 8k, sharp focus"
3. Use negative prompt: "blurry, low quality, distorted"
4. Try different sampler: "DPM++ 2M Karras"

### Issue: "Out of memory" error

**Solution:**
1. Reduce Image Size to 512x512
2. Reduce Steps to 20
3. Check GPU: `nvidia-smi`
4. Restart container: `docker restart automatic1111`

### Issue: Very slow generation

**Causes:**
- Image size too large
- Too many steps
- Other processes using GPU

**Solutions:**
- Use 512x512 or 768x768
- Use 20-30 steps
- Check GPU usage: `nvidia-smi`

---

## 💡 TIPS FOR BETTER IMAGES

### Prompt Engineering

**Good Prompts:**
```
a beautiful landscape with mountains and a lake, sunset, highly detailed, 8k, photorealistic

portrait of a cat wearing a hat, studio lighting, professional photography, sharp focus

futuristic city at night, neon lights, cyberpunk style, detailed architecture, 4k
```

**Bad Prompts:**
```
sunset
cat
city
```

### Quality Keywords

Add these to prompts:
- `highly detailed`
- `8k` or `4k`
- `photorealistic`
- `professional photography`
- `sharp focus`
- `studio lighting`
- `masterpiece`

### Negative Prompts

Always include:
```
blurry, low quality, distorted, ugly, bad anatomy, watermark, text, signature
```

### Style Keywords

- **Photorealistic:** `photorealistic, professional photography, DSLR`
- **Artistic:** `oil painting, digital art, concept art`
- **Anime:** `anime style, manga, cel shaded`
- **3D:** `3d render, octane render, unreal engine`

---

## 📊 PERFORMANCE EXPECTATIONS

### On Your RTX 2080 SUPER (8GB VRAM)

| Resolution | Steps | Time | Quality |
|------------|-------|------|---------|
| 512x512 | 20 | 5-8s | Good |
| 512x512 | 30 | 8-12s | Very Good |
| 768x768 | 20 | 10-15s | Good |
| 768x768 | 30 | 15-20s | Excellent |
| 768x768 | 50 | 25-35s | Best |
| 1024x1024 | 30 | 30-45s | Excellent |

### Concurrent Users

- **1 user:** No issues
- **2-3 users:** May queue
- **4+ users:** Will queue (one at a time)

---

## 🔒 SECURITY NOTES

### Network Isolation

Stable Diffusion runs on internal network:
- ✅ No internet access
- ✅ Only accessible from local network
- ✅ Same security as Ollama

### No Authentication Needed

For internal network:
- Leave "Api Auth String" empty
- Authentication not required
- Only local users can access

### If You Want Authentication

To add authentication:
1. Edit docker-compose-stable-diffusion.yaml
2. Add to CLI_ARGS: `--api-auth username:password`
3. In Open WebUI, set: `username:password`
4. Restart: `docker restart automatic1111`

---

## 📝 QUICK REFERENCE CARD

```
╔══════════════════════════════════════════════════════════════╗
║  OPEN WEBUI IMAGE GENERATION SETTINGS                        ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  Image Generation Engine:    AUTOMATIC1111                   ║
║  AUTOMATIC1111 Base URL:     http://automatic1111:7860      ║
║  Api Auth String:            (empty)                         ║
║  Model:                      (empty - uses default)          ║
║  Image Size:                 768x768                         ║
║  Steps:                      30                              ║
║                                                              ║
║  Additional Parameters:                                      ║
║  {                                                           ║
║    "cfg_scale": 8,                                           ║
║    "sampler_name": "DPM++ 2M Karras",                        ║
║    "negative_prompt": "blurry, low quality, distorted"       ║
║  }                                                           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## ✅ FINAL CHECKLIST

Before testing:
- [ ] Stable Diffusion container running: `docker ps | grep automatic1111`
- [ ] API responding: `curl http://localhost:7860/sdapi/v1/sd-models`
- [ ] Open WebUI settings saved
- [ ] Image Generation Engine set to AUTOMATIC1111
- [ ] Base URL set to `http://automatic1111:7860`

After configuration:
- [ ] Test simple prompt: "Generate an image of a sunset"
- [ ] Image generates successfully
- [ ] Generation time is reasonable (10-20 seconds)
- [ ] Image quality is good

---

## 🎉 YOU'RE READY!

Your Open WebUI now has image generation!

**Test it:**
1. Go to chat
2. Type: "Generate an image of a beautiful mountain landscape"
3. Wait 10-15 seconds
4. Enjoy your AI-generated image!

**Need help?**
- Check logs: `docker logs automatic1111 --tail 50`
- Restart: `docker restart automatic1111`
- Read: STABLE_DIFFUSION_GUIDE.md
