# Drive Documentation

Complete user guide for managing infrastructure services with Drive. This documentation is designed for Drive as an independent infrastructure management platform.

## Getting Started

- **[Quick Start](quick-start.md)** - Get your first service running in minutes (start here!)
  - Prerequisites and Docker installation
  - Starting your first service
  - Using the graphical interface (recommended)
  - Command-line operations (advanced)

## Core Guides

- **[Node Operations](node-operations.md)** - Complete guide to managing blockchain nodes
  - Graphical interface usage (easiest method)
  - All available commands
  - Initialization workflows
  - Key management
  - Starting and stopping nodes

- **[Container Management](container-management.md)** - Container management with `drive.sh`
  - Starting and stopping containers
  - Managing multiple services
  - Accessing container shell
  - Viewing container logs
  - Data persistence

- **[Configuration Reference](../config/)** - Complete configuration documentation
  - [Environment Variables](../config/environment/reference.md) - All available environment variables
  - [Port Allocation Strategy](../config/ports/strategy.md) - Port allocation logic and strategy
  - [Port Reference Guide](../config/ports/reference.md) - Detailed port descriptions
  - [Service-Specific Configurations](../config/ports/services/) - Individual service port configurations

## Monitoring & Maintenance

- **[Monitoring](monitoring.md)** - Monitor your services
  - Process status
  - Log viewing
  - Network diagnosis
  - System information

- **[Troubleshooting](troubleshooting.md)** - Solve common issues
  - Common problems and solutions
  - Debugging techniques
  - Recovery procedures

## Additional Resources

- **[Key Management](key-management.md)** - Comprehensive key management guide
  - Generating keys
  - Backing up seed phrases
  - Adding existing keys
  - Best practices for validators

## Service Structure

Drive organizes services and configuration in the following structure:

```
drive/
├── services/                    # Service definitions
│   ├── node0-infinite/          # Infinite Mainnet (Service #0)
│   │   ├── docker-compose.yml   # Service configuration
│   │   ├── drive.sh             # Container management wrapper (recommended)
│   │   └── persistent-data/     # Service data (git-ignored)
│   ├── node1-infinite-testnet/ # Infinite Testnet (Service #1)
│   ├── node2-infinite-creative/ # Creative Network (Service #2)
│   ├── node3-qom/               # QOM Network (Service #3)
│   └── service4-nginx/         # Nginx Web Server (Service #4) ⚠️ Exception: uses standard ports 80/443
└── config/                      # Configuration documentation
    ├── environment/             # Environment variables documentation
    │   ├── reference.md         # Complete environment variables reference
    │   └── services/            # Service-specific environment configs
    └── ports/                   # Port configuration documentation
        ├── strategy.md          # Port allocation strategy
        ├── reference.md        # Detailed port descriptions
        └── services/            # Service-specific port configs
```

Each service is completely independent with its own:
- Configuration (defined in `docker-compose.yml`)
- Persistent data (stored in `persistent-data/`)
- Container name
- Network settings (ports, P2P configuration)

**Configuration Files:**
- **Environment Variables:** See [`config/environment/reference.md`](../config/environment/reference.md) for all available variables
- **Port Configuration:** See [`config/ports/strategy.md`](../config/ports/strategy.md) for port allocation strategy and service-specific configurations

## Quick Reference

### Most Common Operations

**Start a service:**
```bash
cd drive/services/node0-infinite
./drive.sh up -d
docker compose exec infinite node-ui
```

**Stop a service:**
```bash
cd drive/services/node0-infinite
./drive.sh stop
```

**View logs:**
```bash
cd drive/services/node0-infinite
docker compose exec infinite node-logs
```

**Note:** Use `./drive.sh` for container management commands (up, down, stop, ps, etc.) to automatically handle permissions. Use `docker compose exec` for commands inside the container.

### Using the Graphical Interface

The graphical interface (`node-ui`) is the **recommended method** for all operations:

```bash
cd drive/services/node0-infinite
./drive.sh up -d
docker compose exec infinite node-ui
```

**Note:** Use `./drive.sh` to start the container (automatically handles permissions), then use `docker compose exec` to access the interface.

The interface provides:
- Visual menus for all operations
- Self-descriptive options
- Interactive wizards
- Real-time monitoring

## Documentation Philosophy

This documentation follows a **progressive disclosure** approach:

1. **Easiest First** - Graphical interface is always presented as the primary method
2. **Advanced Options** - Command-line operations are documented for power users
3. **Clear Examples** - All examples use the correct service paths
4. **Independent Repository** - Written as if Drive is a standalone project

## Contributing

When updating this documentation:
- Always prioritize the graphical interface in examples
- Use correct service paths (`drive/services/<service-name>`)
- Include both interface and command-line methods
- Keep examples current with the latest Drive structure

