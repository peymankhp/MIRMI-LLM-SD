#!/bin/bash

# Diagnostic script to confirm the WebSocket issue

echo "🔍 Diagnosing MIRMI LLM LLM Issue..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check 1: Container status
echo "1️⃣  Checking container status..."
if docker ps | grep -q "open-webui"; then
    echo "   ✅ MIRMI LLM container is running"
else
    echo "   ❌ MIRMI LLM container is NOT running"
fi

if docker ps | grep -q "ollama"; then
    echo "   ✅ Ollama container is running"
else
    echo "   ❌ Ollama container is NOT running"
fi
echo ""

# Check 2: Internal connectivity
echo "2️⃣  Checking internal connectivity..."
if docker exec open-webui curl -s http://ollama:11434/api/tags > /dev/null 2>&1; then
    echo "   ✅ MIRMI LLM can reach Ollama"
    MODEL_COUNT=$(docker exec open-webui curl -s http://ollama:11434/api/tags 2>/dev/null | grep -o '"name"' | wc -l)
    echo "   ✅ $MODEL_COUNT models available"
else
    echo "   ❌ MIRMI LLM CANNOT reach Ollama"
fi
echo ""

# Check 3: WebSocket support in nginx
echo "3️⃣  Checking nginx WebSocket configuration..."
if sudo grep -q "Upgrade.*http_upgrade" /etc/nginx/sites-available/openwebui 2>/dev/null; then
    echo "   ✅ WebSocket headers found in nginx config"
else
    echo "   ❌ WebSocket headers MISSING in nginx config (THIS IS THE PROBLEM!)"
fi

if sudo grep -q 'Connection.*"upgrade"' /etc/nginx/sites-available/openwebui 2>/dev/null; then
    echo "   ✅ Connection upgrade header found"
else
    echo "   ❌ Connection upgrade header MISSING (THIS IS THE PROBLEM!)"
fi
echo ""

# Check 4: Recent WebSocket errors
echo "4️⃣  Checking for WebSocket errors in logs..."
WS_ERRORS=$(docker logs open-webui --tail 100 2>&1 | grep -c "socket.io.*400")
if [ "$WS_ERRORS" -gt 0 ]; then
    echo "   ❌ Found $WS_ERRORS WebSocket errors in last 100 log lines"
    echo "   ❌ This confirms WebSocket connections are failing"
else
    echo "   ✅ No recent WebSocket errors"
fi
echo ""

# Check 5: Nginx status
echo "5️⃣  Checking nginx status..."
if sudo systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx is running"
else
    echo "   ❌ Nginx is NOT running"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 DIAGNOSIS SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if ! sudo grep -q "Upgrade.*http_upgrade" /etc/nginx/sites-available/openwebui 2>/dev/null; then
    echo "🔴 PROBLEM CONFIRMED:"
    echo ""
    echo "   Your nginx configuration is missing WebSocket support."
    echo "   This is why LLMs don't respond even though the panel loads."
    echo ""
    echo "   The web interface loads fine (HTTP works)"
    echo "   But real-time communication fails (WebSocket broken)"
    echo ""
    echo "🔧 SOLUTION:"
    echo ""
    echo "   Run this command to fix it:"
    echo "   sudo ./fix-nginx.sh"
    echo ""
    echo "   This will:"
    echo "   • Backup your current config"
    echo "   • Add WebSocket support"
    echo "   • Enable streaming responses"
    echo "   • Reload nginx"
    echo ""
    echo "   Time: 10 seconds"
    echo ""
else
    echo "✅ Configuration looks good!"
    echo ""
    echo "   If LLMs still don't respond, check:"
    echo "   1. Browser console for errors (F12)"
    echo "   2. Firewall settings"
    echo "   3. Try reloading nginx: sudo systemctl reload nginx"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
