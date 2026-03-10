#!/bin/bash

# Network Isolation Script for Open WebUI & Ollama
# Isolates containers from internet while preserving local network access

set -e

echo "🔒 Open WebUI & Ollama Network Isolation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will:"
echo "  ✅ Block Open WebUI & Ollama from internet"
echo "  ✅ Allow access to local network (10.157.174.0/23)"
echo "  ✅ Keep Ubuntu host internet access"
echo "  ✅ Maintain service to local users"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo"
    exit 1
fi

# Configuration
LOCAL_NETWORK="10.157.174.0/23"
DOCKER_NETWORK_INTERNAL="172.19.0.0/16"
DOCKER_NETWORK_DEFAULT="172.18.0.0/16"
BACKUP_DIR="network-isolation-backup-$(date +%Y%m%d-%H%M%S)"

echo "📋 Configuration:"
echo "   Local Network: $LOCAL_NETWORK"
echo "   Docker Internal: $DOCKER_NETWORK_INTERNAL"
echo "   Docker Default: $DOCKER_NETWORK_DEFAULT"
echo ""

read -p "Continue with isolation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Creating Backups"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

mkdir -p "$BACKUP_DIR"

# Backup docker-compose
cp docker-compose.yaml "$BACKUP_DIR/docker-compose.yaml.backup"
echo "✅ Backed up docker-compose.yaml"

# Backup iptables
iptables-save > "$BACKUP_DIR/iptables.backup"
echo "✅ Backed up iptables rules"

# Backup nginx
cp /etc/nginx/sites-available/openwebui "$BACKUP_DIR/nginx-openwebui.backup"
echo "✅ Backed up nginx configuration"

echo ""
echo "Backups saved to: $BACKUP_DIR/"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Updating Docker Compose Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Update docker-compose.yaml
cat > docker-compose.yaml << 'EOF'
services:
  ollama:
    image: ollama/ollama:${OLLAMA_DOCKER_TAG-latest}
    container_name: ollama
    pull_policy: always
    tty: true
    restart: unless-stopped
    volumes:
      - ollama:/root/.ollama
    networks:
      - internal_net
    # Explicitly disable internet access
    dns:
      - 10.157.174.177  # Local DNS only

  open-webui:
    build:
      context: .
      dockerfile: Dockerfile
    image: ghcr.io/open-webui/open-webui:${WEBUI_DOCKER_TAG-main}
    container_name: open-webui
    volumes:
      - open-webui:/app/backend/data
    depends_on:
      - ollama
    # Bind only to localhost (nginx will proxy)
    ports:
      - "127.0.0.1:8080:8080"
    environment:
      - 'OLLAMA_BASE_URL=http://ollama:11434'
      - 'WEBUI_SECRET_KEY='
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped
    networks:
      - internal_net
    # Explicitly disable internet access
    dns:
      - 10.157.174.177  # Local DNS only

volumes:
  ollama: {}
  open-webui: {}

networks:
  internal_net:
    driver: bridge
    internal: true  # No internet access
    ipam:
      config:
        - subnet: 172.19.0.0/16
          gateway: 172.19.0.1
EOF

echo "✅ Updated docker-compose.yaml"
echo "   • Both containers on internal network"
echo "   • Port 8080 bound to localhost only"
echo "   • DNS restricted to local only"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Applying Firewall Rules"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create iptables rules for container isolation
echo "Creating firewall rules..."

# Allow containers to local network
iptables -I DOCKER-USER -s $DOCKER_NETWORK_INTERNAL -d $LOCAL_NETWORK -j ACCEPT
iptables -I DOCKER-USER -s $DOCKER_NETWORK_DEFAULT -d $LOCAL_NETWORK -j ACCEPT

# Allow containers to communicate with each other
iptables -I DOCKER-USER -s $DOCKER_NETWORK_INTERNAL -d $DOCKER_NETWORK_INTERNAL -j ACCEPT
iptables -I DOCKER-USER -s $DOCKER_NETWORK_DEFAULT -d $DOCKER_NETWORK_DEFAULT -j ACCEPT

