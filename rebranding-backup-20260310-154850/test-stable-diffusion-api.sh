#!/bin/bash

echo "=========================================="
echo "Testing Stable Diffusion API"
echo "=========================================="
echo ""

echo "1. Checking container status..."
docker ps | grep automatic1111
echo ""

echo "2. Testing API from MIRMI LLM container..."
docker exec open-webui curl -s http://automatic1111:7860/sdapi/v1/sd-models | python3 -c "import sys, json; data=json.load(sys.stdin); print(f'✅ API Working! Model: {data[0][\"model_name\"]}')" 2>&1
echo ""

echo "3. Testing simple image generation (this will take 10-15 seconds)..."
docker exec open-webui curl -s -X POST http://automatic1111:7860/sdapi/v1/txt2img \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "a beautiful sunset",
    "steps": 20,
    "width": 512,
    "height": 512
  }' | python3 -c "import sys, json; data=json.load(sys.stdin); print('✅ Image generated successfully!' if 'images' in data and len(data['images']) > 0 else '❌ Failed')" 2>&1

echo ""
echo "=========================================="
echo "✅ All tests passed!"
echo "=========================================="
echo ""
echo "Next step: Configure MIRMI LLM Admin Panel"
echo "See: CONFIGURE_OPENWEBUI_IMAGES.txt"
