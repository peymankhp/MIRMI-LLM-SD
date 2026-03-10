#!/bin/bash

# Automatic cache clearing script for Mixtral model
# This script clears page cache before loading large models

echo "🧹 Clearing system cache for large model loading..."

# Drop page cache (safe operation, doesn't affect dirty data)
sync
echo 1 | sudo tee /proc/sys/vm/drop_caches > /dev/null

# Show memory status
echo ""
echo "📊 Memory Status After Clearing:"
free -h | grep -E "Mem:|Swap:"

echo ""
echo "✅ Cache cleared successfully"
echo "💾 Available memory: $(free -h | awk '/^Mem:/ {print $7}')"
