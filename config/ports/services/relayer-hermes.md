# Port Configuration: Relayer Hermes (IBC)

**Service Name:** `relayer-hermes`  
**Container Name:** `relayer-hermes`

This service runs Hermes (IBC relayer) and **does not expose any ports**. It only makes outbound connections to the RPC and gRPC endpoints of the configured chains.

---

## Ports

| Port Type | Host Port | Container Port |
|-----------|-----------|----------------|
| N/A       | —         | —              |

**Note:** The port allocation formula by service number does not apply; the relayer does not listen on any ports.
