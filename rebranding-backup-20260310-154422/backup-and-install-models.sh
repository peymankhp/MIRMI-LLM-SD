#!/bin/bash
set -e

echo "=========================================="
echo "Open WebUI - Safe Model Installation"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Backup directory with timestamp
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

echo -e "${YELLOW}Step 1: Creating backup...${NC}"
mkdir -p "$BACKUP_DIR"

# Backup docker-compose configuration
if [ -f "docker-compose.yaml" ]; then
    cp docker-compose.yaml "$BACKUP_DIR/"
    echo "✓ Backed up docker-compose.yaml"
fi

# Backup Open WebUI data volume
echo "Creating Open WebUI data backup..."
docker run --rm -v open-webui:/data -v "$(pwd)/$BACKUP_DIR":/backup alpine tar czf /backup/open-webui-data.tar.gz -C /data .
echo "✓ Backed up Open WebUI data volume"

# Backup Ollama models volume
echo "Creating Ollama models backup (this may take a while)..."
docker run --rm -v ollama:/data -v "$(pwd)/$BACKUP_DIR":/backup alpine tar czf /backup/ollama-models.tar.gz -C /data .
echo "✓ Backed up Ollama models volume"

echo -e "${GREEN}Backup completed: $BACKUP_DIR${NC}"
echo ""

# Check current setup
echo -e "${YELLOW}Step 2: Analyzing current setup...${NC}"
echo "Current containers:"
docker ps --filter "name=open-webui" --filter "name=ollama" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "Current models in Ollama container:"
docker exec ollama ollama list
echo ""

echo "System resources:"
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader
echo ""

# Check if Ollama port is exposed
OLLAMA_PORTS=$(docker port ollama 2>/dev/null || echo "")
if [ -z "$OLLAMA_PORTS" ]; then
    echo -e "${YELLOW}⚠ Ollama container does NOT have port 11434 exposed to host${NC}"
    NEEDS_RECONFIGURE=true
else
    echo -e "${GREEN}✓ Ollama port is already exposed${NC}"
    NEEDS_RECONFIGURE=false
fi
echo ""

# Check host-level Ollama service
if systemctl is-active --quiet ollama 2>/dev/null; then
    echo -e "${YELLOW}⚠ Host-level Ollama service is running (may cause conflicts)${NC}"
    HAS_HOST_OLLAMA=true
else
    echo -e "${GREEN}✓ No host-level Ollama service detected${NC}"
    HAS_HOST_OLLAMA=false
fi
echo ""

echo -e "${YELLOW}Step 3: Installation plan${NC}"
echo "The following will be installed:"
echo "  - Llama 3 (8B model, ~4.7GB)"
echo "  - Qwen 2.5 (7B model, ~4.7GB)"
echo ""
echo "Note: You already have qwen2:7b-instruct installed"
echo ""

read -p "Do you want to proceed with the installation? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Step 4: Reconfigure if needed
if [ "$NEEDS_RECONFIGURE" = true ]; then
    echo -e "${YELLOW}Step 4: Reconfiguring Ollama container to expose API...${NC}"
    
    # Update docker-compose.yaml to expose Ollama port
    if [ -f "docker-compose.yaml" ]; then
        echo "Updating docker-compose.yaml to expose Ollama port..."
        
        # Check if ports section exists for ollama
        if grep -A 10 "^  ollama:" docker-compose.yaml | grep -q "ports:"; then
            echo "Ports section already exists, skipping modification"
        else
            # Add ports section after networks in ollama service
            sed -i '/^  ollama:/,/^  [a-z]/ {
                /networks:/a\    ports:\n      - "11434:11434"
            }' docker-compose.yaml
            echo "✓ Updated docker-compose.yaml"
        fi
    fi
    
    echo "Recreating Ollama container with port exposure..."
    docker-compose up -d ollama
    
    echo "Waiting for Ollama to be ready..."
    sleep 5
    
    # Verify Ollama is accessible
    if curl -s http://localhost:11434/api/tags > /dev/null; then
        echo -e "${GREEN}✓ Ollama API is now accessible on localhost:11434${NC}"
    else
        echo -e "${RED}✗ Failed to access Ollama API${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Step 4: Skipped (Ollama already configured)${NC}"
fi
echo ""

# Step 5: Stop host-level Ollama if running
if [ "$HAS_HOST_OLLAMA" = true ]; then
    echo -e "${YELLOW}Step 5: Stopping host-level Ollama service...${NC}"
    read -p "Stop and disable host-level Ollama service? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo systemctl stop ollama
        sudo systemctl disable ollama
        echo -e "${GREEN}✓ Host-level Ollama service stopped and disabled${NC}"
    else
        echo -e "${YELLOW}⚠ Keeping host-level Ollama running (may cause port conflicts)${NC}"
    fi
else
    echo -e "${GREEN}Step 5: Skipped (no host-level Ollama)${NC}"
fi
echo ""

# Step 6: Install models
echo -e "${YELLOW}Step 6: Installing models...${NC}"

echo "Installing Llama 3 (8B)..."
docker exec -it ollama ollama pull llama3:8b
echo -e "${GREEN}✓ Llama 3 installed${NC}"

echo "Installing Qwen 2.5 (7B)..."
docker exec -it ollama ollama pull qwen2.5:7b
echo -e "${GREEN}✓ Qwen 2.5 installed${NC}"

echo ""
echo -e "${YELLOW}Step 7: Verifying installation...${NC}"
echo "Available models:"
docker exec ollama ollama list
echo ""

# Test API access
echo "Testing Ollama API access from host..."
if curl -s http://localhost:11434/api/tags | grep -q "models"; then
    echo -e "${GREEN}✓ Ollama API is accessible from host${NC}"
else
    echo -e "${RED}✗ Cannot access Ollama API from host${NC}"
fi
echo ""

echo -e "${GREEN}=========================================="
echo "Installation completed successfully!"
echo "==========================================${NC}"
echo ""
echo "Configuration for external API access:"
echo "  Base URL: http://localhost:11434/v1"
echo "  API Key: (any value, e.g., 'ollama')"
echo "  Models available:"
echo "    - llama3:8b"
echo "    - qwen2.5:7b"
echo "    - (all your existing models)"
echo ""
echo "For remote access (from another machine):"
echo "  Base URL: http://$(hostname -I | awk '{print $1}'):11434/v1"
echo "  Note: Ensure firewall allows port 11434"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
echo "To restore from backup if needed:"
echo "  docker-compose down"
echo "  docker volume rm open-webui ollama"
echo "  docker run --rm -v open-webui:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar xzf /backup/open-webui-data.tar.gz -C /data"
echo "  docker run --rm -v ollama:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar xzf /backup/ollama-models.tar.gz -C /data"
echo "  docker-compose up -d"
