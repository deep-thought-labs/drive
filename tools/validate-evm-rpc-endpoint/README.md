# EVM RPC Endpoint Validation Script

Nodes that expose the Ethereum/EVM JSON-RPC interface allow wallets, dApps, and scripts to read chain data (balances, state, blocks) and send transactions. This script checks that such an endpoint is reachable and correctly configured. The RPC service typically listens on a dedicated port (e.g. **8545**).

Other endpoint types (Tendermint RPC, Cosmos gRPC) have their own validators in this directory.

## What is validated

The script runs **8 validation areas**. Within each area it may perform one or more individual checks (for example, four separate RPC method calls, or several CORS header checks). The **final summary shows the total number of those individual checks** (e.g. 12 or more), not just the number of areas.

The 8 areas, in order:

1. **URL normalization and validation** — Detects protocol (HTTPS/HTTP) if missing; does not add default ports.
2. **DNS resolution** — Hostname resolves correctly.
3. **Network connectivity** — Port is reachable (skipped when no port is given).
4. **SSL certificate** — Validity and expiration (HTTPS only).
5. **HTTP/HTTPS response** — Server responds with a valid status code.
6. **RPC methods (EVM)** — JSON-RPC: `web3_clientVersion`, `eth_blockNumber`, `net_version`, `eth_chainId` (one check per method).
7. **CORS headers** — Present and suitable for browser wallets (e.g. MetaMask); multiple header checks.
8. **Security headers** — Recommended headers (e.g. X-Frame-Options, HSTS).

## Requirements

The script requires the following tools (usually available on Unix-like systems):

- `curl` — for HTTP/HTTPS and RPC requests
- `openssl` — for SSL certificate validation (optional)
- `nc` (netcat) or `/dev/tcp` support — for connectivity checks (optional)
- `host` or `nslookup` — for DNS resolution (optional)

## Usage

```bash
./validate-evm-rpc-endpoint.sh <URL>
```

### Examples

```bash
# HTTPS RPC endpoint with port
./validate-evm-rpc-endpoint.sh https://rpc.example.com:8545

# HTTP RPC endpoint with port
./validate-evm-rpc-endpoint.sh http://rpc.example.com:8545

# RPC endpoint without port (server will handle redirection)
./validate-evm-rpc-endpoint.sh https://rpc.example.com

# Hostname only (script auto-detects HTTPS/HTTP; no default port added)
./validate-evm-rpc-endpoint.sh rpc.example.com

# Hostname with port (script auto-detects protocol)
./validate-evm-rpc-endpoint.sh rpc.example.com:8545
```

## Output

The script uses color codes for readability (✓ green passed, ✗ red failed, ⚠ yellow warnings, ℹ blue info) and a final summary with the total number of individual checks run (e.g. 12) and how many passed or failed. That total is higher than 8 because each validation area can include multiple checks (e.g. four RPC methods, several CORS headers).

## Exit codes

- `0`: All validations passed.
- `1`: One or more validations failed or an error occurred.

## Compatibility

The script is compatible with Linux, macOS, BSD, and any Unix-like system with bash 4.0+.

## Notes

- Default timeout is 10 seconds for connections.
- If a required tool is not available, the script skips that check and prints a warning.
- **No default ports**: If no port is specified, the URL is left without a port so the server or load balancer can handle redirections.
- If no protocol is provided, the script tries to detect HTTPS first, then HTTP.

## Authorship and rights

**Copyright 2025, Deep Thought Labs.**

This tool is part of the **Infinite Drive** ecosystem (**Project 42**).

- **Infinite Drive**: [https://infinitedrive.xyz](https://infinitedrive.xyz) · [https://docs.infinitedrive.xyz](https://docs.infinitedrive.xyz)
- **Deep Thought Labs**: [https://deep-thought.computer](https://deep-thought.computer)
