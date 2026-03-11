# Network Isolation Plan for MIRMI LLM & LLMs

## 🎯 Security Requirement

**Goal:** Isolate MIRMI LLM and Ollama (LLMs) from internet access while:
- ✅ Keeping Ubuntu host internet access
- ✅ Allowing local network access (10.157.174.0/23)
- ✅ Maintaining service to local users
- ✅ Ensuring document classification security

## 📊 Current Architecture Analysis

### Network Configuration

```
Host Machine:
  - IP: 10.157.174.177/23
  - Gateway: 10.157.175.254
  - Interface: eno1
  - Internet: ✅ Has access

Docker Networks:
  1. mirmi-llm_internal_net (172.19.0.0/16)
     - Status: internal: true ✅
     - Containers: ollama (172.19.0.2)
     - Internet: ❌ Already blocked
  
  2. mirmi-llm_default (172.18.0.0/16)
     - Status: bridge (has internet)
     - Containers: mirmi-llm (172.18.0.3)
     - Internet: ⚠️  Currently has access

Nginx:
  - Listens: 443 (HTTPS)
  - Proxies to: 10.157.174.177:8080
  - Domain: mirmi-llm.mirmi.tum.de
```

### Current Security Status

✅ **Already Secure:**
- Ollama network is `internal: true` (no internet)
- Ollama cannot reach external networks
- Docker compose configured correctly

⚠️ **Needs Fixing:**
- MIRMI LLM container has internet access
- Port 8080 exposed on 0.0.0.0 (all interfaces)
- No explicit firewall rules for container isolation

## 🔒 Isolation Strategy

### Layer 1: Docker Network Isolation
- Keep `internal: true` for internal_net
- Ensure both containers on same internal network
- Remove any bridge networks with internet access

### Layer 2: Firewall Rules (iptables)
- Block containers from reaching internet
- Allow containers to local network only (10.157.174.0/23)
- Keep host internet access intact

### Layer 3: Port Binding
- Bind MIRMI LLM only to localhost or LAN IP
- Remove 0.0.0.0 bindings
- Nginx handles external access

### Layer 4: DNS Blocking
- Prevent containers from resolving external domains
- Keep local DNS only

## 🛠️ Implementation Steps

### Step 1: Update Docker Compose (Safe)
- Ensure both containers on internal network
- Remove any external network access
- Bind ports to specific interfaces

### Step 2: Apply Firewall Rules
- Create iptables rules for container isolation
- Test rules before making permanent
- Backup current rules

### Step 3: Update Nginx Configuration
- Ensure proper proxy headers
- Add security headers
- Restrict access to local network

### Step 4: Verify Isolation
- Test container internet access (should fail)
- Test local network access (should work)
- Test host internet access (should work)
- Test user access from local network (should work)

## 📋 Pre-Implementation Checklist

- [x] Analyze current network configuration
- [x] Identify security gaps
- [x] Design isolation strategy
- [ ] Backup current configuration
- [ ] Create rollback plan
- [ ] Test in staging (if available)
- [ ] Implement changes
- [ ] Verify isolation
- [ ] Document changes

## ⚠️ Risk Assessment

### Low Risk Changes
- ✅ Docker compose network configuration
- ✅ Port binding changes
- ✅ Firewall rules (with backup)

### Medium Risk Changes
- ⚠️  DNS configuration
- ⚠️  Network interface changes

### Zero Risk
- ✅ Host internet access (not affected)
- ✅ Local network access (preserved)
- ✅ Nginx configuration (minimal changes)

## 🔄 Rollback Plan

If something goes wrong:

1. **Docker Compose:**
   ```bash
   docker-compose down
   cp docker-compose.yaml.backup docker-compose.yaml
   docker-compose up -d
   ```

2. **Firewall Rules:**
   ```bash
   sudo iptables-restore < /etc/iptables/rules.v4.backup
   ```

3. **Nginx:**
   ```bash
   sudo cp /etc/nginx/sites-available/openwebui.backup /etc/nginx/sites-available/openwebui
   sudo systemctl reload nginx
   ```

## 📊 Expected Result

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet (Blocked)                        │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ ❌ Blocked
                              │
┌─────────────────────────────────────────────────────────────┐
│  Ubuntu Host (10.157.174.177)                                │
│  ✅ Has Internet Access                                      │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Nginx (443)                                         │   │
│  │  ✅ Accessible from local network                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                               │
│                              ▼                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Docker Internal Network (172.19.0.0/16)            │   │
│  │  ❌ No Internet Access                               │   │
│  │  ✅ Local Network Access (10.157.174.0/23)          │   │
│  │                                                       │   │
│  │  ┌──────────────────┐  ┌──────────────────┐        │   │
│  │  │  MIRMI LLM      │  │  Ollama (LLMs)   │        │   │
│  │  │  172.19.0.3      │  │  172.19.0.2      │        │   │
│  │  │  ❌ No Internet   │  │  ❌ No Internet   │        │   │
│  │  └──────────────────┘  └──────────────────┘        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ ✅ Allowed
                              │
┌─────────────────────────────────────────────────────────────┐
│         Local Network Users (10.157.174.0/23)                │
│         ✅ Can access MIRMI LLM via HTTPS                   │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Security Benefits

1. **Data Privacy:** Documents processed by LLMs never leave local network
2. **No Data Leakage:** LLMs cannot send data to external services
3. **Compliance:** Meets air-gap requirements for sensitive data
4. **Audit Trail:** All access is local and traceable
5. **Zero Trust:** Containers have minimal network access

## 📝 Next Steps

Ready to implement? Run:
```bash
sudo ./isolate-openwebui-network.sh
```

This will:
1. Backup all configurations
2. Apply network isolation
3. Test connectivity
4. Verify security
5. Provide rollback instructions if needed
