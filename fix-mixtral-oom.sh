#!/bin/bash

# Fix Mixtral OOM (Out of Memory) issue
# The 46.7B model is too large for 32GB RAM + 2GB swap

set -e

echo "🔧 Fixing Mixtral OOM Issue"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Problem: Mixtral 46.7B needs ~27GB RAM but system runs out of memory"
echo "Current: 32GB RAM + 2GB swap (FULL) = Not enough"
echo ""
echo "Solution: Increase swap to 16GB for safety margin"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo"
    exit 1
fi

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

echo ""
echo "Step 1: Clearing memory and stopping Ollama..."
docker stop ollama
sync
echo 3 > /proc/sys/vm/drop_caches
sleep 2

echo ""
echo "Step 2: Removing old swap..."
swapoff /swapfile 2>/dev/null || true
rm -f /swapfile

echo ""
echo "Step 3: Creating 16GB swap file..."
echo "   This will take 5-10 minutes..."
dd if=/dev/zero of=/swapfile bs=1G count=16 status=progress

echo ""
echo "Step 4: Setting up new swap..."
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Update fstab if needed
if ! grep -q "/swapfile" /etc/fstab; then
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
fi

# Set swappiness
sysctl vm.swappiness=10
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" >> /etc/sysctl.conf
fi

echo ""
echo "Step 5: Starting Ollama..."
docker start ollama
sleep 5

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Fixed!"
echo ""
echo "📊 New configuration:"
free -h | grep -E "Mem:|Swap:"
echo ""
echo "Total virtual memory: 32GB RAM + 16GB Swap = 48GB"
echo "Mixtral needs: ~27GB"
echo "Safety margin: ~21GB"
echo ""
echo "🚀 Now try Mixtral again:"
echo "   ./ollama-memory-manager.sh mixtral:8x7b-instruct-v0.1-q4_0"
echo ""
echo "⚠️  Note: Mixtral will be SLOW because it uses swap"
echo "   • First load: 5-10 minutes"
echo "   • Responses: 30-60 seconds each"
echo "   • Consider using smaller models for daily use"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
