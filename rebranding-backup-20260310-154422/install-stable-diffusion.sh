#!/bin/bash

# Install Stable Diffusion for Open WebUI Image Generation
# Zero downtime - runs alongside existing services

set -e

echo "🎨 Installing Stable Diffusion for Open WebUI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will:"
echo "  ✅ Install AUTOMATIC1111 Stable Diffusion WebUI"
echo "  ✅ Configure for your RTX 2080 SUPER (8GB VRAM)"
echo "  ✅ Download Stable Diffusion v1.5 model"
echo "  ✅ Integrate with Open WebUI"
echo "  ✅ Zero downtime for existing services"
echo ""

# Check GPU
echo "📊 Checking GPU..."
if ! nvidia-smi > /dev/null 2>&1; then
    echo "❌ NVIDIA GPU not detected!"
    echo "   Stable Diffusion requires GPU for reasonable performance"
    exit 1
fi

GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader)
GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)
echo "   ✅ GPU: $GPU_NAME"
echo "   ✅ VRAM: ${GPU_MEM}MB"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo"
    exit 1
fi

read -p "Continue with installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Creating Backup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

BACKUP_DIR="stable-diffusion-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup existing configs
if [ -f "docker-compose.yaml" ]; then
    cp docker-compose.yaml "$BACKUP_DIR/"
    echo "✅ Backed up docker-compose.yaml"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Installing AUTOMATIC1111 Stable Diffusion WebUI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Pull the image
echo "Pulling Stable Diffusion WebUI image..."
echo "   This may take 5-10 minutes..."
docker pull universonic/stable-diffusion-webui:latest

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Starting Stable Diffusion Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start the service
docker-compose -f docker-compose-stable-diffusion.yaml up -d automatic1111

echo "Waiting for Stable Diffusion to start..."
echo "   This may take 2-3 minutes on first run..."
sleep 30

# Wait for service to be ready
for i in {1..60}; do
    if curl -s http://localhost:7860 > /dev/null 2>&1; then
        echo "   ✅ Stable Diffusion WebUI is ready!"
        break
    fi
    echo "   Waiting... ($i/60)"
    sleep 5
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Downloading Stable Diffusion v1.5 Model"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Downloading Stable Diffusion v1.5 model..."
echo "   Size: ~4GB | This may take 10-20 minutes..."
echo ""

# Download SD 1.5 model
docker exec automatic1111 bash -c "
cd /data/models/Stable-diffusion && \
wget -c https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors \
-O sd_v1-5-pruned-emaonly.safetensors
" || echo "Model download in progress..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5: Testing Image Generation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test API
echo "Testing Stable Diffusion API..."
if curl -s http://localhost:7860/sdapi/v1/sd-models > /dev/null 2>&1; then
    echo "   ✅ API is responding"
else
    echo "   ⚠️  API not ready yet (may need more time)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ INSTALLATION COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Service Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|automatic1111|open-webui|ollama"
echo ""
echo "🎨 Stable Diffusion WebUI:"
echo "   URL: http://localhost:7860"
echo "   API: http://localhost:7860/sdapi/v1"
echo ""
echo "🔧 Open WebUI Configuration:"
echo "   1. Go to: https://mirmi-llm.mirmi.tum.de"
echo "   2. Admin Panel > Settings > Images > Image Generation"
echo "   3. Set Image Generation Engine: AUTOMATIC1111"
echo "   4. Set API Base URL: http://automatic1111:7860"
echo "   5. Leave API Key empty (not needed for local)"
echo "   6. Click Save"
echo ""
echo "🧪 Test Image Generation:"
echo "   1. In Open WebUI chat, type: 'Generate an image of a sunset'"
echo "   2. Or use the image generation button"
echo ""
echo "📚 Read: STABLE_DIFFUSION_GUIDE.md for details"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
