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

- **[Configuration](configuration.md)** - Customize your services
  - Environment variables
  - Port configuration
  - Network settings
  - Service-specific settings
- **[Port Allocation](PORT_ALLOCATION.md)** - Port allocation strategy for multiple services
  - Standard ports for mainnet
  - Alternative ports for testnet and other services
  - Running multiple services simultaneously

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

Drive organizes services in the following structure:

```
drive/
└── services/
    ├── infinite-mainnet/     # Mainnet blockchain node
    │   ├── docker-compose.yml
    │   ├── drive.sh          # Container management wrapper (recommended)
    │   └── persistent-data/  # Service data (git-ignored)
    └── infinite-testnet/     # Testnet blockchain node
        ├── docker-compose.yml
        ├── drive.sh
        └── persistent-data/  # Service data (git-ignored)
```

Each service is completely independent with its own:
- Configuration
- Persistent data
- Container name
- Network settings

## Quick Reference

### Most Common Operations

**Start a service:**
```bash
cd drive/services/infinite-mainnet
./drive.sh up -d
docker compose exec infinite-mainnet node-ui
```

**Stop a service:**
```bash
cd drive/services/infinite-mainnet
./drive.sh stop
```

**View logs:**
```bash
cd drive/services/infinite-mainnet
docker compose exec infinite-mainnet node-logs
```

**Note:** Use `./drive.sh` for container management commands (up, down, stop, ps, etc.) to automatically handle permissions. Use `docker compose exec` for commands inside the container.

### Using the Graphical Interface

The graphical interface (`node-ui`) is the **recommended method** for all operations:

```bash
cd drive/services/infinite-mainnet
./drive.sh up -d
docker compose exec infinite-mainnet node-ui
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

