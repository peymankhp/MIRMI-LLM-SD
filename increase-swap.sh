#!/bin/bash

# Increase swap space to help with large models
# Current swap: 2GB → Target: 8GB

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root or with sudo"
    exit 1
fi

SWAP_SIZE_GB=8
SWAP_FILE="/swapfile"

echo "💾 Swap Space Increase Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Current swap: $(free -h | awk '/Swap:/ {print $2}')"
echo "Target swap: ${SWAP_SIZE_GB}GB"
echo ""

# Check if swap file already exists
if [ -f "$SWAP_FILE" ]; then
    echo "⚠️  Swap file already exists at $SWAP_FILE"
    echo ""
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    
    echo "🔄 Removing existing swap..."
    swapoff "$SWAP_FILE" 2>/dev/null || true
    rm -f "$SWAP_FILE"
fi

echo "📝 Creating ${SWAP_SIZE_GB}GB swap file..."
echo "   This may take a few minutes..."

# Create swap file
dd if=/dev/zero of="$SWAP_FILE" bs=1G count=$SWAP_SIZE_GB status=progress

# Set permissions
chmod 600 "$SWAP_FILE"

# Setup swap
mkswap "$SWAP_FILE"

# Enable swap
swapon "$SWAP_FILE"

# Make it permanent
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
    echo "✅ Added to /etc/fstab for persistence"
fi

# Optimize swap usage (swappiness)
sysctl vm.swappiness=10
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    echo "✅ Set swappiness to 10 (less aggressive swapping)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Swap space increased successfully!"
echo ""
echo "📊 New swap status:"
free -h | grep -E "Mem:|Swap:"
echo ""
echo "💡 Benefits:"
echo "   • Prevents out-of-memory errors"
echo "   • Allows loading larger models"
echo "   • System more stable under memory pressure"
echo ""
echo "⚠️  Note: Swap is slower than RAM"
echo "   • Models may load slower"
echo "   • Response time may be affected"
echo "   • Best to close other applications when using Mixtral"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
