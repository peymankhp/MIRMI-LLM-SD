#!/bin/bash

# Create an Open WebUI hook that automatically clears cache before using Mixtral

HOOK_DIR=".kiro/hooks"
HOOK_FILE="$HOOK_DIR/mixtral-memory-prep.json"

echo "🎣 Creating Open WebUI hook for automatic memory management..."
echo ""

# Create hooks directory if it doesn't exist
mkdir -p "$HOOK_DIR"

# Create the hook
cat > "$HOOK_FILE" << 'EOF'
{
  "name": "Mixtral Memory Prep",
  "version": "1.0.0",
  "description": "Automatically clears cache and prepares memory before using Mixtral model",
  "when": {
    "type": "preToolUse",
    "toolTypes": [".*"]
  },
  "then": {
    "type": "runCommand",
    "command": "if echo '$TOOL_ARGS' | grep -q 'mixtral'; then ./auto-clear-cache.sh; fi"
  }
}
EOF

echo "✅ Hook created: $HOOK_FILE"
echo ""
echo "This hook will:"
echo "   • Detect when Mixtral model is being used"
echo "   • Automatically clear cache before loading"
echo "   • Free up memory for the large model"
echo ""
echo "💡 Note: You still need to run setup-sudoers-cache.sh first"
echo "   to allow passwordless cache clearing"
