# Port Configuration: Infinite Creative Network

**Service Number:** 2  
**Service Name:** `infinite-creative`  
**Container Name:** `infinite-creative`

This document contains the complete port configuration for the Infinite Creative Network service. All ports are calculated using the standard formula: `Host Port = Default Port + (Service Number × 10)`.

Since this is Service #2, all ports have a +20 offset from the default ports.

---

## Quick Reference

**Service Number:** 2  
**Port Offset:** +20

| Port Type | Host Port | Container Port |
|-----------|-----------|---------------|
| P2P | 26676 | 26656 |
| RPC | 26677 | 26657 |
| gRPC | 9110 | 9090 |
| gRPC-Web | 9111 | 9091 |
| REST API | 1337 | 1317 |
| JSON-RPC HTTP | 8565 | 8545 |
| JSON-RPC WS | 8566 | 8546 |

---

## Port Calculation

This service uses **Service Number 2**, so all ports have a +20 offset:

- **P2P**: 26656 + (2 × 10) = **26676**
- **RPC**: 26657 + (2 × 10) = **26677**
- **gRPC**: 9090 + (2 × 10) = **9110**
- **gRPC-Web**: 9091 + (2 × 10) = **9111**
- **REST API**: 1317 + (2 × 10) = **1337**
- **JSON-RPC HTTP**: 8545 + (2 × 10) = **8565**
- **JSON-RPC WebSocket**: 8546 + (2 × 10) = **8566**

---

## Required Ports

These ports must be configured for the service to function:

| Port Type | Host Port | Container Port | Description |
|-----------|-----------|---------------|-------------|
| **P2P** | 26676 | 26656 | Peer-to-peer network communication |
| **RPC** | 26677 | 26657 | Tendermint RPC API |

---

## Optional Ports

These ports can be enabled if needed for specific use cases:

| Port Type | Host Port | Container Port | Description | When to Enable |
|-----------|-----------|---------------|-------------|----------------|
| **gRPC** | 9110 | 9090 | Cosmos SDK gRPC queries | Public API endpoint, wallet connections |
| **gRPC-Web** | 9111 | 9091 | gRPC-Web (browser) | Web applications, browser wallets |
| **REST API** | 1337 | 1317 | Cosmos SDK REST API | Legacy application compatibility |
| **JSON-RPC HTTP** | 8565 | 8545 | Ethereum JSON-RPC (HTTP) | MetaMask, Ethereum tools, dApps |
| **JSON-RPC WebSocket** | 8566 | 8546 | Ethereum JSON-RPC (WebSocket) | Real-time blockchain events |
| **Prometheus** | 26680 | 26660 | Prometheus metrics | Node monitoring |
| **EVM Metrics** | 6085 | 6065 | EVM Prometheus metrics | EVM performance monitoring |
| **Geth Metrics** | 8120 | 8100 | Geth-compatible metrics | Geth monitoring tools |

---

## Docker Compose Configuration

### Minimal Configuration (Required Ports Only)

```yaml
services:
  infinite-creative:
    ports:
      - "26676:26656"  # P2P (required)
      - "26677:26657"  # RPC (required)
```

### Full Configuration (All Ports)

```yaml
services:
  infinite-creative:
    ports:
      # Required ports
      - "26676:26656"  # P2P
      - "26677:26657"  # RPC
      
      # Optional ports (uncomment if needed)
      - "9110:9090"    # gRPC
      - "9111:9091"    # gRPC-Web
      - "1337:1317"    # REST API
      - "8565:8545"    # JSON-RPC HTTP
      - "8566:8546"    # JSON-RPC WebSocket
      - "26680:26660"  # Prometheus
      - "6085:6065"    # EVM Metrics
      - "8120:8100"    # Geth Metrics
```

---

## Firewall Configuration

If you need to accept incoming connections from external networks, configure your firewall using UFW (Ubuntu):

### Required Ports

```bash
# P2P port (required for validators and peer connections)
sudo ufw allow 26676/tcp

# RPC port (optional, only if exposing RPC API)
sudo ufw allow 26677/tcp
```

### Optional Ports

```bash
# gRPC (if exposing gRPC API)
sudo ufw allow 9110/tcp

# gRPC-Web (if exposing gRPC-Web API)
sudo ufw allow 9111/tcp

# REST API (if exposing REST API)
sudo ufw allow 1337/tcp

# JSON-RPC HTTP (if exposing Ethereum-compatible API)
sudo ufw allow 8565/tcp

# JSON-RPC WebSocket (if exposing WebSocket API)
sudo ufw allow 8566/tcp

# Prometheus (if exposing metrics)
sudo ufw allow 26680/tcp

# EVM Metrics (if exposing EVM metrics)
sudo ufw allow 6085/tcp

# Geth Metrics (if exposing Geth metrics)
sudo ufw allow 8120/tcp
```

**Note:** The `/tcp` protocol specification is optional in UFW. You can use either `sudo ufw allow 26676/tcp` or `sudo ufw allow 26676` - both work the same way.

---

## See Also

- [../strategy.md](../strategy.md) - Port allocation strategy and general information
- [../reference.md](../reference.md) - Detailed port descriptions
