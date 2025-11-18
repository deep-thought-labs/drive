# Port Allocation Strategy

This document defines the port allocation strategy for Infinite Drive services to avoid conflicts and provide a clear structure for future services.

## Port Allocation Principles

1. **Mainnet uses standard ports** - Mainnet always uses the standard blockchain ports (26656, 26657)
2. **Testnet uses dedicated range** - Testnet uses ports in a dedicated range to avoid conflicts
3. **Future services follow pattern** - New services follow the established pattern
4. **Clear separation** - Each service type has its own port range to prevent conflicts

## Port Allocation Table

### P2P Ports (Network Communication)

| Service | Host Port | Container Port | Description |
|---------|-----------|----------------|-------------|
| **Mainnet** | `26656` | `26656` | Standard P2P port for mainnet |
| **Testnet** | `26666` | `26656` | Testnet P2P port (26656 + 10) |
| **Creative** | `26676` | `26656` | Creative network P2P port (26656 + 20) |
| **Future Service 1** | `26686` | `26656` | Reserved for future service (26656 + 30) |
| **Future Service 2** | `26696` | `26656` | Reserved for future service (26656 + 40) |

**Pattern:** Mainnet uses standard port, other services use `26656 + (service_number * 10)`

### RPC Ports (API Access)

| Service | Host Port | Container Port | Description |
|---------|-----------|----------------|-------------|
| **Mainnet** | `26657` | `26657` | Standard RPC port for mainnet |
| **Testnet** | `26667` | `26657` | Testnet RPC port (26657 + 10) |
| **Creative** | `26677` | `26657` | Creative network RPC port (26657 + 20) |
| **Future Service 1** | `26687` | `26657` | Reserved for future service (26657 + 30) |
| **Future Service 2** | `26697` | `26657` | Reserved for future service (26657 + 40) |

**Pattern:** Mainnet uses standard port, other services use `26657 + (service_number * 10)`

## Service Numbering

| Service Number | Service Name | P2P Port | RPC Port |
|----------------|--------------|----------|----------|
| 0 | Mainnet | 26656 | 26657 |
| 1 | Testnet | 26666 | 26667 |
| 2 | Creative | 26676 | 26677 |
| 3 | Future Service 1 | 26686 | 26687 |
| 4 | Future Service 2 | 26696 | 26697 |

**Formula:**
- P2P Port = `26656 + (service_number * 10)`
- RPC Port = `26657 + (service_number * 10)`

## Rationale

### Why This Strategy?

1. **Clear Separation**: Each service type has its own port range with 10 ports of separation
2. **Scalability**: Easy to add new services following the pattern
3. **Conflict Prevention**: Large gaps (10 ports) prevent conflicts with other services
4. **Maintainability**: Simple formula makes it easy to remember and document
5. **Future-Proof**: Leaves room for other services that might use ports in between

### Container Ports

**Important:** Container ports remain constant (`26656` for P2P, `26657` for RPC) because:
- The blockchain software inside the container always uses standard ports
- Only the host port mapping changes to avoid conflicts
- This simplifies container configuration

## Usage Examples

### Mainnet (Standard Ports)
```yaml
ports:
  - "26656:26656"  # P2P
  - "26657:26657"  # RPC
```

### Testnet (Alternative Ports)
```yaml
ports:
  - "26666:26656"  # P2P (host 26666 maps to container 26656)
  - "26667:26657"  # RPC (host 26667 maps to container 26657)
```

### Creative Network (Alternative Ports)
```yaml
ports:
  - "26676:26656"  # P2P (host 26676 maps to container 26656)
  - "26677:26657"  # RPC (host 26677 maps to container 26657)
```

## Updating Service Configuration

When creating a new service:

1. Determine the service number (0=mainnet, 1=testnet, 2=creative, etc.)
2. Calculate ports using the formula:
   - P2P: `26656 + (service_number * 10)`
   - RPC: `26657 + (service_number * 10)`
3. Update this document with the new service
4. Configure ports in `docker-compose.yml`

## Notes

- **Mainnet always uses standard ports** - This is the production network and should use standard ports
- **Other services use alternative ports** - To allow running multiple services simultaneously
- **Container ports never change** - The blockchain software always uses 26656/26657 internally
- **Host ports are configurable** - Users can change host ports if needed, but recommended ports are documented here

