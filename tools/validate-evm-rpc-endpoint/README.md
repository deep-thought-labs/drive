# EVM RPC Endpoint Validation Script

This script validates **EVM RPC endpoints only** — i.e. nodes that expose the standard Ethereum/EVM JSON-RPC interface (e.g. for MetaMask, dApps, or public RPC usage). It does **not** validate other RPC protocols such as Cosmos (e.g. Tendermint RPC, gRPC, REST) or other non-EVM endpoints; use protocol-specific tools for those.

It runs a set of checks to verify that an EVM RPC endpoint is working correctly and is properly configured for public use.

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

The script uses:

- **Color codes** for readability:
  - ✓ Green: Passed checks
  - ✗ Red: Failed checks
  - ⚠ Yellow: Warnings
  - ℹ Blue: Information

- A **final summary** with the total number of individual checks run (e.g. 12) and how many passed or failed. This total is higher than 8 because each validation area can include multiple checks (e.g. four RPC methods, several CORS headers).

## Exit codes

- `0`: All validations passed.
- `1`: One or more validations failed or an error occurred.

## Compatibility

The script is compatible with:

- Linux
- macOS
- BSD
- Any Unix-like system with bash 4.0+

## Notes

- The script uses a default timeout of 10 seconds for all connections.
- If a required tool is not available, the script skips that specific check and prints a warning.
- The script is designed to be robust and continue running even if some checks fail (except for critical validations).
- **Automatic normalization**: If no protocol (`http://` or `https://`) is provided, the script tries to detect it by testing HTTPS first, then HTTP.
- **No default ports**: If no port is specified, the URL is left without a port. The script does **not** add default ports (443/80), so the server or load balancer can handle redirections correctly.
- The script handles server-side redirections appropriately.

## Authorship and rights

**Copyright 2025, Deep Thought Labs.**

This tool is part of the **Infinite Drive** ecosystem (**Project 42**).

- **Infinite Drive**: [https://infinitedrive.xyz](https://infinitedrive.xyz) · [https://docs.infinitedrive.xyz](https://docs.infinitedrive.xyz)
- **Deep Thought Labs**: [https://deep-thought.computer](https://deep-thought.computer)
