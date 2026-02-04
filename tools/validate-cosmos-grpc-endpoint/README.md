# Cosmos gRPC Endpoint Validation Script

Cosmos SDK chains expose a gRPC interface for application and module queries (account state, balances, staking, etc.). In the Cosmos ecosystem it plays a role similar to JSON-RPC in the EVM (Ethereum Virtual Machine) world: the standard way for clients to query chain state. This script checks that the endpoint is reachable and, when possible, that it exposes the expected gRPC services. The service typically listens on a dedicated port (e.g. **9090**).

Other endpoint types (EVM RPC, Tendermint RPC) have their own validators in this directory.

## What is validated

1. **URL / host:port normalization and validation** — Extracts host and port. **No default port is added** when omitted; the server or load balancer handles routing.
2. **DNS resolution** — Hostname resolves correctly.
3. **gRPC port connectivity** — If **grpcurl** is installed, the script uses it to verify that the gRPC server responds (`grpcurl list`); this is the recommended check. If grpcurl is not available, a raw TCP probe (nc or bash /dev/tcp) is used as fallback; that can fail on some networks or firewalls even when gRPC works, so installing grpcurl is recommended.
4. **SSL certificate (when HTTPS)** — If the URL uses HTTPS, the certificate is validated with OpenSSL (validity and expiration). Skipped for HTTP.
5. **gRPC service list (optional)** — If `grpcurl` is installed, tries to list services (plaintext or TLS) to confirm a gRPC server is present.
6. **CORS headers (optional)** — If the same host/port responds to HTTP OPTIONS or POST, CORS headers are reported. Many gRPC-only endpoints do not respond to HTTP; in that case the check is skipped and no failure is reported.
7. **Security headers (optional)** — If the endpoint responds to HTTP, common security headers (e.g. X-Frame-Options, Strict-Transport-Security) are checked. Skipped when the endpoint is gRPC-only.

## Requirements

The script uses the following tools (when available):

- **grpcurl** — **Recommended.** When installed, step 3 (connectivity) and step 5 (service list) use it to validate the gRPC endpoint. Without it, step 3 falls back to a raw TCP check (nc or /dev/tcp), which can fail even when gRPC works (e.g. on macOS or behind some firewalls). Install: `brew install grpcurl` (macOS); on Ubuntu/Debian: `sudo snap install grpcurl` or, if that package is only on the edge channel, `sudo snap install --edge grpcurl`; or see [grpcurl releases](https://github.com/fullstorydev/grpcurl/releases).
- `nc` (netcat) or `/dev/tcp` — Fallback for port connectivity when grpcurl is not installed.
- `openssl` — For SSL certificate validation when using HTTPS.
- `curl` — For optional CORS and security header checks.
- `host`, `dig`, or `nslookup` — For DNS resolution.

## Usage

```bash
./validate-cosmos-grpc-endpoint.sh <URL_or_host:port>
```

### Examples

```bash
# HTTPS with explicit port (typical 9090)
./validate-cosmos-grpc-endpoint.sh https://grpc.example.com:9090

# Hostname and port only (no protocol)
./validate-cosmos-grpc-endpoint.sh grpc.example.com:9090

# Local or internal gRPC endpoint
./validate-cosmos-grpc-endpoint.sh localhost:9090

# URL without port (no default port is added; server handles routing; some optional probes may contact 443 or 9090 only to attempt the check)
./validate-cosmos-grpc-endpoint.sh grpc.example.com
```

## Output

The script uses color codes for readability (✓ green passed, ✗ red failed, ⚠ yellow warnings, ℹ blue info) and a final summary with the number of checks passed or failed.

## Exit codes

- `0`: All validations passed.
- `1`: One or more validations failed or an error occurred.

## Compatibility

The script is compatible with Linux, macOS, BSD, and any Unix-like system with bash 4.0+.

## Notes

- Default timeout is 10 seconds for connections.
- **No default ports**: If no port is specified, the URL is left without a port so the server or load balancer can handle redirections; the optional gRPC probe may try a standard port for the check only (e.g. 9090 for plaintext gRPC).
- **CORS and security headers**: These are checked only when the endpoint responds to HTTP (e.g. GET/OPTIONS). Pure gRPC servers often do not; the script then reports that these checks are not applicable and does not fail.

## Authorship and rights

**Copyright 2025, Deep Thought Labs.**

This tool is part of the **Infinite Drive** ecosystem (**Project 42**).

- **Infinite Drive**: [https://infinitedrive.xyz](https://infinitedrive.xyz) · [https://docs.infinitedrive.xyz](https://docs.infinitedrive.xyz)
- **Deep Thought Labs**: [https://deep-thought.computer](https://deep-thought.computer)
