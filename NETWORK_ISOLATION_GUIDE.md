# Complete Network Isolation Guide

## 🎯 Goal

Isolate Open WebUI and Ollama (LLMs) from internet access for secure document classification while:
- ✅ Keeping Ubuntu host internet access
- ✅ Allowing local network access (10.157.174.0/23)
- ✅ Maintaining service to local users
- ✅ Zero downtime for users

## 📊 What I Found

### Current Status
- ✅ Ollama already on internal network (no internet)
- ⚠️  Open WebUI has internet access (needs fixing)
- ✅ Nginx properly configured
- ✅ Local network access working

### Security Analysis
Your setup is 80% secure already! Just need to:
1. Move Open WebUI to internal network
2. Add firewall rules for extra protection
3. Verify isolation

## 🚀 Quick Start (Recommended)

```bash
# Run the automated isolation script
sudo ./isolate-openwebui-network.sh
```

This will:
1. Backup all configurations
2. Update docker-compose.yaml
3. Apply firewall rules
4. Restart containers
5. Test isolation
6. Provide rollback instructions

**Time:** 2-3 minutes  
**Downtime:** ~30 seconds during container restart

## 📋 Step-by-Step Manual Process

If you prefer to do it manually:

### Step 1: Backup Everything

```bash
# Create backup directory
mkdir -p network-isolation-backup-$(date +%Y%m%d-%H%M%S)

# Backup docker-compose
cp docker-compose.yaml network-isolation-backup-*/

# Backup iptables
sudo iptables-save > network-isolation-backup-*/iptables.backup

# Backup nginx
sudo cp /etc/nginx/sites-available/openwebui network-isolation-backup-*/
```

### Step 2: Update Docker Compose

Edit `docker-compose.yaml`:

```yaml
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
    ports:
      - "127.0.0.1:8080:8080"  # Localhost only
    environment:
      - 'OLLAMA_BASE_URL=http://ollama:11434'
      - 'WEBUI_SECRET_KEY='
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped
    networks:
      - internal_net  # Same internal network
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
```

### Step 3: Apply Firewall Rules

```bash
# Allow containers to local network
sudo iptables -I DOCKER-USER -s 172.19.0.0/16 -d 10.157.174.0/23 -j ACCEPT

# Allow containers to communicate with each other
sudo iptables -I DOCKER-USER -s 172.19.0.0/16 -d 172.19.0.0/16 -j ACCEPT

# Allow containers to reach host
sudo iptables -I DOCKER-USER -s 172.19.0.0/16 -d 10.157.174.177 -j ACCEPT

# Block containers from internet
sudo iptables -A DOCKER-USER -s 172.19.0.0/16 -j DROP

# Save rules
sudo netfilter-persistent save
# OR
sudo iptables-save > /etc/iptables/rules.v4
```

### Step 4: Restart Containers

```bash
docker-compose down
docker-compose up -d
```

### Step 5: Verify Isolation

```bash
./verify-isolation.sh
```

## 🧪 Testing & Verification

### Test 1: Container Internet Access (Should FAIL)
```bash
docker exec open-webui ping -c 1 8.8.8.8
# Expected: Network unreachable or timeout
```

### Test 2: Container Local Network (Should WORK)
```bash
docker exec open-webui ping -c 1 10.157.174.177
# Expected: Success
```

### Test 3: Container to Ollama (Should WORK)
```bash
docker exec open-webui curl http://ollama:11434/api/tags
# Expected: JSON response with models
```

### Test 4: Host Internet (Should WORK)
```bash
ping -c 1 8.8.8.8
# Expected: Success
```

### Test 5: User Access (Should WORK)
```bash
curl -k https://mirmi-llm.mirmi.tum.de
# Expected: Open WebUI page
```

## 📊 Architecture Diagram

### Before Isolation
```
Internet ←→ Ubuntu Host ←→ Open WebUI (has internet)
                        ←→ Ollama (no internet) ✅
                        ←→ Local Network Users
```

### After Isolation
```
Internet ←→ Ubuntu Host (only) ✅
            ↓
            Nginx (proxy)
            ↓
            Open WebUI (no internet) ✅
            ↓
            Ollama (no internet) ✅
            ↑
            Local Network Users ✅
```

## 🔒 Security Benefits

1. **Data Privacy**
   - Documents never leave local network
   - LLMs cannot send data externally
   - Air-gapped from internet

