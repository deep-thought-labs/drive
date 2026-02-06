# QOM Network Service (node3-qom)

Service configuration for running a QOM blockchain node (`qom_766-1`). Uses Docker Compose with the `drive.sh` wrapper script for easy container management.

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

## Network Configuration

This service is configured for **QOM** (`qom_766-1`). Ports (service #3, +30 offset):

- P2P: `26686:26656`
- RPC: `26687:26657`
- gRPC (optional): `9120:9090` — enable in `docker-compose.yml` if you want to use this node as RPC/gRPC for Hermes or other clients.

---

## Exponer este nodo como RPC (para Hermes u otros clientes)

Para usar **tu propio nodo QOM** como RPC (y gRPC) en lugar de un endpoint público, edita solo lo siguiente.

### 1. `docker-compose.yml` (puertos)

- **RPC** — Ya está mapeado: `26687:26657`. No hace falta cambiarlo.
- **gRPC** — Hermes necesita gRPC. Descomenta la línea de gRPC en `ports:`:
  ```yaml
  - "9120:9090"    # gRPC
  ```
  Así el host expone el puerto **9120** (gRPC) además del **26687** (RPC).

### 2. Archivos de config del nodo (después del primer arranque)

Los genera el contenedor en `persistent-data/` al inicializar. Revisa o edita **solo si** el RPC/gRPC no son accesibles desde fuera del contenedor:

| Archivo | Sección / clave | Valor a contemplar |
|--------|-------------------|--------------------|
| `persistent-data/config/config.toml` | `[rpc]` → `laddr` | Debe escuchar en todas las interfaces: `tcp://0.0.0.0:26657`. Si aparece `127.0.0.1`, cámbialo a `0.0.0.0` para que Docker pueda mapear el puerto. |
| `persistent-data/config/app.toml` | `[grpc]` → `enable` | `true` para activar gRPC. |
| `persistent-data/config/app.toml` | `[grpc]` → `address` | Debe ser `0.0.0.0:9090` (no solo `localhost`) para que sea accesible desde el host. |

Tras editar `config.toml` o `app.toml`, reinicia el servicio: `./drive.sh restart`.

### 3. Cómo usar esta URL en Hermes

- **Desde la misma máquina:**  
  `rpc_addr = 'http://127.0.0.1:26687'`  
  `grpc_addr = 'http://127.0.0.1:9120'`  
  Para WebSocket (event_source push): `url = 'ws://127.0.0.1:26687/websocket'`.

- **Desde otro equipo (o relayer en otro contenedor):**  
  Sustituye `127.0.0.1` por la IP o el hostname del servidor donde corre node3-qom (y asegura que los puertos 26687 y 9120 estén abiertos en el firewall si aplica).

## Files

- `docker-compose.yml` - Service configuration
- `drive.sh` - Helper script for automatic permission handling
- `persistent-data/` - Blockchain data directory (created automatically)

## Documentation

For complete documentation, see:
- [Quick Start Guide](../../docs/quick-start.md)
- [Container Management](../../docs/container-management.md)
- [Node Operations](../../docs/node-operations.md)

## Running Testnet and Mainnet Simultaneously

You can run both testnet and mainnet nodes at the same time:

```bash
# Terminal 1: Mainnet
cd services/node0-infinite
./drive.sh up -d

# Terminal 2: Testnet
cd services/node1-node1-infinite-testnet
./drive.sh up -d
```

Each service maintains its own:
- Container name
- Persistent data directory
- Network ports
- Configuration

