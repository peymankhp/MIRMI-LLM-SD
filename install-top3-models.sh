#!/bin/bash

# Install the Top 3 LLMs optimized for your machine
# Based on 2026 benchmarks and your hardware specs

echo "🏆 Installing Top 3 LLMs for Your Machine"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your Hardware:"
echo "  • CPU: Intel i9-9900KF (8 cores, 16 threads)"
echo "  • RAM: 32GB"
echo "  • GPU: RTX 2080 SUPER (8GB VRAM)"
echo ""
echo "Installing models optimized for this configuration..."
echo ""

# Model 1: Qwen 2.5 14B (Best Overall)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🥇 #1: Qwen 2.5 14B (Best Overall Quality)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Size: 9GB | RAM: 10-12GB | Speed: Fast | Quality: Excellent"
echo "Best for: Complex tasks, coding, multilingual, reasoning"
echo ""
read -p "Install Qwen 2.5 14B? [Y/n]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    docker exec ollama ollama pull qwen2.5:14b
    if [ $? -eq 0 ]; then
        echo "✅ Qwen 2.5 14B installed successfully"
    else
        echo "❌ Installation failed"
    fi
fi

echo ""

# Model 2: Llama 3.1 8B (Best Speed)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🥈 #2: Llama 3.1 8B Instruct (Best Speed & Balance)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Size: 4.9GB | RAM: 6-8GB | Speed: Very Fast | Quality: Very Good"
echo "Best for: Daily use, coding, 128K context, fits in GPU"
echo ""
read -p "Install Llama 3.1 8B? [Y/n]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    docker exec ollama ollama pull llama3.1:8b-instruct-q4_K_M
    if [ $? -eq 0 ]; then
        echo "✅ Llama 3.1 8B installed successfully"
    else
        echo "❌ Installation failed"
    fi
fi

echo ""

# Model 3: Mistral 7B (Already installed)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🥉 #3: Mistral 7B Instruct (Best Efficiency)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Size: 4.4GB | RAM: 5-6GB | Speed: Fastest | Quality: Good"
echo "Best for: Quick queries, automation, low resource usage"
echo ""
echo "✅ Already installed: mistral:7b-instruct"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Your Installed Models:"
docker exec ollama ollama list
echo ""
echo "🎯 Usage Recommendations:"
echo ""
echo "  Daily Use:        Llama 3.1 8B (fast, balanced)"
echo "  Best Quality:     Qwen 2.5 14B (complex tasks)"
echo "  Quick Queries:    Mistral 7B (fastest)"
echo "  Coding:           Qwen 2.5 14B or Llama 3.1 8B"
echo "  Multilingual:     Qwen 2.5 14B"
echo ""
echo "🚀 How to Use:"
echo "  1. Go to: https://mirmi-llm.mirmi.tum.de"
echo "  2. Select model from dropdown"
echo "  3. Start chatting!"
echo ""
echo "🧪 Test a Model:"
echo "  docker exec ollama ollama run qwen2.5:14b \"Hello!\""
echo "  docker exec ollama ollama run llama3.1:8b-instruct-q4_K_M \"Hello!\""
echo "  docker exec ollama ollama run mistral:7b-instruct \"Hello!\""
echo ""
echo "📚 Read: TOP_3_LLMS_FOR_YOUR_MACHINE.md for detailed info"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
