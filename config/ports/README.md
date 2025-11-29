# Port Configuration Reference

This directory contains all port configuration documentation and service-specific port mappings.

## Structure

- **[strategy.md](./strategy.md)** - Port allocation strategy and logic
- **[reference.md](./reference.md)** - Detailed descriptions of all port types
- **[services/](./services/)** - Service-specific port configurations

## Service-Specific Configurations

- **[node0-infinite.md](./services/node0-infinite.md)** - Infinite Mainnet (Service #0)
- **[node1-infinite-testnet.md](./services/node1-infinite-testnet.md)** - Infinite Testnet (Service #1)
- **[node2-infinite-creative.md](./services/node2-infinite-creative.md)** - Creative Network (Service #2)
- **[node3-qom.md](./services/node3-qom.md)** - QOM Network (Service #3)
- **[service4-nginx.md](./services/service4-nginx.md)** - Nginx Web Server (Service #4) ⚠️ **Exception:** uses standard ports 80/443

## Quick Start

1. Read [strategy.md](./strategy.md) to understand the port allocation system
2. Check [reference.md](./reference.md) for detailed port descriptions
3. Find your service in [services/](./services/) for complete configuration

## See Also

- [Environment Variables](../environment/reference.md) - Environment variables reference

