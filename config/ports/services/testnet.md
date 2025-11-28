# Port Configuration: Infinite Testnet

**Service Number:** 1  
**Service Name:** `infinite-testnet`  
**Container Name:** `infinite-testnet`

This document contains the complete port configuration for the Infinite Testnet service. All ports are calculated using the standard formula: `Host Port = Default Port + (Service Number × 10)`.

Since this is Service #1, all ports have a +10 offset from the default ports.

---

## Quick Reference

**Service Number:** 1  
**Port Offset:** +10

| Port Type | Host Port | Container Port |
|-----------|-----------|---------------|
| P2P | 26666 | 26656 |
| RPC | 26667 | 26657 |
| gRPC | 9100 | 9090 |
| gRPC-Web | 9101 | 9091 |
| REST API | 1327 | 1317 |
| JSON-RPC HTTP | 8555 | 8545 |
| JSON-RPC WS | 8556 | 8546 |

---

## Port Calculation

This service uses **Service Number 1**, so all ports have a +10 offset:

- **P2P**: 26656 + (1 × 10) = **26666**
- **RPC**: 26657 + (1 × 10) = **26667**
- **gRPC**: 9090 + (1 × 10) = **9100**
- **gRPC-Web**: 9091 + (1 × 10) = **9101**
- **REST API**: 1317 + (1 × 10) = **1327**
- **JSON-RPC HTTP**: 8545 + (1 × 10) = **8555**
- **JSON-RPC WebSocket**: 8546 + (1 × 10) = **8556**

---

## Required Ports

These ports must be configured for the service to function:

| Port Type | Host Port | Container Port | Description |
|-----------|-----------|---------------|-------------|
| **P2P** | 26666 | 26656 | Peer-to-peer network communication |
| **RPC** | 26667 | 26657 | Tendermint RPC API |

---

## Optional Ports

These ports can be enabled if needed for specific use cases:

| Port Type | Host Port | Container Port | Description | When to Enable |
|-----------|-----------|---------------|-------------|----------------|
| **gRPC** | 9100 | 9090 | Cosmos SDK gRPC queries | Public API endpoint, wallet connections |
| **gRPC-Web** | 9101 | 9091 | gRPC-Web (browser) | Web applications, browser wallets |
| **REST API** | 1327 | 1317 | Cosmos SDK REST API | Legacy application compatibility |
| **JSON-RPC HTTP** | 8555 | 8545 | Ethereum JSON-RPC (HTTP) | MetaMask, Ethereum tools, dApps |
| **JSON-RPC WebSocket** | 8556 | 8546 | Ethereum JSON-RPC (WebSocket) | Real-time blockchain events |
| **Prometheus** | 26670 | 26660 | Prometheus metrics | Node monitoring |
| **EVM Metrics** | 6075 | 6065 | EVM Prometheus metrics | EVM performance monitoring |
| **Geth Metrics** | 8110 | 8100 | Geth-compatible metrics | Geth monitoring tools |

---

## Docker Compose Configuration

### Minimal Configuration (Required Ports Only)

```yaml
services:
  infinite-testnet:
    ports:
      - "26666:26656"  # P2P (required)
      - "26667:26657"  # RPC (required)
```

### Full Configuration (All Ports)

```yaml
services:
  infinite-testnet:
    ports:
      # Required ports
      - "26666:26656"  # P2P
      - "26667:26657"  # RPC
      
      # Optional ports (uncomment if needed)
      - "9100:9090"    # gRPC
      - "9101:9091"    # gRPC-Web
      - "1327:1317"    # REST API
      - "8555:8545"    # JSON-RPC HTTP
      - "8556:8546"    # JSON-RPC WebSocket
      - "26670:26660"  # Prometheus
      - "6075:6065"    # EVM Metrics
      - "8110:8100"    # Geth Metrics
```

---

## Firewall Configuration

If you need to accept incoming connections from external networks, configure your firewall using UFW (Ubuntu):

### Required Ports

```bash
# P2P port (required for validators and peer connections)
sudo ufw allow 26666/tcp

# RPC port (optional, only if exposing RPC API)
sudo ufw allow 26667/tcp
```

### Optional Ports

```bash
# gRPC (if exposing gRPC API)
sudo ufw allow 9100/tcp

# gRPC-Web (if exposing gRPC-Web API)
sudo ufw allow 9101/tcp

# REST API (if exposing REST API)
sudo ufw allow 1327/tcp

# JSON-RPC HTTP (if exposing Ethereum-compatible API)
sudo ufw allow 8555/tcp

# JSON-RPC WebSocket (if exposing WebSocket API)
sudo ufw allow 8556/tcp

# Prometheus (if exposing metrics)
sudo ufw allow 26670/tcp

# EVM Metrics (if exposing EVM metrics)
sudo ufw allow 6075/tcp

# Geth Metrics (if exposing Geth metrics)
sudo ufw allow 8110/tcp
```

**Note:** The `/tcp` protocol specification is optional in UFW. You can use either `sudo ufw allow 26666/tcp` or `sudo ufw allow 26666` - both work the same way.

---

## See Also

- [../strategy.md](../strategy.md) - Port allocation strategy and general information
- [../reference.md](../reference.md) - Detailed port descriptions
