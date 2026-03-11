#!/bin/bash

# Complete setup for Mixtral memory management
# Run this once to set everything up

set -e

echo "🎯 Mixtral Memory Management - Complete Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will:"
echo "  1. Allow cache clearing without password"
echo "  2. Increase swap space from 2GB to 8GB"
echo "  3. Create helper scripts for Mixtral"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo ./setup-mixtral-memory.sh"
    exit 1
fi

read -p "Continue with setup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Setup Passwordless Cache Clearing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./setup-sudoers-cache.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Increase Swap Space"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./increase-swap.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SETUP COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Your System Now:"
echo "   • RAM: 32GB"
echo "   • Swap: 8GB (increased from 2GB)"
echo "   • Total virtual memory: 40GB"
echo "   • Cache clearing: No password needed"
echo ""
echo "🚀 How to Use Mixtral:"
echo ""
echo "   Option 1 - Automatic (Recommended):"
echo "   ./ollama-memory-manager.sh mixtral:8x7b-instruct-v0.1-q4_0"
echo ""
echo "   Option 2 - Manual:"
echo "   ./auto-clear-cache.sh"
echo "   # Then use Mixtral in Open WebUI"
echo ""
echo "💡 Tips:"
echo "   • Close other applications before using Mixtral"
echo "   • Mixtral needs ~27GB RAM"
echo "   • First load takes 2-5 minutes"
echo "   • Responses take 10-30 seconds"
echo ""
echo "📚 Read MEMORY_MANAGEMENT_GUIDE.md for details"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
