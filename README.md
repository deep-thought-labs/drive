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

### Prerequisites

- Docker (20.10+)
- Docker Compose (1.29+)

**Important Note on Docker Permissions (Linux):**
- You may need to add your user to the `docker` group to run Docker commands without `sudo`
- The `drive.sh` script works with or without `sudo`, but Docker itself requires `sudo` if your user is not in the docker group
- To configure: `sudo usermod -aG docker $USER` (then log out and log back in)
- See [Quick Start Guide](docs/quick-start.md) for complete Docker installation instructions

### Clone the Repository

First, clone the Drive repository to your local machine:

```bash
git clone https://github.com/deep-thought-labs/drive.git
cd drive
```

### Run a Node (Easiest Method)

The easiest way to manage your node is through the built-in graphical interface:

```bash
cd services/node0-infinite
./drive.sh up -d
docker compose exec infinite node-ui
```

**Note:** 
- Use `./drive.sh` instead of `docker compose` for container management commands (up, down, ps, etc.)
- The script automatically handles permissions and works with or without `sudo`
- **If Docker requires `sudo`** (user not in docker group), use `sudo ./drive.sh` instead
- For commands inside the container (`exec`), use `docker compose exec` directly

The graphical interface provides visual menus for all operations - no command memorization needed.

**Full Guide** → [Quick Start](docs/quick-start.md)

### Command Line (Advanced)

```bash
cd services/node0-infinite
./drive.sh up -d
docker compose exec infinite node-init
docker compose exec infinite node-start
```

**Why use `./drive.sh`?** It automatically configures correct user permissions, preventing volume permission errors. See [Container Management](docs/container-management.md) for details.

---

## Project Structure

```
drive/
├── services/                    # Service definitions
│   ├── node0-infinite/          # Infinite Mainnet blockchain node
│   │   ├── docker-compose.yml  # Service configuration
│   │   ├── drive.sh            # Container management wrapper (recommended)
│   │   └── persistent-data/    # Persistent blockchain data (git-ignored)
│   ├── node1-infinite-testnet/ # Infinite Testnet blockchain node
│   │   ├── docker-compose.yml
│   │   ├── drive.sh
│   │   └── persistent-data/
│   ├── service4-nginx/          # Nginx Web Server (⚠️ Exception: uses standard ports 80/443)
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

**Location:** `drive/services/node0-infinite/`

**Quick Commands:**
```bash
cd services/node0-infinite
./drive.sh up -d
docker compose exec infinite node-ui
```

**Note:** Use `./drive.sh` for container management (up, down, ps, etc.) to automatically handle permissions.

### Infinite Testnet

Full blockchain node for **Infinite Improbability Chain** testnet network.

**Location:** `drive/services/node1-infinite-testnet/`

**Quick Commands:**
```bash
cd services/node1-infinite-testnet
./drive.sh up -d
docker compose exec infinite-testnet node-ui
```

### Infinite Creative Network

Full blockchain node for **Infinite Improbability Chain** creative network.

**Location:** `drive/services/node2-infinite-creative/`

**Quick Commands:**
```bash
cd services/node2-infinite-creative
./drive.sh up -d
docker compose exec infinite-creative node-ui
```

### QOM Network

Full blockchain node for **QOM Network**.

**Location:** `drive/services/node3-qom/`

**Quick Commands:**
```bash
cd services/node3-qom
./drive.sh up -d
docker compose exec qom node-ui
```

**Configuration:**
- **Environment Variables:** See [`config/environment/reference.md`](config/environment/reference.md) for all available variables
- **Port Configuration:** See [`config/ports/strategy.md`](config/ports/strategy.md) for port allocation and service-specific configurations

### Nginx Web Server

Primary web server and reverse proxy for Drive infrastructure.

**Location:** `drive/services/service4-nginx/`

**Quick Commands:**
```bash
cd services/service4-nginx
./drive.sh up -d
```

**Access:** Open `http://localhost` in your browser (port 80) or `https://localhost` (port 443)

**⚠️ Important:** This service is an **exception** to the port allocation strategy. It uses standard web ports (80, 443) instead of calculated ports, as it's the primary web/proxy server.

**Configuration:**
- **Port Configuration:** See [`config/ports/services/service4-nginx.md`](config/ports/services/service4-nginx.md) for complete port configuration
- **Directory Structure:**
  - `persistent-data/html/` - Web content (HTML, CSS, JS, images)
  - `persistent-data/conf.d/` - Nginx site configurations
  - `persistent-data/logs/` - Nginx access and error logs
  - `persistent-data/ssl/` - SSL certificates for HTTPS

**Note:** Cache is not persistent and clears on container restart.

---

## Documentation

**Start here:** [Quick Start Guide](docs/quick-start.md)

**Full Documentation:**
- [Quick Start](docs/quick-start.md) - Get started in 5 minutes
- [Node Operations](docs/node-operations.md) - Complete guide to node commands
- [Container Management](docs/container-management.md) - Container management with `drive.sh`
- [Updating the System](docs/update-system.md) - How to update services and Docker images
- [Configuration Reference](config/) - Complete configuration documentation
  - [Environment Variables](config/environment/reference.md) - All available environment variables
  - [Port Allocation Strategy](config/ports/strategy.md) - Port configuration and strategy
  - [Port Reference Guide](config/ports/reference.md) - Detailed port descriptions
  - [Service-Specific Configurations](config/ports/services/) - Individual service port configurations

---

## Managing Multiple Services

Each service is completely independent. Run multiple services simultaneously:

```bash
# Mainnet node
cd services/node0-infinite
./drive.sh up -d

# Testnet node (in another terminal)
cd services/node1-infinite-testnet
./drive.sh up -d

# Creative Network node
cd services/node2-infinite-creative
./drive.sh up -d

# QOM Network node
cd services/node3-qom
./drive.sh up -d

# Nginx Web Server
cd services/service4-nginx
./drive.sh up -d
```

**Note:** Each service has its own `drive.sh` script for easy container management with automatic permission handling.

Each service maintains its own:
- Container name
- Persistent data directory
- Network configuration (ports are automatically allocated based on service number)
- Environment variables

**Configuration Reference:**
- **Port Configuration:** Each service's ports are documented in [`config/ports/services/`](config/ports/services/) - see the service-specific file for complete port mappings
- **Environment Variables:** All available variables are documented in [`config/environment/reference.md`](config/environment/reference.md) - this is the complete reference for all configuration options

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
