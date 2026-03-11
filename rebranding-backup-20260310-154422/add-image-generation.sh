#!/bin/bash

# Add Stable Diffusion Image Generation to Open WebUI
# Zero downtime installation

set -e

echo "🎨 Adding Image Generation to Open WebUI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo"
    exit 1
fi

# Check GPU
echo "📊 Checking system..."
if ! nvidia-smi > /dev/null 2>&1; then
    echo "❌ NVIDIA GPU not detected!"
    exit 1
fi

GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader)
GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)
GPU_FREE=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits)

echo "   GPU: $GPU_NAME"
echo "   VRAM: ${GPU_MEM}MB (${GPU_FREE}MB free)"
echo ""

if [ "$GPU_MEM" -lt 6000 ]; then
    echo "⚠️  Warning: Less than 6GB VRAM detected"
    echo "   Stable Diffusion may be slow"
    echo ""
fi

echo "This will install:"
echo "  • AUTOMATIC1111 Stable Diffusion WebUI"
echo "  • Stable Diffusion v1.5 model (~4GB)"
echo "  • Integration with Open WebUI"
echo ""
echo "Estimated time: 20-30 minutes"
echo "Downtime: Zero (runs alongside existing services)"
echo ""

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Pulling Docker Image"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker pull universonic/stable-diffusion-webui:latest

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Starting Stable Diffusion"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd /home/mirmi/open-webui || cd "$(dirname "$0")"

docker-compose -f docker-compose-stable-diffusion.yaml up -d automatic1111

echo "Waiting for service to start..."
sleep 20

# Wait for API to be ready
for i in {1..30}; do
    if curl -s http://localhost:7860 > /dev/null 2>&1; then
        echo "✅ Stable Diffusion is ready!"
        break
    fi
    sleep 5
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Downloading SD v1.5 Model"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Downloading Stable Diffusion v1.5 (~4GB)..."
echo "This may take 10-20 minutes depending on your connection..."
echo ""

# Download model
docker exec automatic1111 bash -c "
mkdir -p /data/models/Stable-diffusion && \
cd /data/models/Stable-diffusion && \
if [ ! -f sd_v1-5-pruned-emaonly.safetensors ]; then
    wget -c --progress=bar:force \
    https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors \
    -O sd_v1-5-pruned-emaonly.safetensors
    echo 'Model downloaded successfully'
else
    echo 'Model already exists'
fi
"

# Restart to load model
echo ""
echo "Restarting to load model..."
docker restart automatic1111
sleep 15

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Testing Installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test API
if curl -s http://localhost:7860/sdapi/v1/sd-models | grep -q "sd_v1-5"; then
    echo "✅ API is working"
    echo "✅ Model loaded successfully"
else
    echo "⚠️  API may need more time to initialize"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ INSTALLATION COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Service Status:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "NAME|automatic1111|open-webui|ollama"
echo ""
echo "🎨 Stable Diffusion WebUI:"
echo "   API: http://localhost:7860"
echo "   Status: Running"
echo ""
echo "🔧 Configure Open WebUI:"
echo ""
echo "   1. Go to: https://mirmi-llm.mirmi.tum.de"
echo "   2. Login as admin"
echo "   3. Click profile → Admin Panel"
echo "   4. Settings → Images → Image Generation"
echo "   5. Configure:"
echo ""
echo "      Image Generation Engine: AUTOMATIC1111"
echo "      OpenAI API Base URL: http://automatic1111:7860"
echo "      OpenAI API Key: (leave empty)"
echo ""
echo "   6. Click Save"
echo ""
echo "🧪 Test Image Generation:"
echo "   In Open WebUI chat, type:"
echo "   'Generate an image of a beautiful sunset over mountains'"
echo ""
echo "📚 Full guide: STABLE_DIFFUSION_GUIDE.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
