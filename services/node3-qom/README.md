# Infinite Testnet Service

Service configuration for running an Infinite Drive blockchain node on testnet. Uses Docker Compose with the `drive.sh` wrapper script for easy container management.

## Quick Start

### Using the Wrapper Script (Recommended)

The `drive.sh` script automatically handles permission configuration:

```bash
# Start the service
./drive.sh up -d

# Stop the service
./drive.sh down

# Check status
./drive.sh ps

# View logs
./drive.sh logs -f

# Any docker-compose command works!
```

**Why use the wrapper script?**
- ✅ Automatically configures correct user permissions
- ✅ Works with or without `sudo` (handles both cases automatically)
- ✅ Prevents permission errors when writing to volumes
- ✅ No need to manually set environment variables

**Important Note on Docker Permissions:**
- **If Docker requires `sudo`** (user not in docker group), you must use `sudo ./drive.sh` - the script will detect and handle this correctly
- **If Docker works without `sudo`** (user in docker group), use `./drive.sh` directly
- To configure Docker to work without sudo (Linux): `sudo usermod -aG docker $USER` (then log out and log back in)

### Using Docker Compose Directly

If you prefer to use `docker compose` directly (not recommended), you may need to configure permissions manually:

```bash
# Set permissions (works with or without sudo)
export PUID=${SUDO_UID:-$(id -u)}
export PGID=${SUDO_GID:-$(id -g)}

# Then use docker compose normally
docker compose up -d
```

**Note:** Using `./drive.sh` is strongly recommended as it handles permissions automatically. See the [Container Management documentation](../../docs/container-management.md#fixing-permission-issues) for more details.

## Network Configuration

This service is configured for **Infinite Testnet**:

- **Cosmos Chain ID**: `infinite_421018001-1`
- **EVM Chain ID**: `421018001`
- **Ports** (see [Port Allocation Strategy](../../docs/PORT_ALLOCATION.md) for details): 
  - P2P: `26666:26656` (host:container)
  - RPC: `26667:26657` (host:container)

**Port Allocation:**
- Mainnet uses standard ports: `26656` (P2P), `26657` (RPC)
- Testnet uses alternative ports: `26666` (P2P), `26667` (RPC) - +10 from standard
- This allows running both networks simultaneously without conflicts

**Note:** If you only run testnet (not mainnet), you can change the ports in `docker-compose.yml` to `26656:26656` and `26657:26657` to use standard ports.

## Important: Configuration Required

Before using this service, you need to update the following in `docker-compose.yml`:

1. **NODE_GENESIS_URL**: Update with the official testnet genesis URL
2. **NODE_P2P_SEEDS**: Update with official testnet seed nodes

These are marked with `TODO` comments in the configuration file.

## Files

- `docker-compose.yml` - Service configuration
- `drive.sh` - Helper script for automatic permission handling
- `persistent-data/` - Blockchain data directory (created automatically)

## Documentation

For complete documentation, see:
- [Quick Start Guide](../../docs/quick-start.md)
- [Container Management](../../docs/container-management.md)
- [Node Operations](../../docs/node-operations.md)

## Running Testnet and Mainnet Simultaneously

You can run both testnet and mainnet nodes at the same time:

```bash
# Terminal 1: Mainnet
cd services/node0-infinite
./drive.sh up -d

# Terminal 2: Testnet
cd services/node1-node1-infinite-testnet
./drive.sh up -d
```

Each service maintains its own:
- Container name
- Persistent data directory
- Network ports
- Configuration

