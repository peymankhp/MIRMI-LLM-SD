#!/bin/bash
# Safe installation script for Llama 3 and Qwen 2.5
# This script will backup, reconfigure, and install models safely

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "MIRMI LLM - Safe Model Installation"
echo "Llama 3 & Qwen 2.5 with API Access"
echo "==========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run as root${NC}"
    exit 1
fi

# Check if docker-compose exists
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}docker-compose not found. Please install it first.${NC}"
    exit 1
fi

# Step 1: Backup
echo -e "${YELLOW}Step 1: Creating backup...${NC}"
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backing up docker-compose.yaml..."
cp docker-compose.yaml "$BACKUP_DIR/"
echo -e "${GREEN}✓ Configuration backed up${NC}"

echo "Backing up MIRMI LLM data volume..."
docker run --rm -v mirmi-llm:/data -v "$(pwd)/$BACKUP_DIR":/backup alpine tar czf /backup/mirmi-llm-data.tar.gz -C /data . 2>/dev/null
echo -e "${GREEN}✓ MIRMI LLM data backed up${NC}"

echo "Backing up Ollama models (this may take several minutes)..."
docker run --rm -v ollama:/data -v "$(pwd)/$BACKUP_DIR":/backup alpine tar czf /backup/ollama-models.tar.gz -C /data . 2>/dev/null
echo -e "${GREEN}✓ Ollama models backed up${NC}"

echo -e "${GREEN}Backup completed: $BACKUP_DIR${NC}"
echo ""

# Step 2: Analyze current setup
echo -e "${YELLOW}Step 2: Analyzing current setup...${NC}"

echo "Current containers:"
docker ps --filter "name=mirmi-llm" --filter "name=ollama" --format "table {{.Names}}\t{{.Status}}"
echo ""

echo "Current models:"
docker exec ollama ollama list
echo ""

echo "GPU Status:"
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader
echo ""

# Check if host Ollama is running
if systemctl is-active --quiet ollama 2>/dev/null; then
    echo -e "${YELLOW}⚠ Host-level Ollama service is running${NC}"
    HAS_HOST_OLLAMA=true
else
    echo -e "${GREEN}✓ No host-level Ollama service conflict${NC}"
    HAS_HOST_OLLAMA=false
fi
echo ""

# Step 3: Confirm installation
echo -e "${YELLOW}Step 3: Installation Plan${NC}"
echo "This script will:"
echo "  1. Modify docker-compose.yaml to expose Ollama API on port 11434"
echo "  2. Change network from internal to external access"
echo "  3. Stop host-level Ollama service (if running)"
echo "  4. Recreate containers with new configuration"
echo "  5. Install Llama 3 (8B) - ~4.7GB download"
echo "  6. Install Qwen 2.5 (7B) - ~4.7GB download"
echo ""
echo -e "${BLUE}Note: Your MIRMI LLM will remain accessible during this process${NC}"
echo -e "${BLUE}Backup location: $BACKUP_DIR${NC}"
echo ""

read -p "Do you want to proceed? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi
echo ""

# Step 4: Stop host Ollama if running
if [ "$HAS_HOST_OLLAMA" = true ]; then
    echo -e "${YELLOW}Step 4: Stopping host-level Ollama service...${NC}"
    echo "This prevents port conflicts with the container."
    read -p "Stop and disable host-level Ollama? (yes/no): " -r
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        sudo systemctl stop ollama
        sudo systemctl disable ollama
        echo -e "${GREEN}✓ Host-level Ollama stopped and disabled${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: Port 11434 may conflict${NC}"
    fi
else
    echo -e "${GREEN}Step 4: Skipped (no host Ollama service)${NC}"
fi
echo ""

# Step 5: Update docker-compose.yaml
echo -e "${YELLOW}Step 5: Updating docker-compose.yaml...${NC}"

# Create updated docker-compose.yaml
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
    ports:
      - "11434:11434"
    networks:
      - internal_net

  mirmi-llm:
    build:
      context: .
      dockerfile: Dockerfile
    image: ghcr.io/mirmi-llm/mirmi-llm:${WEBUI_DOCKER_TAG-main}
    container_name: mirmi-llm
    volumes:
      - mirmi-llm:/app/backend/data
    depends_on:
      - ollama
    ports:
      - "127.0.0.1:8081:8080"
    environment:
      - 'OLLAMA_BASE_URL=http://ollama:11434'
      - 'WEBUI_SECRET_KEY='
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped
    networks:
      - internal_net

