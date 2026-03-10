#!/bin/bash

# Ollama Memory Manager
# Automatically manages memory for large models like Mixtral

set -e

MODEL_NAME="${1:-mixtral:8x7b-instruct-v0.1-q4_0}"
MIN_FREE_GB=27

echo "🎯 Ollama Memory Manager"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Target model: $MODEL_NAME"
echo "Required free memory: ${MIN_FREE_GB}GB"
echo ""

# Function to get available memory in GB
get_available_gb() {
    awk '/MemAvailable/ {printf "%.1f", $2/1024/1024}' /proc/meminfo
}

# Function to clear cache
clear_cache() {
    echo "🧹 Clearing system cache..."
    sync
    echo 1 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    sleep 2
}

# Function to unload other models
unload_other_models() {
    echo "🔄 Unloading other models from memory..."
    # Restart Ollama to clear all loaded models
    docker restart ollama > /dev/null 2>&1
    echo "   Waiting for Ollama to restart..."
    sleep 5
    
    # Wait for Ollama to be ready
    for i in {1..30}; do
        if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
            echo "   ✅ Ollama restarted successfully"
            return 0
        fi
        sleep 1
    done
    echo "   ⚠️  Ollama restart timeout, continuing anyway..."
}

# Check current available memory
AVAILABLE_GB=$(get_available_gb)
echo "📊 Current Status:"
echo "   Available memory: ${AVAILABLE_GB}GB"
echo ""

# If not enough memory, try to free it
if (( $(echo "$AVAILABLE_GB < $MIN_FREE_GB" | bc -l) )); then
    echo "⚠️  Not enough memory available (need ${MIN_FREE_GB}GB, have ${AVAILABLE_GB}GB)"
    echo ""
    
    # Step 1: Clear cache
    clear_cache
    AVAILABLE_GB=$(get_available_gb)
    echo "   After cache clear: ${AVAILABLE_GB}GB available"
    echo ""
    
    # Step 2: If still not enough, unload models
    if (( $(echo "$AVAILABLE_GB < $MIN_FREE_GB" | bc -l) )); then
        echo "   Still not enough, unloading other models..."
        unload_other_models
        clear_cache
        AVAILABLE_GB=$(get_available_gb)
        echo "   After unloading models: ${AVAILABLE_GB}GB available"
        echo ""
    fi
fi

# Final check
AVAILABLE_GB=$(get_available_gb)
if (( $(echo "$AVAILABLE_GB >= $MIN_FREE_GB" | bc -l) )); then
    echo "✅ Memory ready: ${AVAILABLE_GB}GB available"
    echo ""
    echo "🚀 Loading model: $MODEL_NAME"
    echo "   This may take a few minutes..."
    echo ""
    
    # Load the model with a simple prompt
    docker exec ollama ollama run "$MODEL_NAME" "Hi" > /dev/null 2>&1 &
    
    echo "✅ Model loading started"
    echo ""
    echo "💡 Tips:"
    echo "   • Wait 1-2 minutes for model to fully load"
    echo "   • Check memory: docker stats ollama"
    echo "   • Monitor GPU: nvidia-smi"
    echo ""
else
    echo "❌ Still not enough memory: ${AVAILABLE_GB}GB available, need ${MIN_FREE_GB}GB"
    echo ""
    echo "💡 Suggestions:"
    echo "   1. Close other applications"
    echo "   2. Increase swap space"
    echo "   3. Use a smaller model (e.g., mistral:7b)"
    echo "   4. Add more RAM to your system"
    echo ""
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
