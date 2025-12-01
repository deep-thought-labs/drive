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
│   └── [other-services]/       # Additional blockchains, services, and infrastructure
└── README.md                    # This file
```

Each service directory contains:
- `docker-compose.yml` - Service configuration
- `drive.sh` - Container management wrapper script
- `persistent-data/` - Persistent blockchain data (git-ignored)

---

## Documentation

Complete documentation for Drive is available in our dedicated documentation repository:

- **📚 Documentation Site:** [docs.infinitedrive.xyz](https://docs.infinitedrive.xyz)
- **📖 GitHub Repository:** [github.com/deep-thought-labs/drive-docs](https://github.com/deep-thought-labs/drive-docs)

---

## Architecture

Drive is designed as an **open service orchestrator** with the following characteristics:

- **Independent Services** - Each service runs in complete isolation with its own container, persistent data, network configuration, and environment variables
- **Unified Management** - All services use the same `drive.sh` wrapper script for consistent container management
- **Extensible** - Easy to add new services or duplicate existing ones; supports any blockchain or containerized application
- **Persistent Storage** - Each service maintains its own `persistent-data/` directory (git-ignored) that survives container restarts

---

## Community

- **Project**: [infinitedrive.xyz](https://infinitedrive.xyz)
- **Lab**: [Deep Thought Labs](https://deep-thought.computer) - Research laboratory developing Infinite Drive
- **X**: [@DeepThought_Lab](https://x.com/DeepThought_Lab)
- **Telegram**: [Deep Thought Computer](https://t.me/+nt8ysid_-8VlMDVh)
- **Client**: [Drive](https://github.com/deep-thought-labs/drive) - Infrastructure management client (this repository)

---

## Contributing

Drive is an open infrastructure management platform, designed for **Infinite Improbability Chain** and extensible to any blockchain or service. Part of the **Infinite Drive** ecosystem and **Project 42**.

Join our Telegram channel to stay in touch with the development team and contribute to the project.

---

## License

Apache 2.0

---

## Support

For issues, questions, or contributions, please refer to the [documentation](https://docs.infinitedrive.xyz) or open an issue in the repository.

---

_Part of Project 42. Building infrastructure for the cypherpunk nation. A [Deep Thought Labs](https://deep-thought.computer) project._
