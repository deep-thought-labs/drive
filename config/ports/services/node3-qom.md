# Port Configuration: QOM Network

**Service Number:** 3  
**Service Name:** `qom`  
**Container Name:** `qom`

This document contains the complete port configuration for the QOM Network service. All ports are calculated using the standard formula: `Host Port = Default Port + (Service Number × 10)`.

Since this is Service #3, all ports have a +30 offset from the default ports.

---

## Quick Reference

**Service Number:** 3  
**Port Offset:** +30

| Port Type | Host Port | Container Port |
|-----------|-----------|---------------|
| P2P | 26686 | 26656 |
| RPC | 26687 | 26657 |
| gRPC | 9120 | 9090 |
| gRPC-Web | 9121 | 9091 |
| REST API | 1347 | 1317 |
| JSON-RPC HTTP | 8575 | 8545 |
| JSON-RPC WS | 8576 | 8546 |

---

## Port Calculation

This service uses **Service Number 3**, so all ports have a +30 offset:

- **P2P**: 26656 + (3 × 10) = **26686**
- **RPC**: 26657 + (3 × 10) = **26687**
- **gRPC**: 9090 + (3 × 10) = **9120**
- **gRPC-Web**: 9091 + (3 × 10) = **9121**
- **REST API**: 1317 + (3 × 10) = **1347**
- **JSON-RPC HTTP**: 8545 + (3 × 10) = **8575**
- **JSON-RPC WebSocket**: 8546 + (3 × 10) = **8576**

---

## Required Ports

These ports must be configured for the service to function:

| Port Type | Host Port | Container Port | Description |
|-----------|-----------|---------------|-------------|
| **P2P** | 26686 | 26656 | Peer-to-peer network communication |
| **RPC** | 26687 | 26657 | Tendermint RPC API |

---

## Optional Ports

These ports can be enabled if needed for specific use cases:

| Port Type | Host Port | Container Port | Description | When to Enable |
|-----------|-----------|---------------|-------------|----------------|
| **gRPC** | 9120 | 9090 | Cosmos SDK gRPC queries | Public API endpoint, wallet connections |
| **gRPC-Web** | 9121 | 9091 | gRPC-Web (browser) | Web applications, browser wallets |
| **REST API** | 1347 | 1317 | Cosmos SDK REST API | Legacy application compatibility |
| **JSON-RPC HTTP** | 8575 | 8545 | Ethereum JSON-RPC (HTTP) | MetaMask, Ethereum tools, dApps |
| **JSON-RPC WebSocket** | 8576 | 8546 | Ethereum JSON-RPC (WebSocket) | Real-time blockchain events |
| **Prometheus** | 26690 | 26660 | Prometheus metrics | Node monitoring |
| **EVM Metrics** | 6095 | 6065 | EVM Prometheus metrics | EVM performance monitoring |
| **Geth Metrics** | 8130 | 8100 | Geth-compatible metrics | Geth monitoring tools |

---

## Docker Compose Configuration

### Minimal Configuration (Required Ports Only)

```yaml
services:
  qom:
    ports:
      - "26686:26656"  # P2P (required)
      - "26687:26657"  # RPC (required)
```

### Full Configuration (All Ports)

```yaml
services:
  qom:
    ports:
      # Required ports
      - "26686:26656"  # P2P
      - "26687:26657"  # RPC
      
      # Optional ports (uncomment if needed)
      - "9120:9090"    # gRPC
      - "9121:9091"    # gRPC-Web
      - "1347:1317"    # REST API
      - "8575:8545"    # JSON-RPC HTTP
      - "8576:8546"    # JSON-RPC WebSocket
      - "26690:26660"  # Prometheus
      - "6095:6065"    # EVM Metrics
      - "8130:8100"    # Geth Metrics
```

---

## Firewall Configuration

If you need to accept incoming connections from external networks, configure your firewall using UFW (Ubuntu):

### Required Ports

```bash
# P2P port (required for validators and peer connections)
sudo ufw allow 26686/tcp

# RPC port (optional, only if exposing RPC API)
sudo ufw allow 26687/tcp
```

### Optional Ports

```bash
# gRPC (if exposing gRPC API)
sudo ufw allow 9120/tcp

# gRPC-Web (if exposing gRPC-Web API)
sudo ufw allow 9121/tcp

# REST API (if exposing REST API)
sudo ufw allow 1347/tcp

# JSON-RPC HTTP (if exposing Ethereum-compatible API)
sudo ufw allow 8575/tcp

# JSON-RPC WebSocket (if exposing WebSocket API)
sudo ufw allow 8576/tcp

# Prometheus (if exposing metrics)
sudo ufw allow 26690/tcp

# EVM Metrics (if exposing EVM metrics)
sudo ufw allow 6095/tcp

# Geth Metrics (if exposing Geth metrics)
sudo ufw allow 8130/tcp
```

**Note:** The `/tcp` protocol specification is optional in UFW. You can use either `sudo ufw allow 26686/tcp` or `sudo ufw allow 26686` - both work the same way.

---

## See Also

- [../strategy.md](../strategy.md) - Port allocation strategy and general information
- [../reference.md](../reference.md) - Detailed port descriptions

