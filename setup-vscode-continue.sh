#!/bin/bash

echo "=========================================="
echo "Setting Up VSCode + Continue for Local LLMs"
echo "=========================================="
echo ""

# Check if VSCode is installed
if ! command -v code &> /dev/null; then
    echo "📦 Installing VSCode..."
    sudo snap install code --classic
    echo "✅ VSCode installed"
else
    echo "✅ VSCode already installed"
fi

echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Open VSCode:"
echo "   code"
echo ""
echo "2. Install Continue extension:"
echo "   - Press Ctrl+Shift+X"
echo "   - Search for 'Continue'"
echo "   - Click Install"
echo ""
echo "3. Configure Continue:"
echo "   - Press Ctrl+Shift+P"
echo "   - Type 'Continue: Open Config'"
echo "   - Paste this configuration:"
echo ""
cat << 'EOF'
{
  "models": [
    {
      "title": "Qwen 2.5 14B (Best Quality)",
      "provider": "ollama",
      "model": "qwen2.5:14b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Llama 3.1 8B (Fast)",
      "provider": "ollama",
      "model": "llama3.1:8b",
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
    "model": "llama3.1:8b",
    "apiBase": "http://localhost:11434"
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://localhost:11434"
  }
}
EOF
echo ""
echo "4. Install embedding model (optional but recommended):"
echo "   ollama pull nomic-embed-text"
echo ""
echo "5. Test Continue:"
echo "   - Open any code file"
echo "   - Press Ctrl+L to open chat"
echo "   - Ask: 'Explain this code'"
echo "   - Or select code and press Ctrl+I for inline editing"
echo ""
echo "=========================================="
echo "✅ Setup guide complete!"
echo "=========================================="
echo ""
echo "📖 Full documentation: CONNECT_LOCAL_LLMS_TO_AGENTIC_IDES.md"
