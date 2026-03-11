#!/bin/bash

# Verify network isolation is working correctly

echo "🔍 Verifying Network Isolation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PASS=0
FAIL=0

# Test 1: Container internet access (should fail)
echo "Test 1: Container internet access (should FAIL)..."
if docker exec open-webui ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "   ❌ FAILED: Container can reach internet!"
    echo "   ⚠️  Security risk: Containers have internet access"
    FAIL=$((FAIL + 1))
else
    echo "   ✅ PASSED: Container cannot reach internet"
    PASS=$((PASS + 1))
fi

# Test 2: Container DNS resolution (should fail for external)
echo ""
echo "Test 2: Container external DNS (should FAIL)..."
if docker exec open-webui nslookup google.com > /dev/null 2>&1; then
    echo "   ❌ FAILED: Container can resolve external domains!"
    FAIL=$((FAIL + 1))
else
    echo "   ✅ PASSED: Container cannot resolve external domains"
    PASS=$((PASS + 1))
fi

# Test 3: Container to local network (should work)
echo ""
echo "Test 3: Container to local network (should WORK)..."
if docker exec open-webui ping -c 1 -W 2 10.157.174.177 > /dev/null 2>&1; then
    echo "   ✅ PASSED: Container can reach local network"
    PASS=$((PASS + 1))
else
    echo "   ❌ FAILED: Container cannot reach local network!"
    echo "   ⚠️  Service broken: Local access not working"
    FAIL=$((FAIL + 1))
fi

# Test 4: Container to Ollama (should work)
echo ""
echo "Test 4: Container to Ollama (should WORK)..."
if docker exec open-webui curl -s http://ollama:11434/api/tags > /dev/null 2>&1; then
    echo "   ✅ PASSED: MIRMI LLM can reach Ollama"
    PASS=$((PASS + 1))
else
    echo "   ❌ FAILED: MIRMI LLM cannot reach Ollama!"
    echo "   ⚠️  Service broken: Internal communication failed"
    FAIL=$((FAIL + 1))
fi

# Test 5: Ollama internet access (should fail)
echo ""
echo "Test 5: Ollama internet access (should FAIL)..."
if docker exec ollama ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "   ❌ FAILED: Ollama can reach internet!"
    echo "   ⚠️  Security risk: LLMs have internet access"
    FAIL=$((FAIL + 1))
else
    echo "   ✅ PASSED: Ollama cannot reach internet"
    PASS=$((PASS + 1))
fi

# Test 6: Host internet access (should work)
echo ""
echo "Test 6: Host internet access (should WORK)..."
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "   ✅ PASSED: Host has internet access"
    PASS=$((PASS + 1))
else
    echo "   ❌ FAILED: Host lost internet access!"
    echo "   ⚠️  Critical: Host connectivity broken"
    FAIL=$((FAIL + 1))
fi

# Test 7: Local network access to MIRMI LLM (should work)
echo ""
echo "Test 7: Local network access to MIRMI LLM (should WORK)..."
if curl -s -k https://mirmi-llm.mirmi.tum.de > /dev/null 2>&1; then
    echo "   ✅ PASSED: MIRMI LLM accessible from local network"
    PASS=$((PASS + 1))
else
    echo "   ⚠️  WARNING: Could not verify external access"
    echo "   (This may be normal if testing from the host)"
fi

# Test 8: Check iptables rules
echo ""
echo "Test 8: Firewall rules (checking)..."
if sudo iptables -L DOCKER-USER -n | grep -q "172.19.0.0/16"; then
    echo "   ✅ PASSED: Firewall rules are in place"
    PASS=$((PASS + 1))
else
    echo "   ⚠️  WARNING: Firewall rules may not be configured"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "   ✅ Passed: $PASS"
echo "   ❌ Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 All tests passed! Network isolation is working correctly."
    echo ""
    echo "✅ Security Status:"
    echo "   • MIRMI LLM: Isolated from internet"
    echo "   • Ollama (LLMs): Isolated from internet"
    echo "   • Local network: Can access services"
    echo "   • Host: Maintains internet access"
    echo ""
    echo "🔒 Your document classification system is secure!"
else
    echo "⚠️  Some tests failed. Please review the results above."
    echo ""
    echo "If isolation is not working:"
    echo "   1. Check docker-compose.yaml configuration"
    echo "   2. Verify iptables rules: sudo iptables -L DOCKER-USER -n"
    echo "   3. Restart containers: docker-compose restart"
    echo "   4. Re-run isolation script: sudo ./isolate-openwebui-network.sh"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
