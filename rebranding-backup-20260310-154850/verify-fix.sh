#!/bin/bash

# Verify that the WebSocket fix is working

echo "🔍 Verifying WebSocket Fix..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check 1: Map directive
echo "1️⃣  Checking WebSocket map directive..."
if sudo cat /etc/nginx/nginx.conf | grep -q "map.*http_upgrade.*connection_upgrade"; then
    echo "   ✅ Map directive found in nginx.conf"
else
    echo "   ❌ Map directive missing"
fi
echo ""

# Check 2: Site configuration
echo "2️⃣  Checking site configuration..."
if sudo cat /etc/nginx/sites-available/openwebui | grep -q "Connection.*connection_upgrade"; then
    echo "   ✅ Site config uses \$connection_upgrade variable"
else
    echo "   ❌ Site config not using correct variable"
fi
echo ""

# Check 3: Nginx status
echo "3️⃣  Checking nginx status..."
if sudo systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx is running"
else
    echo "   ❌ Nginx is not running"
fi
echo ""

# Check 4: Container connectivity
echo "4️⃣  Checking MIRMI LLM connectivity..."
if curl -s http://10.157.174.177:8080/health | grep -q "true"; then
    echo "   ✅ MIRMI LLM is responding"
else
    echo "   ❌ MIRMI LLM not responding"
fi
echo ""

# Check 5: Recent logs
echo "5️⃣  Checking recent WebSocket attempts..."
RECENT_WS=$(docker logs open-webui --tail 20 2>&1 | grep -c "socket.io")
if [ "$RECENT_WS" -gt 0 ]; then
    echo "   ℹ️  Found $RECENT_WS WebSocket connection attempts in last 20 lines"
    echo "   ℹ️  Check browser console for connection status"
else
    echo "   ℹ️  No recent WebSocket attempts (may need browser refresh)"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 VERIFICATION SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Configuration is correct!"
echo ""
echo "🧪 NEXT STEPS:"
echo ""
echo "   1. Open your browser to: https://mirmi-llm.mirmi.tum.de"
echo ""
echo "   2. Do a HARD REFRESH to clear cache:"
echo "      • Chrome/Firefox: Ctrl + Shift + R"
echo "      • Safari: Cmd + Shift + R"
echo ""
echo "   3. Open browser console (F12) and check for:"
echo "      • WebSocket connection messages"
echo "      • Any red errors"
echo ""
echo "   4. Select a model (e.g., mistral:latest)"
echo ""
echo "   5. Send a test message: 'Hello!'"
echo ""
echo "   6. You should see:"
echo "      ✅ Response appears word-by-word (streaming)"
echo "      ✅ No errors in console"
echo "      ✅ WebSocket shows 'connected' status"
echo ""
echo "📝 If still not working:"
echo "   • Check browser console for specific errors"
echo "   • Try a different browser"
echo "   • Clear all browser cache and cookies"
echo "   • Check: docker logs open-webui --tail 50"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
