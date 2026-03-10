#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                              ║"
echo "║  🤖 Complete Agentic IDE Setup                                               ║"
echo "║  VSCode + Continue + Your Local LLMs                                         ║"
echo "║                                                                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Check/Install VSCode
echo "📦 Step 1: Checking VSCode installation..."
if command -v code &> /dev/null; then
    echo "✅ VSCode already installed: $(code --version | head -1)"
else
    echo "📥 Installing VSCode..."
    sudo snap install code --classic
    echo "✅ VSCode installed"
fi
echo ""

# Step 2: Pull recommended models
echo "🤖 Step 2: Installing recommended LLM models..."
echo ""

echo "  Pulling qwen2.5-coder:7b (4.7GB) - Best for coding..."
docker exec ollama ollama pull qwen2.5-coder:7b
echo "  ✅ qwen2.5-coder:7b ready"
echo ""

echo "  Pulling nomic-embed-text (274MB) - For codebase understanding..."
docker exec ollama ollama pull nomic-embed-text
echo "  ✅ nomic-embed-text ready"
echo ""

# Step 3: Verify models
echo "📋 Step 3: Verifying installed models..."
echo ""
docker exec ollama ollama list | grep -E "qwen2.5-coder|qwen2.5:14b|llama3.1:8b|nomic-embed"
echo ""

# Step 4: Create Continue config
echo "⚙️  Step 4: Creating Continue configuration..."
mkdir -p ~/.continue
cat > ~/.continue/config.json << 'EOF'
{
  "models": [
    {
      "title": "Qwen 2.5 Coder 7B (Best for Coding)",
      "provider": "ollama",
      "model": "qwen2.5-coder:7b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Qwen 2.5 14B (Best Overall)",
      "provider": "ollama",
      "model": "qwen2.5:14b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Llama 3.1 8B (Fast)",
      "provider": "ollama",
      "model": "llama3.1:8b-instruct-q4_K_M",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Mistral 7B (Efficient)",
      "provider": "ollama",
      "model": "mistral:7b-instruct",
      "apiBase": "http://localhost:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Llama 3.1 8B",
    "provider": "ollama",
    "model": "llama3.1:8b-instruct-q4_K_M",
    "apiBase": "http://localhost:11434"
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://localhost:11434"
  },
  "reranker": {
    "name": "llm",
    "params": {
      "modelTitle": "Llama 3.1 8B"
    }
  },
  "contextProviders": [
    {
      "name": "code",
      "params": {}
    },
    {
      "name": "docs",
      "params": {}
    },
    {
      "name": "diff",
      "params": {}
    },
    {
      "name": "terminal",
      "params": {}
    },
    {
      "name": "problems",
      "params": {}
    },
    {
      "name": "folder",
      "params": {}
    },
    {
      "name": "codebase",
      "params": {}
    }
  ],
  "systemMessage": "You are an expert programmer. Provide concise, production-ready code with proper error handling."
}
EOF
echo "✅ Configuration created at ~/.continue/config.json"
echo ""

# Step 5: Test Ollama connection
echo "🔌 Step 5: Testing Ollama connection..."
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "✅ Ollama API is accessible"
else
    echo "❌ Cannot connect to Ollama API"
    echo "   Try: docker restart ollama"
fi
echo ""

# Step 6: Instructions
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                              ║"
echo "║  ✅ Setup Complete!                                                          ║"
echo "║                                                                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Open VSCode:"
echo "   code"
echo ""
echo "2. Install Continue Extension:"
echo "   - Press Ctrl+Shift+X"
echo "   - Search for 'Continue'"
echo "   - Click Install"
echo ""
echo "3. The configuration is already created at ~/.continue/config.json"
echo "   Continue will use it automatically!"
echo ""
echo "4. Start using:"
echo "   - Ctrl+L = Open chat"
echo "   - Ctrl+I = Inline edit"
echo "   - Tab = Accept autocomplete"
echo ""
echo "🎯 Your Models:"
echo "   • qwen2.5-coder:7b - Best for coding tasks"
echo "   • qwen2.5:14b - Best overall quality"
echo "   • llama3.1:8b - Fast autocomplete"
echo "   • mistral:7b - Efficient general use"
echo ""
echo "📖 Full guide: VSCODE_CONTINUE_COMPLETE_SETUP.md"
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║  Ready to code with AI! 🚀                                                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
