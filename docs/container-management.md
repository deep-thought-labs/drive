# Container Management

Essential Docker Compose commands for managing your service containers in Drive. These commands control the container lifecycle and access.

## Working with Services

Each service in Drive has its own directory. Always navigate to the service directory first:

```bash
# Navigate to your service
cd drive/services/infinite-mainnet
```

## Start Container

### Using Graphical Interface (Easiest)

The easiest way to start and manage containers is through the graphical interface:

```bash
cd drive/services/infinite-mainnet
docker compose up -d
docker compose exec infinite-mainnet node-ui
```

The interface provides visual options for all container operations.

### Using Command Line

```bash
# Navigate to service directory
cd drive/services/infinite-mainnet

# Create and start container
docker compose up -d

# Start existing container (if stopped)
docker compose start
```

**What it does:**
- `docker compose up -d`: Creates the container if it doesn't exist and starts it in detached mode (background). The `-d` flag means it won't block your terminal.
- `docker compose start`: Starts an already-created container that was previously stopped.

**Expected output:**
- `docker compose up -d`: Shows container name and status (e.g., `infinite-mainnet  Started`)
- `docker compose start`: Minimal output, just confirms the container started

**When to use:**
- `up -d`: First time setup or when recreating the container
- `start`: Quick restart of an existing container

**Note:** Starting the container doesn't start the node. You still need to run `node-start` (through the interface or command line) after the container is running.

## Stop Container

### Using Graphical Interface

```bash
cd drive/services/infinite-mainnet
docker compose exec infinite-mainnet node-ui
# Select "Node Operations" > "Stop Node"
```

### Using Command Line

```bash
cd drive/services/infinite-mainnet

# Stop container (keeps it created)
docker compose stop

# Stop and remove container
docker compose down
```

**What it does:**
- `docker compose stop`: Stops the running container but keeps it created. The container and its data remain, just not running.
- `docker compose down`: Stops the container and removes it. The container is deleted but data volumes persist (unless you use `-v` flag).

**Expected output:**
- `stop`: Shows container name and "Stopped" status
- `down`: Shows "Removed" or "Stopped" for the container

**When to use:**
- `stop`: Temporary stop (e.g., system maintenance) - you can restart with `docker compose start`
- `down`: Complete cleanup or when you want to remove the container entirely

**Important:** Both commands will stop the node if it's running. Use `node-stop` first for graceful shutdown, then stop the container.

## Container Status

```bash
cd drive/services/infinite-mainnet

# Check container status
docker compose ps

# Check specific service
docker compose ps infinite-mainnet
```

**What it does:** Shows the current status of containers managed by docker-compose.

**Expected output:** Table showing:
- Container name
- Image used
- Command running
- Status (Up, Exited, Restarting, etc.)
- Ports mapping

**Example output:**
```
NAME                IMAGE                STATUS       PORTS
infinite-mainnet    infinite-drive:latest   Up 5 minutes   0.0.0.0:26656->26656/tcp, 0.0.0.0:26657->26657/tcp
```

**Status meanings:**
- `Up`: Container is running
- `Exited`: Container stopped (exit code shown)
- `Restarting`: Container is in restart loop
- `Paused`: Container is paused

**When to use:** Quick check to verify container state, especially after starting or stopping.

## Access Container Shell

```bash
cd drive/services/infinite-mainnet
docker compose exec infinite-mainnet bash
```

**What it does:** Opens an interactive bash shell inside the running container.

**Expected output:** You'll see a command prompt inside the container (typically `ubuntu@container-id:/home/ubuntu$` or similar).

**When to use:** 
- Debugging issues
- Manual file inspection
- Running commands that require interactive access
- Exploring the container's file system

**Note:** 
- Container must be running for this to work
- Type `exit` to leave the shell
- You can run `node-*` commands directly from inside the container without the `docker compose exec` prefix

**Alternative:** You can also use `sh` if bash is not available:
```bash
docker compose exec infinite-mainnet sh
```

## Restart Container

```bash
cd drive/services/infinite-mainnet
docker compose restart infinite-mainnet
```

**What it does:** Stops and starts the container in one command. This is faster than `stop` + `start`.

