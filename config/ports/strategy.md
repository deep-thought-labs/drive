# Port Allocation Strategy

This document explains the port allocation strategy and logic for running multiple services simultaneously on the same host. For detailed port descriptions and service-specific configurations, see the related documents.

## Table of Contents

- [Understanding Port Mapping](#understanding-port-mapping)
- [Port Allocation Strategy](#port-allocation-strategy)
- [Service-Specific Configurations](#service-specific-configurations)
- [Port Conflict Resolution](#port-conflict-resolution)
- [Troubleshooting](#troubleshooting)

---

## Understanding Port Mapping

When configuring ports in `docker-compose.yml`, you'll see entries like this:

```yaml
ports:
  - "26656:26656"  # P2P
  - "26657:26657"  # RPC
```

### How Port Mapping Works

The format is: `"HOST_PORT:CONTAINER_PORT"`

- **Left number (HOST_PORT)**: This is the port on your computer/host system. **This is the one you can change** and **must be different** for each service running on your system. This is what you'll use to access the service from your host.

- **Right number (CONTAINER_PORT)**: This is the port **inside the Docker container**. **Never change this value** - it's what the service software expects and is configured in the service's internal settings. This value is fixed and recognized by the service's configuration.

### Why Different Host Ports?

If you want to run multiple services on the same computer, each one needs different host ports to avoid conflicts. The container ports stay the same (because the software inside expects those specific ports), but you map them to different host ports.

**Example:**
- Service 1: `"26656:26656"` - Uses host port 26656
- Service 2: `"26666:26656"` - Uses host port 26666 (different!), but container still uses 26656 internally

This way, both services can run simultaneously without conflicts!

---

## Port Allocation Strategy

### Service Numbering

Each service is assigned a **Service Number** starting from 0:

- **Service #0** = Mainnet (uses standard ports)
- **Service #1** = Testnet
- **Service #2** = Creative Network
- **Service #3** = QOM Network
- **relayer-hermes** = IBC Relayer (does not expose ports; outbound connections only)
- **Service #4+** = Future services (follow standard offset formula)
- And so on...

### Port Calculation Formula

For each port type, calculate the host port using:

**Host Port = Default Port + (Service Number × 10)**

**Example:**
- P2P default port is 26656
- Service #0 (Mainnet): 26656 + (0 × 10) = **26656**
- Service #1 (Testnet): 26656 + (1 × 10) = **26666**
- Service #2 (Creative): 26656 + (2 × 10) = **26676**

This simple formula ensures:
- ✅ No port conflicts between services
- ✅ Easy to remember and calculate
- ✅ Consistent across all port types
- ✅ Supports up to 10+ services without issues

---

## Service-Specific Configurations

Each preconfigured service has its own detailed configuration file with complete port mappings, Docker Compose examples, and firewall configurations:

- **[node0-infinite.md](./services/node0-infinite.md)** - Service #0: Infinite Mainnet
- **[node1-infinite-testnet.md](./services/node1-infinite-testnet.md)** - Service #1: Infinite Testnet
- **[node2-infinite-creative.md](./services/node2-infinite-creative.md)** - Service #2: Creative Network
- **[node3-qom.md](./services/node3-qom.md)** - Service #3: QOM Network
- **[relayer-hermes.md](./services/relayer-hermes.md)** - Relayer Hermes (IBC; no ports)

For detailed descriptions of what each port type does, see **[reference.md](./reference.md)**.

---

## Port Conflict Resolution

### Scenario 1: Port Already in Use

**Error:**
```
Error: bind: address already in use
```

**Solution:**
1. Find what's using the port: `sudo lsof -i :26656` or `sudo netstat -tulpn | grep 26656`
2. Change the host port in `docker-compose.yml` to the next available service number
3. Restart the service

**Example:**
If port 26656 is already in use, use Service #1 ports instead:
```yaml
ports:
  - "26666:26656"  # Changed host port, container port stays the same
```

---

### Scenario 2: Running Multiple Services Simultaneously

**Solution:** Each service must use a different Service Number

```yaml
# Service #0 (Mainnet)
ports:
  - "26656:26656"  # P2P
  - "26657:26657"  # RPC

# Service #1 (Testnet)
ports:
  - "26666:26656"  # P2P (different host port)
  - "26667:26657"  # RPC (different host port)

# Service #2 (Creative)
ports:
  - "26676:26656"  # P2P (different host port)
  - "26677:26657"  # RPC (different host port)
```

✅ **No conflicts** - Different host ports, same container ports

---

## Troubleshooting

### Cannot Connect to Service

**Symptoms:**
- Service shows connection errors
- Cannot establish network connections

**Possible Causes:**
1. Firewall blocking required port
2. Wrong port mapping in `docker-compose.yml`
3. NAT/firewall not configured for external address

**Solution:**
1. Check firewall: `sudo ufw status`
2. Verify port mapping: `docker compose ps` or `docker ps`
3. For blockchain nodes: Configure `NODE_P2P_EXTERNAL_ADDRESS` if behind NAT

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

- **[reference.md](./reference.md)** - Detailed descriptions of all port types
- **[services/node0-infinite.md](./services/node0-infinite.md)** - Mainnet port configuration
- **[services/node1-infinite-testnet.md](./services/node1-infinite-testnet.md)** - Testnet port configuration
- **[services/node2-infinite-creative.md](./services/node2-infinite-creative.md)** - Creative Network port configuration
- **[services/node3-qom.md](./services/node3-qom.md)** - QOM Network port configuration
- **[../environment/reference.md](../environment/reference.md)** - Environment variables reference
