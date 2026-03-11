#!/bin/bash

# Fix MIRMI LLM nginx configuration to support WebSocket and LLM streaming
# This script backs up the current config and applies the fix

set -e

echo "🔧 Fixing MIRMI LLM nginx configuration..."
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root or with sudo"
    exit 1
fi

# Backup current configuration
BACKUP_DIR="nginx-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating backup..."
cp /etc/nginx/sites-available/openwebui "$BACKUP_DIR/openwebui.backup"
echo "   Backup saved to: $BACKUP_DIR/openwebui.backup"
echo ""

# Apply the fixed configuration
echo "✏️  Applying fixed configuration..."
cp nginx-openwebui-fixed.conf /etc/nginx/sites-available/openwebui

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
if nginx -t; then
    echo "✅ Configuration test passed"
    echo ""
    
    # Reload nginx
    echo "🔄 Reloading nginx..."
    systemctl reload nginx
    echo "✅ Nginx reloaded successfully"
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ FIXED! The following issues have been resolved:"
    echo ""
    echo "   1. ✅ WebSocket support enabled (fixes connection errors)"
    echo "   2. ✅ Streaming responses optimized (no buffering)"
    echo "   3. ✅ Increased timeouts for LLM generation (600s)"
    echo "   4. ✅ Proper proxy headers for HTTPS"
    echo ""
    echo "🎉 Your LLMs should now respond properly!"
    echo ""
    echo "🧪 Test your setup:"
    echo "   1. Open: https://mirmi-llm.mirmi.tum.de"
    echo "   2. Select a model (e.g., mistral:latest)"
    echo "   3. Send a message: 'Hello, how are you?'"
    echo "   4. You should see a streaming response"
    echo ""
    echo "📋 Backup location: $BACKUP_DIR/"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "❌ Configuration test failed!"
    echo "   Restoring backup..."
    cp "$BACKUP_DIR/openwebui.backup" /etc/nginx/sites-available/openwebui
    echo "   Backup restored. No changes were made."
    exit 1
fi
