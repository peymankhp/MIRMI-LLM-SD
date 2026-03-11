#!/bin/bash

# Rollback script for network isolation

BACKUP_DIR="${1}"

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Usage: sudo ./rollback-network-isolation.sh <backup-directory>"
    echo ""
    echo "Available backups:"
    ls -d network-isolation-backup-* 2>/dev/null || echo "  No backups found"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo"
    exit 1
fi

echo "🔄 Rolling Back Network Isolation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Backup directory: $BACKUP_DIR"
echo ""

read -p "Continue with rollback? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

echo ""
echo "Step 1: Stopping containers..."
cd /home/mirmi/open-webui || cd "$(dirname "$0")"
docker-compose down

echo ""
echo "Step 2: Restoring docker-compose.yaml..."
if [ -f "$BACKUP_DIR/docker-compose.yaml.backup" ]; then
    cp "$BACKUP_DIR/docker-compose.yaml.backup" docker-compose.yaml
    echo "✅ Restored docker-compose.yaml"
else
    echo "❌ Backup not found: $BACKUP_DIR/docker-compose.yaml.backup"
fi

echo ""
echo "Step 3: Restoring iptables rules..."
if [ -f "$BACKUP_DIR/iptables.backup" ]; then
    iptables-restore < "$BACKUP_DIR/iptables.backup"
    echo "✅ Restored iptables rules"
else
    echo "❌ Backup not found: $BACKUP_DIR/iptables.backup"
fi

echo ""
echo "Step 4: Restoring nginx configuration..."
if [ -f "$BACKUP_DIR/nginx-openwebui.backup" ]; then
    cp "$BACKUP_DIR/nginx-openwebui.backup" /etc/nginx/sites-available/openwebui
    systemctl reload nginx
    echo "✅ Restored nginx configuration"
else
    echo "❌ Backup not found: $BACKUP_DIR/nginx-openwebui.backup"
fi

echo ""
echo "Step 5: Starting containers..."
docker-compose up -d

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Rollback Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Configuration restored from: $BACKUP_DIR"
echo ""
