#!/bin/bash

# Setup sudoers to allow cache clearing without password
# This allows the current user to run drop_caches without sudo password

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root or with sudo"
    exit 1
fi

CURRENT_USER="${SUDO_USER:-$USER}"

echo "🔧 Setting up passwordless cache clearing for user: $CURRENT_USER"
echo ""

# Create sudoers file for cache clearing
SUDOERS_FILE="/etc/sudoers.d/ollama-cache-clear"

cat > "$SUDOERS_FILE" << EOF
# Allow $CURRENT_USER to clear cache without password for Ollama/Mixtral
# This is safe as drop_caches only clears page cache, not dirty data
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/bin/tee /proc/sys/vm/drop_caches
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/sbin/sysctl vm.drop_caches=*
EOF

# Set correct permissions
chmod 0440 "$SUDOERS_FILE"

# Validate sudoers file
if visudo -c -f "$SUDOERS_FILE" > /dev/null 2>&1; then
    echo "✅ Sudoers configuration created successfully"
    echo "   File: $SUDOERS_FILE"
    echo ""
    echo "✅ You can now run these commands without password:"
    echo "   • sudo sysctl vm.drop_caches=1"
    echo "   • ./auto-clear-cache.sh"
    echo ""
else
    echo "❌ Sudoers validation failed, removing file"
    rm -f "$SUDOERS_FILE"
    exit 1
fi