volumes:
  ollama: {}
  mirmi-llm: {}

networks:
  internal_net:
    driver: bridge
    internal: false
EOF

echo -e "${GREEN}✓ docker-compose.yaml updated${NC}"
echo ""

# Step 6: Recreate containers
echo -e "${YELLOW}Step 6: Recreating containers with new configuration...${NC}"
docker-compose up -d

echo "Waiting for services to start..."
sleep 10

# Verify Ollama is accessible
MAX_RETRIES=12
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Ollama API is accessible on localhost:11434${NC}"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        echo -e "${RED}✗ Failed to access Ollama API after $MAX_RETRIES attempts${NC}"
        echo "Please check: docker logs ollama"
        exit 1
    fi
    echo "Waiting for Ollama to be ready... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 5
done
echo ""

# Step 7: Install models
echo -e "${YELLOW}Step 7: Installing models...${NC}"
echo ""

echo "Installing Llama 3 (8B)..."
echo "This will download ~4.7GB and may take several minutes..."
docker exec ollama ollama pull llama3:8b
echo -e "${GREEN}✓ Llama 3 (8B) installed${NC}"
echo ""

echo "Installing Qwen 2.5 (7B)..."
echo "This will download ~4.7GB and may take several minutes..."
docker exec ollama ollama pull qwen2.5:7b
echo -e "${GREEN}✓ Qwen 2.5 (7B) installed${NC}"
echo ""

# Step 8: Verify installation
echo -e "${YELLOW}Step 8: Verifying installation...${NC}"
echo ""

echo "All available models:"
docker exec ollama ollama list
echo ""

echo "Testing API access from host..."
if curl -s http://localhost:11434/api/tags | grep -q "models"; then
    echo -e "${GREEN}✓ Ollama API is accessible from host${NC}"
else
    echo -e "${RED}✗ Cannot access Ollama API from host${NC}"
fi
echo ""

echo "Testing model generation..."
RESPONSE=$(curl -s http://localhost:11434/api/generate -d '{
  "model": "llama3:8b",
  "prompt": "Say hello in one word",
  "stream": false
}' | grep -o '"response":"[^"]*"' | head -1)

if [ -n "$RESPONSE" ]; then
    echo -e "${GREEN}✓ Model generation working${NC}"
    echo "Response: $RESPONSE"
else
    echo -e "${YELLOW}⚠ Could not verify model generation${NC}"
fi
echo ""

# Step 9: Display configuration
echo -e "${GREEN}=========================================="
echo "Installation Completed Successfully!"
echo "==========================================${NC}"
echo ""
echo -e "${BLUE}MIRMI LLM Access:${NC}"
echo "  URL: http://localhost:8081"
echo "  The new models should appear in the model dropdown"
echo ""
echo -e "${BLUE}Ollama API Configuration (for Cursor, etc.):${NC}"
echo "  Base URL: http://localhost:11434/v1"
echo "  API Key: ollama (or any value)"
echo ""
echo -e "${BLUE}Available Models:${NC}"
echo "  - llama3:8b (NEW)"
echo "  - qwen2.5:7b (NEW)"
echo "  - qwen2:7b-instruct"
echo "  - llama2:13b-chat"
echo "  - mixtral:8x7b-instruct-v0.1-q4_0"
echo "  - mistral:7b-instruct"
echo "  - (and all your other existing models)"
echo ""
echo -e "${BLUE}For Remote Access (from another machine):${NC}"
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "  Base URL: http://$SERVER_IP:11434/v1"
echo "  Note: Configure firewall to allow port 11434 from trusted IPs only"
echo ""
echo -e "${BLUE}Firewall Configuration (if needed):${NC}"
echo "  sudo ufw allow from <trusted-ip> to any port 11434"
echo "  sudo ufw allow from 192.168.1.0/24 to any port 11434  # For local network"
echo ""
echo -e "${BLUE}Backup Information:${NC}"
echo "  Location: $BACKUP_DIR"
echo "  Files: docker-compose.yaml, mirmi-llm-data.tar.gz, ollama-models.tar.gz"
echo ""
echo -e "${YELLOW}To rollback if needed:${NC}"
echo "  docker-compose down"
echo "  cp $BACKUP_DIR/docker-compose.yaml ./"
echo "  docker-compose up -d"
echo ""
echo -e "${GREEN}Enjoy your new models! 🚀${NC}"
