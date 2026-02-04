# Cosmos (Tendermint) RPC Endpoint Validation Script

Cosmos-based chains expose an HTTP RPC (Tendermint RPC) for low-level node and chain data: sync status, chain ID, latest block height, consensus info. Relayers, block explorers, and other clients use it to talk to the chain at the Tendermint layer. This script checks that the endpoint is reachable and returns valid data. The service typically listens on a dedicated port (e.g. **26657**).

Other endpoint types (EVM RPC, Cosmos gRPC) have their own validators in this directory.

## What is validated

1. **URL normalization and validation** — Protocol (HTTP/HTTPS) if missing. **No default port is added** when omitted; the server or load balancer handles routing.
2. **DNS resolution** — Hostname resolves correctly.
3. **Network connectivity** — Port is reachable (skipped when no port is specified; connectivity is then checked via the `/status` request).
4. **Tendermint /status** — GET `/status` returns valid JSON with `result.node_info` and `result.sync_info`; chain ID and latest block height are reported.

## Requirements

The script requires the following tools (usually available on Unix-like systems):

- `curl` — required for `/status` request
- `nc` (netcat) or `/dev/tcp` support — for connectivity checks (optional)
- `host` or `nslookup` — for DNS resolution (optional)

## Usage

```bash
./validate-cosmos-rpc-endpoint.sh <URL>
```

### Examples

```bash
# HTTPS with explicit port (typical 26657)
./validate-cosmos-rpc-endpoint.sh https://rpc.example.com:26657

# HTTP (e.g. local node or internal RPC)
./validate-cosmos-rpc-endpoint.sh http://localhost:26657

# URL without port (server or load balancer handles routing)
./validate-cosmos-rpc-endpoint.sh https://rpc.example.com

# Hostname only (script auto-detects protocol; no default port added)
./validate-cosmos-rpc-endpoint.sh rpc.example.com

# Hostname with port (script auto-detects protocol)
./validate-cosmos-rpc-endpoint.sh rpc.example.com:26657
```

## Output

The script uses color codes for readability (✓ green passed, ✗ red failed, ⚠ yellow warnings, ℹ blue info) and a final summary with the number of checks passed or failed. When the endpoint responds correctly, the summary also shows **endpoint information** from Tendermint `/status`: chain ID, latest block height, and latest block time. Step 4 (Tendermint /status) reports **"Step 4 completed in Xs"** so you can see how long the request took. The script uses the shared `scripts/endpoint-validation-common.sh` (same practices as the gRPC and EVM validators).

## Exit codes

- `0`: All validations passed.
- `1`: One or more validations failed or an error occurred.

## Compatibility

The script is compatible with Linux, macOS, BSD, and any Unix-like system with bash 4.0+.

## Notes

- Default timeout is 10 seconds for connections.
- **No default ports**: If no port is specified, the URL is left without a port so the server or load balancer can handle redirections.

## Authorship and rights

**Copyright 2025, Deep Thought Labs.**

This tool is part of the **Infinite Drive** ecosystem (**Project 42**).

- **Infinite Drive**: [https://infinitedrive.xyz](https://infinitedrive.xyz) · [https://docs.infinitedrive.xyz](https://docs.infinitedrive.xyz)
- **Deep Thought Labs**: [https://deep-thought.computer](https://deep-thought.computer)
