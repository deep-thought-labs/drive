# Drive

**Open infrastructure management platform. Orchestrate services. Deploy nodes. Scale infrastructure.**

> _A cypherpunk nation in cyberspace. Powered by improbability._

Drive is an open infrastructure management platform designed for **Infinite Improbability Chain** and beyond. Easily orchestrate blockchain nodes, services, and infrastructure with a unified interface. Part of the **Infinite Drive** ecosystem and **Project 42**, developed by [Deep Thought Labs](https://deep-thought.computer). Learn more at [infinitedrive.xyz](https://infinitedrive.xyz)

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

## 🚀 Quick Start

Get started with Drive by following the complete [Quick Start Guide](docs/quick-start.md), which covers prerequisites, firewall configuration, repository setup, node initialization, and both graphical and command-line operations.

**Start here:** [Quick Start Guide](docs/quick-start.md)

---

## Project Structure

```
drive/
├── services/                    # Service definitions
│   ├── infinite-mainnet/        # Infinite Mainnet blockchain node
│   ├── infinite-testnet/       # Infinite Testnet blockchain node
│   └── [other-services]/       # Additional blockchains, services, and infrastructure
├── docs/                        # User documentation
└── README.md                    # This file
```

Each service directory contains:
- `docker-compose.yml` - Service configuration
- `drive.sh` - Container management wrapper script
- `persistent-data/` - Persistent blockchain data (git-ignored)

---

## Available Services

### Infinite Mainnet

Full blockchain node for **Infinite Improbability Chain** mainnet network.

**Location:** `drive/services/infinite-mainnet/`

### Infinite Testnet

Full blockchain node for **Infinite Improbability Chain** testnet network.

**Location:** `drive/services/infinite-testnet/`

**Note:** Configured with different environment variables (chain ID, genesis URL, etc.) to connect to the testnet network.

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

## Architecture

Drive is designed as an **open service orchestrator** with the following characteristics:

- **Independent Services** - Each service runs in complete isolation with its own container, persistent data, network configuration, and environment variables
- **Unified Management** - All services use the same `drive.sh` wrapper script for consistent container management
- **Extensible** - Easy to add new services or duplicate existing ones; supports any blockchain or containerized application
- **Persistent Storage** - Each service maintains its own `persistent-data/` directory (git-ignored) that survives container restarts

---

## Adding New Services

To add a new service:

1. Create a new directory under `drive/services/`
2. Copy `docker-compose.yml` from an existing service as a template
3. Modify environment variables and configuration as needed
4. Update the service name and container name to be unique
5. Create a `persistent-data/` directory (will be git-ignored automatically)

Drive provides the same unified management interface for any blockchain, database, web service, or containerized application.

---

## Community

- **Project**: [infinitedrive.xyz](https://infinitedrive.xyz)
- **Lab**: [Deep Thought Labs](https://deep-thought.computer) - Research laboratory developing Infinite Drive
- **X**: [@DeepThought_Lab](https://x.com/DeepThought_Lab)
- **Telegram**: Deep Thought Labs
- **Client**: [Drive](https://github.com/deep-thought-labs/drive) - Infrastructure management client (this repository)

---

## Contributing

Drive is an open infrastructure management platform, designed for **Infinite Improbability Chain** and extensible to any blockchain or service. Part of the **Infinite Drive** ecosystem and **Project 42**. When contributing:

1. Follow the service structure conventions
2. Document new services in the `docs/` directory
3. Ensure each service is self-contained
4. Update this README when adding new service types

---

## License

Apache 2.0

---

## Support

For issues, questions, or contributions, please refer to the [Quick Start Guide](docs/quick-start.md) or open an issue in the repository.

---

_Part of Project 42. Building infrastructure for the cypherpunk nation. A [Deep Thought Labs](https://deep-thought.computer) project._
