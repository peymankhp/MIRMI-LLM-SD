#!/bin/bash
# Quick API test script

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          Testing Ollama API Access                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test 1: Check if API is accessible
echo -e "${BLUE}Test 1: Checking API accessibility...${NC}"
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✓ API is accessible at http://localhost:11434${NC}"
else
    echo -e "${RED}✗ API is not accessible${NC}"
    echo "Run: ./install-models-safe.sh to expose the API"
    exit 1
fi
echo ""

# Test 2: List available models
echo -e "${BLUE}Test 2: Listing available models...${NC}"
MODELS=$(curl -s http://localhost:11434/api/tags | python3 -c "import sys, json; data=json.load(sys.stdin); print('\n'.join([m['name'] for m in data['models']]))")
echo "$MODELS"
echo ""

# Test 3: Simple text generation
echo -e "${BLUE}Test 3: Testing text generation...${NC}"
echo "Prompt: 'Say hello in one sentence'"
echo -e "${YELLOW}Generating response...${NC}"

RESPONSE=$(curl -s http://localhost:11434/api/generate -d '{
  "model": "mistral:latest",
  "prompt": "Say hello in one sentence",
  "stream": false
}' | python3 -c "import sys, json; print(json.load(sys.stdin)['response'])")

echo -e "${GREEN}Response:${NC} $RESPONSE"
echo ""

# Test 4: OpenAI-compatible endpoint
echo -e "${BLUE}Test 4: Testing OpenAI-compatible API...${NC}"
OPENAI_RESPONSE=$(curl -s http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ollama" \
  -d '{
    "model": "mistral:latest",
    "messages": [{"role": "user", "content": "What is 2+2?"}],
    "max_tokens": 50
  }' | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['message']['content'])")

echo -e "${GREEN}Response:${NC} $OPENAI_RESPONSE"
echo ""

# Test 5: Show API endpoints
echo -e "${BLUE}Test 5: API Configuration Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Native Ollama API:"
echo "  Base URL: http://localhost:11434"
echo "  List models: curl http://localhost:11434/api/tags"
echo "  Generate: curl http://localhost:11434/api/generate -d '{...}'"
echo ""
echo "OpenAI-Compatible API:"
echo "  Base URL: http://localhost:11434/v1"
echo "  API Key: ollama (or any value)"
echo "  Chat: curl http://localhost:11434/v1/chat/completions -d '{...}'"
echo ""
echo "For Cursor/VS Code:"
echo "  Base URL: http://localhost:11434/v1"
echo "  API Key: ollama"
echo "  Model: mistral:latest (or any from the list above)"
echo ""

# Get server IP for remote access
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "For Remote Access (from another machine):"
echo "  Base URL: http://$SERVER_IP:11434/v1"
echo "  Note: Configure firewall if needed"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}All tests passed! Your API is working correctly. 🎉${NC}"
echo ""
echo "Next steps:"
echo "  1. Read API_ACCESS_GUIDE.md for detailed examples"
echo "  2. Run ./install-models-safe.sh to add Llama 3 and Qwen 2.5"
echo "  3. Configure your IDE or tools with the URLs above"
