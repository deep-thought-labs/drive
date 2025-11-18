# Infinite Mainnet Service

Service configuration for running an Infinite Drive blockchain node on mainnet. Uses Docker Compose with the `drive.sh` wrapper script for easy container management.

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

## Files

- `docker-compose.yml` - Service configuration
- `drive.sh` - Helper script for automatic permission handling
- `persistent-data/` - Blockchain data directory (created automatically)

## Documentation

For complete documentation, see:
- [Quick Start Guide](../../docs/quick-start.md)
- [Container Management](../../docs/container-management.md)
- [Node Operations](../../docs/node-operations.md)

