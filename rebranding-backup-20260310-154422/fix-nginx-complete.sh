#!/bin/bash

# Complete fix for Open WebUI WebSocket support
# Adds map directive and updates site configuration

set -e

echo "🔧 Applying complete WebSocket fix..."
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root or with sudo"
    exit 1
fi

# Backup
BACKUP_DIR="nginx-backup-complete-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating backups..."
cp /etc/nginx/nginx.conf "$BACKUP_DIR/nginx.conf.backup"
cp /etc/nginx/sites-available/openwebui "$BACKUP_DIR/openwebui.backup"
echo "   Backups saved to: $BACKUP_DIR/"
echo ""

# Check if map directive exists
if ! grep -q "map.*http_upgrade" /etc/nginx/nginx.conf; then
    echo "✏️  Adding WebSocket map directive to nginx.conf..."
    
    # Add map directive in http block
    sed -i '/^http {/a \
    # WebSocket support\
    map $http_upgrade $connection_upgrade {\
        default upgrade;\
        '"'"''"'"' close;\
    }\
' /etc/nginx/nginx.conf
    
    echo "   ✅ Map directive added"
else
    echo "   ℹ️  Map directive already exists"
fi
echo ""

# Update site configuration to use the map
echo "✏️  Updating site configuration..."
cat > /etc/nginx/sites-available/openwebui << 'EOF'
server {
    listen 443 ssl;
    server_name mirmi-llm.mirmi.tum.de;

    ssl_certificate /etc/letsencrypt/live/mirmi-llm.mirmi.tum.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mirmi-llm.mirmi.tum.de/privkey.pem;

    # Increase timeouts for LLM responses
    proxy_read_timeout 600s;
    proxy_connect_timeout 600s;
    proxy_send_timeout 600s;

    # Increase buffer sizes for streaming responses
    proxy_buffering off;
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_busy_buffers_size 8k;

    location / {
        proxy_pass http://10.157.174.177:8080;
        proxy_http_version 1.1;
        
        # WebSocket support - using map variable
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        
        # Standard proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
    }

    # WebSocket endpoint - explicit configuration
    location /ws/ {
        proxy_pass http://10.157.174.177:8080;
        proxy_http_version 1.1;
        
        # WebSocket upgrade headers
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Disable buffering for WebSocket
        proxy_buffering off;
        
        # Increase timeouts for long-running connections
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }

    # API endpoints - optimize for streaming
    location /api/ {
        proxy_pass http://10.157.174.177:8080;
        proxy_http_version 1.1;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Disable buffering for streaming responses
        proxy_buffering off;
        proxy_cache off;
        
        # Increase timeouts for LLM generation
        proxy_read_timeout 600s;
        proxy_connect_timeout 600s;
        proxy_send_timeout 600s;
    }
}

server {
    listen 80;
    server_name mirmi-llm.mirmi.tum.de;
    return 301 https://$host$request_uri;
}
EOF

echo "   ✅ Site configuration updated"
echo ""

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
if nginx -t; then
    echo "✅ Configuration test passed"
    echo ""
    
    # Restart nginx (not just reload, to ensure map is loaded)
    echo "🔄 Restarting nginx..."
    systemctl restart nginx
    echo "✅ Nginx restarted successfully"
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ COMPLETE FIX APPLIED!"
    echo ""
    echo "   Changes made:"
    echo "   1. ✅ Added WebSocket map directive to nginx.conf"
    echo "   2. ✅ Updated site config to use \$connection_upgrade"
    echo "   3. ✅ Restarted nginx (full restart, not reload)"
    echo ""
    echo "🎉 Your LLMs should now respond!"
    echo ""
    echo "🧪 Test now:"
    echo "   1. Refresh: https://mirmi-llm.mirmi.tum.de (hard refresh: Ctrl+Shift+R)"
    echo "   2. Open browser console (F12) - check for WebSocket errors"
    echo "   3. Select a model and send: 'Hello!'"
    echo "   4. You should see streaming response"
    echo ""
    echo "📋 Backups: $BACKUP_DIR/"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "❌ Configuration test failed!"
    echo "   Restoring backups..."
    cp "$BACKUP_DIR/nginx.conf.backup" /etc/nginx/nginx.conf
    cp "$BACKUP_DIR/openwebui.backup" /etc/nginx/sites-available/openwebui
    echo "   Backups restored. No changes were made."
    exit 1
fi
