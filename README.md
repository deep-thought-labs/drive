# Drive

**Infrastructure management platform for Infinite Drive and beyond. Orchestrate services. Deploy nodes. Scale infrastructure.**

> _A cypherpunk nation in cyberspace. Powered by improbability._

---

## The Platform

| Feature                    | Status                      |
| -------------------------- | --------------------------- |
| Multi-Service Orchestration | ✅ Independent services      |
| Infinite Mainnet Node      | ✅ Full blockchain node      |
| Infinite Testnet Node      | ✅ Testnet support           |
| Graphical Interface        | ✅ Self-descriptive UI       |
| Persistent Data            | ✅ Isolated per service      |
| Docker Compose             | ✅ Standard workflow         |

---

## Infinite Drive Network

**Chain ID**: `infinite_421018-1`  
**Token**: Improbability (TEA)  
**Bech32**: `infinite`

> _The drive runs on tea. Properly prepared._

For more information about Infinite Drive, visit the [project repository](https://github.com/deep-thought-labs/infinite).

---

## Quick Start

### Prerequisites

- Docker (20.10+)
- Docker Compose (1.29+)

### Run a Node (Easiest Method)

The easiest way to manage your node is through the built-in graphical interface:

```bash
cd drive/services/infinite-mainnet
docker compose up -d
docker compose exec infinite-mainnet node-ui
```

The graphical interface provides visual menus for all operations - no command memorization needed.

**Full Guide** → [Quick Start](docs/quick-start.md)

### Command Line (Advanced)

```bash
cd drive/services/infinite-mainnet
docker compose up -d
docker compose exec infinite-mainnet node-init
docker compose exec infinite-mainnet node-start
```

---

## Project Structure

```
drive/
├── services/                    # Service definitions
│   ├── infinite-mainnet/        # Infinite Mainnet blockchain node
│   │   ├── docker-compose.yml  # Service configuration
│   │   └── persistent-data/    # Persistent blockchain data (git-ignored)
│   ├── infinite-testnet/       # Infinite Testnet blockchain node
│   │   ├── docker-compose.yml
│   │   └── persistent-data/
│   └── [other-services]/       # Future services (DNS, web servers, etc.)
├── docs/                        # User documentation
└── README.md                    # This file
```

---

## Available Services

### Infinite Mainnet

Full blockchain node for the Infinite Drive mainnet network.

**Location:** `drive/services/infinite-mainnet/`

**Quick Commands:**
```bash
cd drive/services/infinite-mainnet
docker compose up -d
docker compose exec infinite-mainnet node-ui
```

### Infinite Testnet

Full blockchain node for the Infinite Drive testnet network.

**Location:** `drive/services/infinite-testnet/`

**Note:** Uses different environment variables (chain ID, genesis URL, etc.) configured in its `docker-compose.yml` to connect to the testnet network.

---

## Documentation

**Start here:** [Quick Start Guide](docs/quick-start.md)

**Full Documentation:**
- [Quick Start](docs/quick-start.md) - Get started in 5 minutes
- [Node Operations](docs/node-operations.md) - Complete guide to node commands
- [Container Management](docs/container-management.md) - Docker Compose commands
- [Configuration](docs/configuration.md) - Service configuration guide
- [Monitoring](docs/monitoring.md) - Monitor your services
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Key Management](docs/key-management.md) - Comprehensive key management guide

---

## Managing Multiple Services

Each service is completely independent. Run multiple services simultaneously:

```bash
# Mainnet node
cd drive/services/infinite-mainnet
docker compose up -d

# Testnet node (in another terminal)
cd drive/services/infinite-testnet
docker compose up -d
```

Each service maintains its own:
- Container name
- Persistent data directory
- Network configuration
- Environment variables

---

## Architecture

Drive is designed as a **service orchestrator** that:

- **Isolates services** - Each service runs independently
- **Manages resources** - Each service can have different resource limits
- **Simplifies deployment** - Standard Docker Compose workflow
- **Enables scaling** - Easy to add new services or duplicate existing ones

---

## Adding New Services

To add a new service:

1. Create a new directory under `drive/services/`
2. Copy `docker-compose.yml` from an existing service as a template
3. Modify environment variables and configuration as needed
4. Update the service name and container name to be unique
5. Create a `persistent-data/` directory (will be git-ignored automatically)

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
- **Lab**: [deep-thought.computer](https://deep-thought.computer)
- **X**: [@DeepThought_Lab](https://x.com/DeepThought_Lab)
- **Telegram**: Deep Thought Labs
- **Docs**: [Getting Started with Infinite Drive](https://github.com/deep-thought-labs/infinite)
- **Repository**: [deep-thought-labs/infinite](https://github.com/deep-thought-labs/infinite)

---

## Contributing

This is an independent repository for infrastructure management. When contributing:

1. Follow the service structure conventions
2. Document new services in the `docs/` directory
3. Ensure each service is self-contained
4. Update this README when adding new service types

---

## License

Apache 2.0

---

## Support

For issues, questions, or contributions, please refer to the [documentation](docs/quick-start.md) or open an issue in the repository.

---

_Project 42. The answer was always infrastructure._
