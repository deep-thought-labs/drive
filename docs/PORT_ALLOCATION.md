# Port Allocation

> **📖 Complete Port Documentation:** This is a quick reference. For complete port allocation strategy, detailed port descriptions, and service-specific configurations, see the [Port Configuration Documentation](../config/ports/strategy.md).

## Quick Reference

Port configuration documentation is organized in the `config/ports/` directory:

- **[Port Allocation Strategy](../config/ports/strategy.md)** - Complete strategy and logic for port allocation
- **[Port Reference Guide](../config/ports/reference.md)** - Detailed descriptions of all port types
- **[Service-Specific Port Configurations](../config/ports/services/)** - Individual port configurations for each service:
  - [node0-infinite.md](../config/ports/services/node0-infinite.md) - Infinite Mainnet (Service #0)
  - [node1-infinite-testnet.md](../config/ports/services/node1-infinite-testnet.md) - Infinite Testnet (Service #1)
  - [node2-infinite-creative.md](../config/ports/services/node2-infinite-creative.md) - Creative Network (Service #2)
  - [node3-qom.md](../config/ports/services/node3-qom.md) - QOM Network (Service #3)

## Why These Files Are Important

The port configuration files in `config/ports/` provide:

- **Complete port mappings** - All ports (required and optional) for each service
- **Port calculation formulas** - How ports are calculated based on service number
- **Firewall examples** - Ready-to-use firewall configuration commands
- **Docker Compose examples** - Copy-paste ready port configurations
- **Service-specific details** - Tailored information for each blockchain network

These files are the **source of truth** for port configuration. Always refer to them when configuring ports for your services.

## See Also

- [Port Allocation Strategy](../config/ports/strategy.md) - Start here for understanding the port system
- [Environment Variables Reference](../config/environment/reference.md) - Complete environment variables documentation

