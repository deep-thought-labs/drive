# Port Configuration: Infinite Mainnet

**Service Number:** 0  
**Service Name:** `infinite`  
**Container Name:** `infinite`

This document contains the complete port configuration for the Infinite Mainnet service. All ports are calculated using the standard formula: `Host Port = Default Port + (Service Number × 10)`.

Since this is Service #0 (Mainnet), it uses the standard/default ports.

---

## Quick Reference

**Service Number:** 0  
**Port Offset:** +0 (standard ports)

| Port Type | Host Port | Container Port |
|-----------|-----------|---------------|
| P2P | 26656 | 26656 |
| RPC | 26657 | 26657 |
| gRPC | 9090 | 9090 |
| gRPC-Web | 9091 | 9091 |
| REST API | 1317 | 1317 |
| JSON-RPC HTTP | 8545 | 8545 |
| JSON-RPC WS | 8546 | 8546 |

---

## Port Calculation

This service uses **Service Number 0**, so all ports use the default values:

- **P2P**: 26656 + (0 × 10) = **26656**
- **RPC**: 26657 + (0 × 10) = **26657**
- **gRPC**: 9090 + (0 × 10) = **9090**
- **gRPC-Web**: 9091 + (0 × 10) = **9091**
- **REST API**: 1317 + (0 × 10) = **1317**
- **JSON-RPC HTTP**: 8545 + (0 × 10) = **8545**
- **JSON-RPC WebSocket**: 8546 + (0 × 10) = **8546**

---

## Required Ports

These ports must be configured for the service to function:

| Port Type | Host Port | Container Port | Description |
|-----------|-----------|---------------|-------------|
| **P2P** | 26656 | 26656 | Peer-to-peer network communication |
| **RPC** | 26657 | 26657 | Tendermint RPC API |

---

## Optional Ports

These ports can be enabled if needed for specific use cases:

| Port Type | Host Port | Container Port | Description | When to Enable |
|-----------|-----------|---------------|-------------|----------------|
| **gRPC** | 9090 | 9090 | Cosmos SDK gRPC queries | Public API endpoint, wallet connections |
| **gRPC-Web** | 9091 | 9091 | gRPC-Web (browser) | Web applications, browser wallets |
| **REST API** | 1317 | 1317 | Cosmos SDK REST API | Legacy application compatibility |
| **JSON-RPC HTTP** | 8545 | 8545 | Ethereum JSON-RPC (HTTP) | MetaMask, Ethereum tools, dApps |
| **JSON-RPC WebSocket** | 8546 | 8546 | Ethereum JSON-RPC (WebSocket) | Real-time blockchain events |
| **Prometheus** | 26660 | 26660 | Prometheus metrics | Node monitoring |
| **EVM Metrics** | 6065 | 6065 | EVM Prometheus metrics | EVM performance monitoring |
| **Geth Metrics** | 8100 | 8100 | Geth-compatible metrics | Geth monitoring tools |

---

## Docker Compose Configuration

### Minimal Configuration (Required Ports Only)

```yaml
services:
  infinite:
    ports:
      - "26656:26656"  # P2P (required)
      - "26657:26657"  # RPC (required)
```

### Full Configuration (All Ports)

```yaml
services:
  infinite:
    ports:
      # Required ports
      - "26656:26656"  # P2P
      - "26657:26657"  # RPC
      
      # Optional ports (uncomment if needed)
      - "9090:9090"    # gRPC
      - "9091:9091"    # gRPC-Web
      - "1317:1317"    # REST API
      - "8545:8545"    # JSON-RPC HTTP
      - "8546:8546"    # JSON-RPC WebSocket
      - "26660:26660"  # Prometheus
      - "6065:6065"    # EVM Metrics
      - "8100:8100"    # Geth Metrics
```

---

## Firewall Configuration

If you need to accept incoming connections from external networks, configure your firewall using UFW (Ubuntu):

### Required Ports

```bash
# P2P port (required for validators and peer connections)
sudo ufw allow 26656/tcp

# RPC port (optional, only if exposing RPC API)
sudo ufw allow 26657/tcp
```

### Optional Ports

```bash
# gRPC (if exposing gRPC API)
sudo ufw allow 9090/tcp

# gRPC-Web (if exposing gRPC-Web API)
sudo ufw allow 9091/tcp

# REST API (if exposing REST API)
sudo ufw allow 1317/tcp

# JSON-RPC HTTP (if exposing Ethereum-compatible API)
sudo ufw allow 8545/tcp

# JSON-RPC WebSocket (if exposing WebSocket API)
sudo ufw allow 8546/tcp

# Prometheus (if exposing metrics)
sudo ufw allow 26660/tcp

# EVM Metrics (if exposing EVM metrics)
sudo ufw allow 6065/tcp

# Geth Metrics (if exposing Geth metrics)
sudo ufw allow 8100/tcp
```

**Note:** The `/tcp` protocol specification is optional in UFW. You can use either `sudo ufw allow 26656/tcp` or `sudo ufw allow 26656` - both work the same way.

---

## See Also

- [../strategy.md](../strategy.md) - Port allocation strategy and general information
- [../reference.md](../reference.md) - Detailed port descriptions
