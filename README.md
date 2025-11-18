# Drive

**Open infrastructure management platform. Orchestrate services. Deploy nodes. Scale infrastructure.**

> _A cypherpunk nation in cyberspace. Powered by improbability._

Drive is an open infrastructure management platform designed for **Infinite Improbability Chain** and beyond. Orchestrate blockchain nodes, services, and infrastructure with a unified interface. Part of the **Infinite Drive** ecosystem and **Project 42**. Developed by [Deep Thought Labs](https://deep-thought.computer). For information about **Infinite Improbability Chain**, see the [Infinite repository](https://github.com/deep-thought-labs/infinite).

---

## The Platform

| Feature                    | Status                      |
| -------------------------- | --------------------------- |
| Multi-Service Orchestration | ✅ Independent services      |
| Infinite Mainnet Node      | ✅ Full blockchain node      |
| Infinite Testnet Node      | ✅ Testnet support           |
| Graphical Interface        | ✅ Self-descriptive UI       |
| Persistent Data            | ✅ Isolated per service      |
| Container Management       | ✅ `drive.sh` wrapper script |

---

## Quick Start

To get started with Drive, follow the complete [Quick Start Guide](docs/quick-start.md) which includes:

- **Prerequisites** - Git, Docker, and Docker Compose installation instructions for macOS, Linux, and Windows
- **Firewall Configuration** - Step-by-step instructions for opening required ports on all supported systems
- **Repository Setup** - How to clone and navigate the repository
- **Node Initialization** - Complete guide for setting up validator or simple nodes
- **Graphical Interface** - Using the built-in TUI for easy node management
- **Command Line Operations** - Advanced commands for automation

**Start here:** [Quick Start Guide](docs/quick-start.md)

---

## Project Structure

```
drive/
├── services/                    # Service definitions
│   ├── infinite-mainnet/        # Infinite Mainnet blockchain node
│   │   ├── docker-compose.yml  # Service configuration
│   │   ├── drive.sh            # Container management wrapper (recommended)
│   │   └── persistent-data/    # Persistent blockchain data (git-ignored)
│   ├── infinite-testnet/       # Infinite Testnet blockchain node
│   │   ├── docker-compose.yml
│   │   ├── drive.sh
│   │   └── persistent-data/
│   └── [other-services]/       # Additional blockchains, services, and infrastructure
├── docs/                        # User documentation
└── README.md                    # This file
```

---

## Available Services

### Infinite Mainnet

Full blockchain node for **Infinite Improbability Chain** mainnet network.

**Location:** `drive/services/infinite-mainnet/`

**Getting Started:** See the [Quick Start Guide](docs/quick-start.md) for complete setup instructions.

### Infinite Testnet

Full blockchain node for **Infinite Improbability Chain** testnet network.

**Location:** `drive/services/infinite-testnet/`

**Note:** Uses different environment variables (chain ID, genesis URL, etc.) configured in its `docker-compose.yml` to connect to the testnet network.

---

## Documentation

**Start here:** [Quick Start Guide](docs/quick-start.md)

**Full Documentation:**
- [Quick Start](docs/quick-start.md) - Get started in 5 minutes
- [Node Operations](docs/node-operations.md) - Complete guide to node commands
- [Container Management](docs/container-management.md) - Container management with `drive.sh`
- [Configuration](docs/configuration.md) - Service configuration guide
- [Port Allocation](docs/PORT_ALLOCATION.md) - Port allocation strategy for multiple services
- [Monitoring](docs/monitoring.md) - Monitor your services
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Key Management](docs/key-management.md) - Comprehensive key management guide

---

## Managing Multiple Services

Each service is completely independent. Run multiple services simultaneously:

```bash
# Mainnet node
cd services/infinite-mainnet
./drive.sh up -d

# Testnet node (in another terminal)
cd services/infinite-testnet
./drive.sh up -d
```

**Note:** Each service has its own `drive.sh` script for easy container management with automatic permission handling.

Each service maintains its own:
- Container name
- Persistent data directory
- Network configuration
- Environment variables

---

## Architecture

Drive is designed as an **open service orchestrator** that:

- **Isolates services** - Each service runs independently
- **Manages resources** - Each service can have different resource limits
- **Simplifies deployment** - Standard Docker Compose workflow with `drive.sh` wrapper for easy management
- **Enables scaling** - Easy to add new services or duplicate existing ones
- **Multi-blockchain ready** - Extensible architecture supports any blockchain or service

---

## Adding New Services

Drive's open architecture allows you to add any blockchain node or service. To add a new service:

1. Create a new directory under `drive/services/`
2. Copy `docker-compose.yml` from an existing service as a template
3. Modify environment variables and configuration as needed
4. Update the service name and container name to be unique
5. Create a `persistent-data/` directory (will be git-ignored automatically)

Whether it's another blockchain, a database, a web service, or any containerized application, Drive provides the same unified management interface.

**Example structure:**
```
drive/services/my-new-service/
├── docker-compose.yml
└── persistent-data/
    └── README.md
```

---

## Data Persistence

Each service maintains its own `persistent-data/` directory that is:
- **Git-ignored** - Data is not tracked in version control
- **Service-specific** - Each service has isolated data
- **Persistent** - Data survives container restarts

The `persistent-data/` directory structure is automatically ignored by Git using the pattern `**/persistent-data/*` in `.gitignore`.

---

## Community

- **Project**: [infinitedrive.xyz](https://infinitedrive.xyz)
- **Lab**: [Deep Thought Labs](https://deep-thought.computer) - Research laboratory developing Infinite Drive
- **X**: [@DeepThought_Lab](https://x.com/DeepThought_Lab)
- **Telegram**: Deep Thought Labs
- **Blockchain**: [Infinite Improbability Chain](https://github.com/deep-thought-labs/infinite) - Main repository
- **Client**: [Drive](https://github.com/deep-thought-labs/drive) - Infrastructure management client (this repository)
- **Docs**: [Getting Started with Infinite Drive](https://github.com/deep-thought-labs/infinite)

---

## Contributing

Drive is an open infrastructure management platform, designed for **Infinite Improbability Chain** and extensible to any blockchain or service. Part of the **Infinite Drive** ecosystem and **Project 42**. When contributing:

1. Follow the service structure conventions
2. Document new services in the `docs/` directory
3. Ensure each service is self-contained
4. Update this README when adding new service types

For contributions to **Infinite Improbability Chain** itself, see the [Infinite repository](https://github.com/deep-thought-labs/infinite).

---

## License

Apache 2.0

---

## Support

For issues, questions, or contributions, please refer to the [documentation](docs/quick-start.md) or open an issue in the repository.

---

_Part of Project 42. Building infrastructure for the cypherpunk nation. A [Deep Thought Labs](https://deep-thought.computer) project._
