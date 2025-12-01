# Port Reference Guide

This document provides detailed descriptions of all port types that services may use. This is a reference guide for understanding what each port does and when it might be needed.

## Table of Contents

- [Core Tendermint/CometBFT Ports](#core-tendermintcometbft-ports)
- [Cosmos SDK Application Ports](#cosmos-sdk-application-ports)
- [EVM/JSON-RPC Ports](#evmjson-rpc-ports)
- [Development/Debug Ports](#developmentdebug-ports)

---

## Core Tendermint/CometBFT Ports

These ports are used by the Tendermint/CometBFT consensus layer (the blockchain engine).

### P2P (Port 26656)

**Default Port:** 26656  
**Protocol:** TCP  
**Required:** Yes (for blockchain nodes)

**Description:**  
Peer-to-peer network communication port. This is the primary port used by blockchain nodes to communicate with other nodes in the network. Nodes exchange blocks, transactions, and consensus messages through this port.

**When to expose:**
- ✅ Always required for blockchain nodes
- ✅ Required if running a validator
- ✅ Required if you want to accept incoming peer connections

**Configuration:**
- Via command line: `--p2p.laddr tcp://0.0.0.0:26656`
- Via config file: `config.toml` → `[p2p]` → `laddr`

---

### RPC (Port 26657)

**Default Port:** 26657  
**Protocol:** TCP  
**Required:** Optional (depends on use case)

**Description:**  
Tendermint RPC API endpoint. Provides HTTP and WebSocket interfaces for querying blockchain data, submitting transactions, and monitoring node status.

**When to expose:**
- ✅ If you need to query blockchain data from external applications
- ✅ If you're running a public RPC endpoint
- ❌ Not required if only running a validator without external queries

**Configuration:**
- Via command line: `--rpc.laddr tcp://0.0.0.0:26657`
- Via config file: `config.toml` → `[rpc]` → `laddr`

**Common endpoints:**
- `/status` - Node status
- `/block` - Block information
- `/tx` - Transaction information
- `/abci_query` - Application state queries

---

### ABCI (Port 26658)

**Default Port:** 26658  
**Protocol:** TCP  
**Required:** No (internal only)

**Description:**  
ABCI (Application Blockchain Interface) connection port. Used for communication between Tendermint and the application layer. This is typically only used when running Tendermint and the application as separate processes.

**When to expose:**
- ❌ Never expose externally (internal communication only)
- ❌ Not needed for standard node configurations

**Configuration:**
- Via config file: `config.toml` → `proxy_app`

---

### Prometheus (Port 26660)

**Default Port:** 26660  
**Protocol:** TCP  
**Required:** Optional (monitoring)

**Description:**  
Prometheus metrics endpoint for Tendermint/CometBFT. Provides metrics about node performance, network activity, and consensus state.

**When to expose:**
- ✅ If you're running a Prometheus monitoring system
- ✅ If you want to collect node metrics
- ❌ Not required for basic node operation

**Configuration:**
- Via config file: `config.toml` → `[instrumentation]` → `prometheus_listen_addr`

---

## Cosmos SDK Application Ports

These ports are used by the Cosmos SDK application layer (the blockchain application).

### gRPC (Port 9090)

**Default Port:** 9090  
**Protocol:** TCP  
**Required:** Optional

**Description:**  
gRPC server for Cosmos SDK queries. Provides high-performance query interface for blockchain data. Used by wallets, explorers, and other applications that need to query the blockchain state.

**When to expose:**
- ✅ If you're running a public API endpoint
- ✅ If wallets or applications need to query your node
- ❌ Not required for validators that only participate in consensus

**Configuration:**
- Via command line: `--grpc.address 0.0.0.0:9090`
- Via config file: `app.toml` → `[grpc]` → `address`

---

### gRPC-Web (Port 9091)

**Default Port:** 9091  
**Protocol:** TCP  
**Required:** Optional

**Description:**  
gRPC-Web server provides browser-compatible access to gRPC services. Allows web applications to query the blockchain without requiring a proxy.

**When to expose:**
- ✅ If you're building web applications that need blockchain data
- ✅ If you want browser-based wallets to connect
- ❌ Not required if only using gRPC (not gRPC-Web)

**Configuration:**
- Via command line: `--grpc-web.address 0.0.0.0:9091`
- Via config file: `app.toml` → `[grpc-web]` → `address`

**Note:** Requires gRPC to also be enabled.

---

### REST API (Port 1317)

**Default Port:** 1317  
**Protocol:** TCP  
**Required:** Optional (legacy)

**Description:**  
Cosmos SDK REST API (legacy). Provides HTTP REST interface for blockchain queries. This is the older API format, largely superseded by gRPC, but still used by some applications.

**When to expose:**
- ✅ If you need compatibility with older applications
- ✅ If you prefer REST over gRPC
- ❌ Not required for new applications (use gRPC instead)

**Configuration:**
- Via command line: `--api.address tcp://0.0.0.0:1317`
- Via config file: `app.toml` → `[api]` → `address`

---

## EVM/JSON-RPC Ports

These ports provide Ethereum-compatible JSON-RPC interfaces for EVM (Ethereum Virtual Machine) functionality.

### JSON-RPC HTTP (Port 8545)

**Default Port:** 8545  
**Protocol:** TCP  
**Required:** Optional

**Description:**  
Ethereum-compatible JSON-RPC HTTP endpoint. Allows Ethereum tools (MetaMask, Remix, etc.) and applications to interact with the blockchain as if it were an Ethereum network.

**When to expose:**
- ✅ If you want to use Ethereum-compatible wallets (MetaMask, etc.)
- ✅ If you're deploying Ethereum smart contracts
- ✅ If you're building dApps that use Web3.js or Ethers.js
- ❌ Not required if only using Cosmos SDK features

**Configuration:**
- Via command line: `--json-rpc.address 0.0.0.0:8545`
- Via config file: `app.toml` → `[json-rpc]` → `address`

**Common methods:**
- `eth_blockNumber` - Get latest block number
- `eth_getBalance` - Get account balance
- `eth_sendTransaction` - Send transaction
- `eth_call` - Execute contract call

---

### JSON-RPC WebSocket (Port 8546)

**Default Port:** 8546  
**Protocol:** TCP (WebSocket)  
**Required:** Optional

**Description:**  
Ethereum-compatible JSON-RPC WebSocket endpoint. Provides real-time updates for blockchain events, new blocks, and transaction confirmations.

**When to expose:**
- ✅ If you need real-time blockchain event notifications
- ✅ If your application uses WebSocket subscriptions
- ✅ If you're building reactive dApps
- ❌ Not required if only using HTTP JSON-RPC

**Configuration:**
- Via command line: `--json-rpc.ws-address 0.0.0.0:8546`
- Via config file: `app.toml` → `[json-rpc]` → `ws-address`

---

### EVM Metrics (Port 6065)

**Default Port:** 6065  
**Protocol:** TCP  
**Required:** Optional (monitoring)

**Description:**  
EVM Prometheus metrics endpoint. Provides detailed metrics about EVM execution, gas usage, and transaction processing.

**When to expose:**
- ✅ If you're monitoring EVM performance
- ✅ If you need detailed EVM transaction metrics
- ❌ Not required for basic node operation

**Configuration:**
- Via config file: `app.toml` → `[json-rpc]` → `metrics-address`

---

### Geth Metrics (Port 8100)

**Default Port:** 8100  
**Protocol:** TCP  
**Required:** Optional (monitoring)

**Description:**  
Geth-compatible metrics endpoint. Provides metrics in a format compatible with Ethereum's Geth client for monitoring tools.

**When to expose:**
- ✅ If you're using Geth-compatible monitoring tools
- ✅ If you need compatibility with existing Ethereum monitoring setups
- ❌ Not required for basic node operation

**Configuration:**
- Via config file: `app.toml` → `[evm]` → `geth-metrics-address`

---

## Development/Debug Ports

These ports are for development and debugging purposes only. **Do not expose in production.**

### pprof (Port 6060)

**Default Port:** 6060  
**Protocol:** TCP  
**Required:** No (development only)

**Description:**  
Go pprof profiling endpoint. Provides detailed performance profiling and debugging information for Go applications. Used for identifying performance bottlenecks and memory leaks.

**When to expose:**
- ✅ Only during development and debugging
- ❌ **Never expose in production** (security risk)
- ❌ Not required for normal operation

**Configuration:**
- Via command line: `--rpc.pprof_laddr localhost:6060`
- Via config file: `config.toml` → `[rpc]` → `pprof_laddr`

**Security Warning:**  
This endpoint can expose sensitive information about your application's internal state. Always bind to `localhost` only, never to `0.0.0.0` in production.

---

## Port Summary Table

| Port Type | Default Port | Required | Protocol | Use Case |
|-----------|-------------|----------|----------|----------|
| P2P | 26656 | ✅ Yes | TCP | Network communication |
| RPC | 26657 | ⚠️ Optional | TCP | Blockchain queries |
| ABCI | 26658 | ❌ No | TCP | Internal (do not expose) |
| Prometheus | 26660 | ⚠️ Optional | TCP | Monitoring |
| gRPC | 9090 | ⚠️ Optional | TCP | Application queries |
| gRPC-Web | 9091 | ⚠️ Optional | TCP | Browser queries |
| REST API | 1317 | ⚠️ Optional | TCP | Legacy API |
| JSON-RPC HTTP | 8545 | ⚠️ Optional | TCP | Ethereum compatibility |
| JSON-RPC WS | 8546 | ⚠️ Optional | TCP | Real-time events |
| EVM Metrics | 6065 | ⚠️ Optional | TCP | EVM monitoring |
| Geth Metrics | 8100 | ⚠️ Optional | TCP | Geth monitoring |
| pprof | 6060 | ❌ No | TCP | Development only |

---

## See Also

- [strategy.md](./strategy.md) - Port allocation strategy and service configuration
- [services/](./services/) - Service-specific port files (e.g., `node0-infinite.md`)