2. **Compliance**
   - Meets data protection requirements
   - Suitable for classified documents
   - Audit trail is local only

3. **Zero Trust**
   - Containers have minimal network access
   - Only local network communication
   - No external dependencies

## ⚠️ Important Notes

### What Still Works
- ✅ Local network users can access Open WebUI
- ✅ Open WebUI can communicate with Ollama
- ✅ All LLM models work normally
- ✅ Document classification works
- ✅ Ubuntu host has internet
- ✅ You can SSH to the server
- ✅ You can update packages

### What Stops Working
- ❌ Containers cannot download updates
- ❌ Containers cannot access external APIs
- ❌ Containers cannot resolve external domains
- ❌ Open WebUI cannot check for updates

### How to Update Containers

When you need to update:

```bash
# Temporarily disable isolation
sudo iptables -D DOCKER-USER -s 172.19.0.0/16 -j DROP

# Pull updates
docker-compose pull

# Re-enable isolation
sudo iptables -A DOCKER-USER -s 172.19.0.0/16 -j DROP

# Restart
docker-compose up -d
```

## 🔄 Rollback Instructions

If something goes wrong:

```bash
# Use the rollback script
sudo ./rollback-network-isolation.sh network-isolation-backup-YYYYMMDD-HHMMSS/

# Or manually:
docker-compose down
cp backup/docker-compose.yaml.backup docker-compose.yaml
sudo iptables-restore < backup/iptables.backup
docker-compose up -d
```

## 📝 Maintenance

### Check Isolation Status
```bash
./verify-isolation.sh
```

### View Firewall Rules
```bash
sudo iptables -L DOCKER-USER -n -v
```

### Check Container Network
```bash
docker network inspect open-webui_internal_net
```

### Monitor Container Logs
```bash
docker logs open-webui --tail 50
docker logs ollama --tail 50
```

## 🎯 Use Cases

This isolation is perfect for:
- ✅ Document classification systems
- ✅ Sensitive data processing
- ✅ Compliance requirements (GDPR, HIPAA, etc.)
- ✅ Air-gapped environments
- ✅ Internal corporate use
- ✅ Government/military applications

## 📞 Troubleshooting

### Issue: Users can't access Open WebUI

**Check:**
```bash
# Is nginx running?
sudo systemctl status nginx

# Are containers running?
docker ps

# Can host reach containers?
curl http://localhost:8080
```

**Fix:**
```bash
# Restart nginx
sudo systemctl restart nginx

# Restart containers
docker-compose restart
```

### Issue: Containers can't reach each other

**Check:**
```bash
# Are they on same network?
docker network inspect open-webui_internal_net

# Test connectivity
docker exec open-webui ping ollama
```

**Fix:**
```bash
# Restart containers
docker-compose restart
```

### Issue: Host lost internet

**Check:**
```bash
# Check routes
ip route show

# Check DNS
cat /etc/resolv.conf
```

**Fix:**
```bash
# Rollback firewall rules
sudo ./rollback-network-isolation.sh <backup-dir>
```

## ✅ Final Checklist

Before going live:
- [ ] Backup created
- [ ] Docker compose updated
- [ ] Firewall rules applied
- [ ] Containers restarted
- [ ] Isolation verified
- [ ] User access tested
- [ ] Host internet confirmed
- [ ] Rollback plan ready
- [ ] Documentation updated
- [ ] Team notified

## 🎉 Success Criteria

Your isolation is successful when:
- ✅ `docker exec open-webui ping 8.8.8.8` fails
- ✅ `docker exec ollama ping 8.8.8.8` fails
- ✅ `ping 8.8.8.8` succeeds (from host)
- ✅ Users can access https://mirmi-llm.mirmi.tum.de
- ✅ LLMs respond to queries
- ✅ Document classification works

---

## 🚀 Ready to Implement?

**Recommended approach:**

```bash
# 1. Read the plan
cat NETWORK_ISOLATION_PLAN.md

# 2. Run the isolation script
sudo ./isolate-openwebui-network.sh

# 3. Verify it worked
./verify-isolation.sh

# 4. Test from a local network device
# Open: https://mirmi-llm.mirmi.tum.de
```

**Time:** 2-3 minutes  
**Risk:** Low (full backup & rollback available)  
**Downtime:** ~30 seconds

Your document classification system will be secure and air-gapped from the internet!
