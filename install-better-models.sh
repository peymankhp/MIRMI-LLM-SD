#!/bin/bash

# Install better alternatives to Mixtral 46.7B Q4
# These models fit in 32GB RAM and provide excellent quality

echo "🎯 Installing Better Model Alternatives"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your system: 32GB RAM"
echo "Mixtral Q4: 27GB (too large, causes OOM)"
echo ""
echo "Installing better alternatives that fit your RAM:"
echo ""

# Function to install and test a model
install_model() {
    local model=$1
    local description=$2
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Installing: $model"
    echo "   $description"
    echo ""
    
    docker exec ollama ollama pull "$model"
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Installed successfully"
        echo ""
    else
        echo "   ❌ Installation failed"
        echo ""
    fi
}

# Option 1: Qwen 2.5 14B (Recommended)
read -p "Install Qwen 2.5 14B? (Recommended - Excellent quality, 9GB) [Y/n]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    install_model "qwen2.5:14b" "Excellent quality, fast, fits perfectly"
fi

# Option 2: Mixtral Q2_K (Smaller Mixtral)
read -p "Install Mixtral Q2_K? (Smaller Mixtral, 15GB) [Y/n]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    install_model "mixtral:8x7b-instruct-v0.1-q2_k" "Smaller Mixtral, good quality"
fi

# Option 3: Mixtral Q3_K_M (Medium Mixtral)
read -p "Install Mixtral Q3_K_M? (Medium Mixtral, 20GB) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_model "mixtral:8x7b-instruct-v0.1-q3_k_m" "Better quality than Q2, still fits"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation Complete!"
echo ""
echo "📊 Your models now:"
docker exec ollama ollama list
echo ""
echo "🚀 How to use:"
echo "   1. Go to: https://mirmi-llm.mirmi.tum.de"
echo "   2. Select model from dropdown"
echo "   3. Start chatting!"
echo ""
echo "💡 Recommended models for your system:"
echo "   • qwen2.5:14b - Best balance of quality and speed"
echo "   • mixtral Q2_K - Good Mixtral alternative"
echo "   • llama2:13b-chat - Already installed, very good"
echo "   • mistral:latest - Fast for daily use"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
