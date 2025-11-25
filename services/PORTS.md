# Port Allocation Reference

Complete reference for port allocation across all blockchain node services. This document helps avoid port conflicts when running multiple services simultaneously.

## Table of Contents

- [Port Allocation Strategy](#port-allocation-strategy)
- [Service Port Mappings](#service-port-mappings)
- [Internal Container Ports](#internal-container-ports)
- [Port Conflict Resolution](#port-conflict-resolution)

---

## Port Allocation Strategy

Ports are allocated using a **+10 offset strategy** to allow running multiple networks simultaneously on the same host:

- **Mainnet**: Standard ports (26656, 26657)
- **Testnet**: +10 offset (26666, 26667)
- **Other networks**: +20 or higher offsets (26676, 26677, etc.)

### Port Ranges

| Network Type | P2P Port (Host) | RPC Port (Host) | Internal P2P | Internal RPC |
|--------------|-----------------|-----------------|--------------|--------------|
| Mainnet      | 26656           | 26657           | 26656        | 26657        |
| Testnet      | 26666           | 26667           | 26656        | 26657        |
| Custom       | 26676+          | 26677+          | 26656        | 26657        |

**Note:** Internal container ports are always fixed (26656 for P2P, 26657 for RPC) regardless of the host port mapping.

---

## Service Port Mappings

### Infinite Mainnet

**Service Name:** `infinite-mainnet`  
**Container Name:** `infinite-mainnet`

| Port Type | Host Port | Container Port | Description |
|-----------|-----------|---------------|-------------|
| P2P       | 26656     | 26656         | Peer-to-peer network communication |
| RPC       | 26657     | 26657         | RPC API access |

**docker-compose.yml example:**
```yaml
ports:
  - "26656:26656"  # P2P
  - "26657:26657"  # RPC
```

---

### Infinite Testnet

**Service Name:** `infinite-testnet`  
**Container Name:** `infinite-testnet`

| Port Type | Host Port | Container Port | Description |
|-----------|-----------|---------------|-------------|
| P2P       | 26666     | 26656         | Peer-to-peer network communication |
| RPC       | 26667     | 26657         | RPC API access |

**docker-compose.yml example:**
```yaml
ports:
  - "26666:26656"  # P2P
  - "26667:26657"  # RPC
```

**Why different host ports?** Allows running both mainnet and testnet simultaneously without conflicts.

---

### QOM Network

**Service Name:** `qom-node`  
**Container Name:** `qom-node`

| Port Type | Host Port | Container Port | Description |
|-----------|-----------|---------------|-------------|
| P2P       | 26666     | 26656         | Peer-to-peer network communication |
| RPC       | 26667     | 26657         | RPC API access |

**docker-compose.yml example:**
```yaml
ports:
  - "26666:26656"  # P2P
  - "26667:26657"  # RPC
```

**Note:** QOM uses the same host ports as Infinite Testnet. If you need to run both simultaneously, change QOM's ports to 26676:26656 and 26677:26657.

---

## Internal Container Ports

**Important:** Internal container ports are **fixed** and should **never be changed**. These are hardcoded in the blockchain binaries.

| Port | Service | Description |
|------|---------|-------------|
| 26656 | P2P     | Peer-to-peer network communication (always) |
| 26657 | RPC     | RPC API access (always) |

**Why fixed?** The blockchain binaries are compiled with these ports hardcoded. Changing them would require recompiling the binary.

---

## Port Conflict Resolution

### Scenario 1: Running Mainnet and Testnet Simultaneously

**Solution:** Use different host ports (already configured)

```yaml
# Mainnet
ports:
  - "26656:26656"  # P2P
  - "26657:26657"  # RPC

# Testnet
ports:
  - "26666:26656"  # P2P (different host port)
  - "26667:26657"  # RPC (different host port)
```

✅ **No conflicts** - Different host ports, same container ports

---

### Scenario 2: Running Multiple Custom Networks

**Solution:** Use incremental +10 offsets

```yaml
# Network 1
ports:
  - "26656:26656"  # P2P
  - "26657:26657"  # RPC

# Network 2
ports:
  - "26666:26656"  # P2P (+10)
  - "26667:26657"  # RPC (+10)

# Network 3
ports:
  - "26676:26656"  # P2P (+20)
  - "26677:26657"  # RPC (+20)

# Network 4
ports:
  - "26686:26656"  # P2P (+30)
  - "26687:26657"  # RPC (+30)
```

---

### Scenario 3: Port Already in Use

**Error:** `Error: bind: address already in use`

**Solution:** Change the host port in `docker-compose.yml`

```yaml
# Original (conflict)
ports:
  - "26656:26656"

# Changed to available port
ports:
  - "26666:26656"  # Changed host port, container port stays the same
```

**Check available ports:**
```bash
# Check if port is in use
netstat -tuln | grep 26656
# or
ss -tuln | grep 26656
```

---

## Port Allocation Guidelines

### Recommended Port Ranges

| Network Type | Recommended Host Port Range |
|--------------|------------------------------|
| Mainnet      | 26656-26665 (P2P), 26657-26666 (RPC) |
| Testnet      | 26666-26675 (P2P), 26667-26676 (RPC) |
| Development  | 26676-26685 (P2P), 26677-26686 (RPC) |
| Custom       | 26686+ (P2P), 26687+ (RPC) |

### Port Selection Rules

1. **Always use +10 increments** for different networks
2. **Keep container ports fixed** (26656, 26657)
3. **Check for conflicts** before assigning new ports
4. **Document custom ports** in your service's README

---

## Quick Reference Table

| Service | Host P2P | Host RPC | Container P2P | Container RPC |
|---------|----------|----------|---------------|---------------|
| infinite-mainnet | 26656 | 26657 | 26656 | 26657 |
| infinite-testnet | 26666 | 26667 | 26656 | 26657 |
| qom-node | 26666 | 26667 | 26656 | 26657 |

**Note:** If running QOM and Infinite Testnet simultaneously, change QOM to 26676:26656 and 26677:26657.

---

## Firewall Configuration

If you're running a validator or want to accept incoming P2P connections, ensure these ports are open in your firewall:

### For Mainnet
```bash
# UFW (Ubuntu)
sudo ufw allow 26656/tcp  # P2P
sudo ufw allow 26657/tcp  # RPC (optional, only if exposing RPC)

# firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-port=26656/tcp
sudo firewall-cmd --permanent --add-port=26657/tcp
sudo firewall-cmd --reload
```

### For Testnet
```bash
# UFW (Ubuntu)
sudo ufw allow 26666/tcp  # P2P
sudo ufw allow 26667/tcp  # RPC (optional)
```

---

## Troubleshooting

### Port Already in Use

**Error:**
```
Error: bind: address already in use
```

**Solution:**
1. Find what's using the port: `sudo lsof -i :26656` or `sudo netstat -tulpn | grep 26656`
2. Change the host port in `docker-compose.yml`
3. Restart the service

---

### Cannot Connect to P2P Network

**Symptoms:**
- Node shows 0 peers
- Cannot sync blocks

**Possible Causes:**
1. Firewall blocking P2P port
2. Wrong port mapping in `docker-compose.yml`
3. NAT/firewall not configured for external address

**Solution:**
1. Check firewall: `sudo ufw status` or `sudo firewall-cmd --list-ports`
2. Verify port mapping: `docker compose ps` or `docker ps`
3. Configure `NODE_P2P_EXTERNAL_ADDRESS` if behind NAT

---

### RPC Not Accessible

**Symptoms:**
- Cannot access RPC API from host
- Connection refused errors

**Possible Causes:**
1. RPC port not mapped in `docker-compose.yml`
2. Firewall blocking RPC port
3. RPC only listening on localhost inside container

**Solution:**
1. Verify port mapping in `docker-compose.yml`
2. Check firewall rules
3. Test from inside container: `curl http://localhost:26657/status`

---

## See Also

- [ENVIRONMENT_VARIABLES.md](./ENVIRONMENT_VARIABLES.md) - Environment variables reference
- Service-specific README files in each service directory