**Expected output:** Shows container name and restart confirmation.

**When to use:** Apply configuration changes that require container restart, or when the container seems stuck.

**Note:** This restarts the container, but the node process inside needs to be started separately with `node-start` if it was running before.

## View Container Logs

```bash
cd drive/services/infinite-mainnet

# All logs
docker compose logs infinite-mainnet

# Follow logs (real-time)
docker compose logs -f infinite-mainnet

# Last N lines
docker compose logs --tail=100 infinite-mainnet

# Last N lines and follow
docker compose logs --tail=100 -f infinite-mainnet
```

**What it does:** Displays logs from the container itself (Docker logs), which may differ from node logs.

**Expected output:** Container startup logs, error messages, and any output from the container's entrypoint or CMD.

**When to use:**
- Debugging container startup issues
- Seeing Docker-level errors
- Verifying container configuration

**Note:** These are container logs, not node logs. Use `node-logs` (through the interface or command line) for blockchain node logs. Container logs are useful for Docker-related issues.

**Options:**
- `-f` or `--follow`: Stream logs in real-time
- `--tail=N`: Show only the last N lines
- `--since=1h`: Show logs from the last hour
- `--until=1h`: Show logs until 1 hour ago

## Remove Container and Data

**⚠️ Warning:** These commands can delete data. Use with caution.

```bash
cd drive/services/infinite-mainnet

# Remove container (keeps volumes/data)
docker compose down

# Remove container and volumes (deletes all data)
docker compose down -v

# Remove data directory manually (from host)
rm -rf ./persistent-data/*
```

**What it does:**
- `docker compose down`: Removes the container but keeps data volumes intact
- `docker compose down -v`: Removes container AND all associated volumes (deletes blockchain data)
- `rm -rf ./persistent-data/*`: Manually deletes data from the host filesystem

**Expected output:**
- `down`: Shows "Removed" for container
- `down -v`: Shows "Removed" for container and volumes
- `rm -rf`: No output (silent deletion)

**When to use:**
- `down`: Remove container but keep data for later use
- `down -v`: Complete reset - remove everything including blockchain data
- Manual deletion: When you need to reset specific data or have permission issues

**⚠️ Critical:** Using `-v` or manual deletion will permanently erase all blockchain data, keys, and configuration. Only use when you want to start completely fresh.

## Rebuild Image

**Note:** In Drive, services use pre-built images from Docker Hub. Rebuilding is typically only needed if you're developing custom images.

```bash
cd drive/services/infinite-mainnet

# Rebuild image
docker compose build

# Rebuild without cache (fresh build)
docker compose build --no-cache

# Rebuild and restart
docker compose up -d --build
```

**What it does:**
- `build`: Rebuilds the image using the Dockerfile, using cache when possible
- `build --no-cache`: Forces a complete rebuild ignoring cache
- `up -d --build`: Rebuilds and starts the container in one command

**Expected output:** Build progress showing each step being executed.

**When to use:** 
- Only if you've modified the Dockerfile or need to build locally
- In Drive, images come pre-built from Docker Hub, so this is rarely needed

## Managing Multiple Services

Each service in Drive is independent. You can manage them separately:

```bash
# Service 1: Mainnet
cd drive/services/infinite-mainnet
docker compose up -d
docker compose exec infinite-mainnet node-ui

# Service 2: Testnet (in another terminal)
cd drive/services/infinite-testnet
docker compose up -d
docker compose exec infinite-testnet node-ui
```

Each service maintains its own:
- Container name
- Persistent data directory (`persistent-data/`)
- Network configuration
- Environment variables

## Important Notes

- **Always navigate to service directory first** - `cd drive/services/<service-name>`
- **Container must be running** to execute node commands (`node-*`)
- **Node must be started separately** with `node-start` after container starts
- **Data persists** in `./persistent-data/` (bind mount from host)
- **Container auto-restarts** unless stopped manually (configured with `restart: unless-stopped`)
- **Stopping the container** stops the node process, but use `node-stop` first for graceful shutdown
- **Use the graphical interface** (`node-ui`) for the easiest management experience