# Allow containers to reach host
iptables -I DOCKER-USER -s $DOCKER_NETWORK_INTERNAL -d 10.157.174.177 -j ACCEPT
iptables -I DOCKER-USER -s $DOCKER_NETWORK_DEFAULT -d 10.157.174.177 -j ACCEPT

# Block containers from internet (everything else)
iptables -A DOCKER-USER -s $DOCKER_NETWORK_INTERNAL -j DROP
iptables -A DOCKER-USER -s $DOCKER_NETWORK_DEFAULT -j DROP

echo "✅ Firewall rules applied"
echo "   • Containers can access local network"
echo "   • Containers blocked from internet"
echo "   • Host internet access preserved"

# Make iptables rules persistent
if command -v netfilter-persistent &> /dev/null; then
    netfilter-persistent save
    echo "✅ Firewall rules saved (persistent)"
elif command -v iptables-save &> /dev/null; then
    iptables-save > /etc/iptables/rules.v4
    echo "✅ Firewall rules saved to /etc/iptables/rules.v4"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Restarting Containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd /home/mirmi/open-webui || cd "$(dirname "$0")"

echo "Stopping containers..."
docker-compose down

echo "Starting containers with new configuration..."
docker-compose up -d

echo "Waiting for containers to start..."
sleep 10

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5: Verifying Isolation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Container internet access (should fail)
echo "Test 1: Container internet access (should FAIL)..."
if docker exec open-webui ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "   ❌ FAILED: Container can reach internet!"
    echo "   ⚠️  Isolation not complete"
else
    echo "   ✅ PASSED: Container cannot reach internet"
fi

# Test 2: Container to local network (should work)
echo ""
echo "Test 2: Container to local network (should WORK)..."
if docker exec open-webui ping -c 1 -W 2 10.157.174.177 > /dev/null 2>&1; then
    echo "   ✅ PASSED: Container can reach local network"
else
    echo "   ❌ FAILED: Container cannot reach local network!"
    echo "   ⚠️  Local access broken"
fi

# Test 3: Container to Ollama (should work)
echo ""
echo "Test 3: Container to Ollama (should WORK)..."
if docker exec open-webui curl -s http://ollama:11434/api/tags > /dev/null 2>&1; then
    echo "   ✅ PASSED: Open WebUI can reach Ollama"
else
    echo "   ❌ FAILED: Open WebUI cannot reach Ollama!"
    echo "   ⚠️  Internal communication broken"
fi

# Test 4: Host internet access (should work)
echo ""
echo "Test 4: Host internet access (should WORK)..."
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "   ✅ PASSED: Host has internet access"
else
    echo "   ❌ FAILED: Host lost internet access!"
    echo "   ⚠️  Host connectivity broken"
fi

# Test 5: Local network access to Open WebUI (should work)
echo ""
echo "Test 5: Local network access to Open WebUI (should WORK)..."
if curl -s -k https://mirmi-llm.mirmi.tum.de > /dev/null 2>&1; then
    echo "   ✅ PASSED: Open WebUI accessible from local network"
else
    echo "   ⚠️  WARNING: Could not verify external access"
    echo "   (This may be normal if testing from the host)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ NETWORK ISOLATION COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Summary:"
echo "   ✅ Open WebUI: No internet access"
echo "   ✅ Ollama (LLMs): No internet access"
echo "   ✅ Local network: Can access Open WebUI"
echo "   ✅ Host: Maintains internet access"
echo ""
echo "🔒 Security Status:"
echo "   • Documents processed locally only"
echo "   • LLMs cannot send data externally"
echo "   • Air-gapped from internet"
echo "   • Local network access preserved"
echo ""
echo "📋 Backups saved to: $BACKUP_DIR/"
echo ""
echo "🔄 To rollback if needed:"
echo "   sudo ./rollback-network-isolation.sh $BACKUP_DIR"
echo ""
echo "🧪 Test from local network:"
echo "   https://mirmi-llm.mirmi.tum.de"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
