# Container Management

Essential commands for managing your service containers in Drive using the `drive.sh` wrapper script. These commands control the container lifecycle and access.

## Quick Start: Using the Wrapper Script

**Recommended for all users:** Each service includes a `drive.sh` script that automatically handles permission configuration. Use it instead of `docker compose` directly:

```bash
cd drive/services/node0-infinite

# Instead of: docker compose up -d
./drive.sh up -d

# Instead of: docker compose down
./drive.sh down

# Instead of: docker compose ps
./drive.sh ps

# Works with any docker-compose command!
```

**Benefits:**
- ✅ Automatically configures correct user permissions
- ✅ Works with or without `sudo` (handles both cases automatically)
- ✅ No need to manually set environment variables
- ✅ Prevents permission errors when writing to volumes

**Important Note on Docker Permissions:**
- **If Docker requires `sudo`** (user not in docker group), you must use `sudo ./drive.sh` - the script will detect and handle this correctly
- **If Docker works without `sudo`** (user in docker group), use `./drive.sh` directly
- The script automatically detects your real user ID whether you use `sudo` or not, ensuring correct volume permissions

**To avoid needing `sudo` with Docker:**
```bash
# Add your user to the docker group (Linux only)
sudo usermod -aG docker $USER
# Then log out and log back in
```

**Note:** All examples below show both the wrapper script (recommended) and direct `docker compose` commands. Use whichever you prefer, but the wrapper script is recommended to avoid permission issues.

## Working with Services

Each service in Drive has its own directory. Always navigate to the service directory first:

```bash
# Navigate to your service
cd drive/services/node0-infinite
```

## Start Container

### Using Graphical Interface (Easiest)

The easiest way to start and manage containers is through the graphical interface:

```bash
cd drive/services/node0-infinite
./drive.sh up -d
docker compose exec infinite node-ui
```

**Note:** Use `./drive.sh` for container management (up, down, ps, etc.) and `docker compose exec` for commands inside the container.

The interface provides visual options for all container operations.

### Using Command Line

**Recommended: Use the wrapper script for automatic permission handling**

```bash
# Navigate to service directory
cd drive/services/node0-infinite

# Use the wrapper script (automatically handles permissions)
# If Docker requires sudo, use: sudo ./drive.sh up -d
# If Docker works without sudo, use: ./drive.sh up -d
./drive.sh up -d

# Start existing container (if stopped)
./drive.sh start
```

**Note:** If you get a "permission denied" error when running `./drive.sh`, it means Docker requires `sudo`. In that case, use `sudo ./drive.sh` instead. The script handles both cases correctly.

**Alternative: Direct docker-compose (requires manual permission setup)**

```bash
# Navigate to service directory
cd drive/services/node0-infinite

# Create and start container
docker compose up -d

# Start existing container (if stopped)
docker compose start
```

**Note:** If you encounter permission issues with direct `docker compose` commands, use the wrapper script (`drive.sh`) instead, or see the [Fixing Permission Issues](#fixing-permission-issues) section below.

**What it does:**
- `./drive.sh up -d`: Creates the container if it doesn't exist and starts it in detached mode (background). The `-d` flag means it won't block your terminal.
- `./drive.sh start`: Starts an already-created container that was previously stopped.

**Expected output:**
- `./drive.sh up -d`: Shows container name and status (e.g., `node0-infinite  Started`)
- `./drive.sh start`: Minimal output, just confirms the container started

**When to use:**
- `up -d`: First time setup or when recreating the container
- `start`: Quick restart of an existing container

**Note:** Starting the container doesn't start the node. You still need to run `node-start` (through the interface or command line) after the container is running.

## Stop Container

### Using Graphical Interface

```bash
cd drive/services/node0-infinite
docker compose exec infinite node-ui
# Select "Node Operations" > "Stop Node"
```

### Using Command Line

```bash
cd drive/services/node0-infinite

# Stop container (keeps it created)
./drive.sh stop

# Stop and remove container
./drive.sh down
```

**What it does:**
- `./drive.sh stop`: Stops the running container but keeps it created. The container and its data remain, just not running.
- `./drive.sh down`: Stops the container and removes it. The container is deleted but data volumes persist (unless you use `-v` flag).

**Expected output:**
- `stop`: Shows container name and "Stopped" status
- `down`: Shows "Removed" or "Stopped" for the container

**When to use:**
- `stop`: Temporary stop (e.g., system maintenance) - you can restart with `./drive.sh start`
- `down`: Complete cleanup or when you want to remove the container entirely

**Important:** Both commands will stop the node if it's running. Use `node-stop` first for graceful shutdown, then stop the container.

## Container Status

```bash
cd drive/services/node0-infinite

# Check container status
./drive.sh ps

# Check specific service (same command, docker-compose filters automatically)
./drive.sh ps node0-infinite
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
node0-infinite    infinite-drive:latest   Up 5 minutes   0.0.0.0:26656->26656/tcp, 0.0.0.0:26657->26657/tcp
```

**Status meanings:**
- `Up`: Container is running
- `Exited`: Container stopped (exit code shown)
- `Restarting`: Container is in restart loop
- `Paused`: Container is paused

**When to use:** Quick check to verify container state, especially after starting or stopping.

## Access Container Shell

```bash
cd drive/services/node0-infinite
docker compose exec infinite bash
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
docker compose exec infinite sh
```

## Restart Container

```bash
cd drive/services/node0-infinite
./drive.sh restart node0-infinite
```

**What it does:** Stops and starts the container in one command. This is faster than `stop` + `start`.

**Expected output:** Shows container name and restart confirmation.

**When to use:** Apply configuration changes that require container restart, or when the container seems stuck.

**Note:** This restarts the container, but the node process inside needs to be started separately with `node-start` if it was running before.

## View Container Logs

```bash
cd drive/services/node0-infinite

# All logs
./drive.sh logs node0-infinite

# Follow logs (real-time)
./drive.sh logs -f node0-infinite

# Last N lines
./drive.sh logs --tail=100 node0-infinite

# Last N lines and follow
./drive.sh logs --tail=100 -f node0-infinite
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
cd drive/services/node0-infinite

# Remove container (keeps volumes/data)
./drive.sh down

# Remove container and volumes (deletes all data)
./drive.sh down -v

# Remove data directory manually (from host)
rm -rf ./persistent-data/*
```

**What it does:**
- `./drive.sh down`: Removes the container but keeps data volumes intact
- `./drive.sh down -v`: Removes container AND all associated volumes (deletes blockchain data)
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

## Fixing Permission Issues

If you encounter permission errors when the container tries to write to the `persistent-data/` directory, it's likely because your user ID (UID) or group ID (GID) on the host doesn't match the default `1000:1000` used in the container.

### Symptoms
- Container fails to write files to `persistent-data/`
- Permission denied errors in logs
- Node initialization fails
- Cannot create or modify files in the mounted volume

### Solution

The `docker-compose.yml` file now supports custom user IDs through environment variables. You can fix permission issues by setting your host user's UID and GID. **The solution works the same whether you use `sudo` or not.**

**Option 0: Use the wrapper script (easiest - recommended)**
```bash
cd drive/services/node0-infinite

# Use the wrapper script instead of docker-compose directly
# It automatically configures permissions and works with or without sudo
# If Docker requires sudo, use: sudo ./drive.sh up -d
# If Docker works without sudo, use: ./drive.sh up -d
./drive.sh up -d
./drive.sh down
./drive.sh ps
# Works with any docker-compose command!
```

**Important:** The `drive.sh` script supports both `sudo` and non-sudo usage, but **Docker itself** may require `sudo` if your user is not in the docker group. If you get permission errors, use `sudo ./drive.sh` instead.

The wrapper script (`drive.sh`) automatically:
- Detects your user ID and group ID (works with or without sudo)
- Configures `PUID` and `PGID` environment variables correctly
- Executes docker-compose with the correct permissions
- Passes all arguments to docker-compose (works with any docker-compose command)
- **Handles Docker's sudo requirement** - if Docker needs sudo, use `sudo ./drive.sh`

**To configure Docker to work without sudo (Linux):**
```bash
# Add your user to the docker group
sudo usermod -aG docker $USER
# Log out and log back in for changes to take effect
```

**Option 1: Set environment variables (works with or without sudo)**
```bash
cd drive/services/node0-infinite

# This automatically detects your real user ID, even when using sudo
export PUID=${SUDO_UID:-$(id -u)}
export PGID=${SUDO_GID:-$(id -g)}

# Start the container (works with or without sudo)
# Use drive.sh which handles this automatically
./drive.sh up -d
# or if Docker requires sudo
sudo ./drive.sh up -d
```

**Option 2: Set inline when starting (not needed with drive.sh)**
```bash
cd drive/services/node0-infinite

# drive.sh handles this automatically, but if using docker compose directly:
# Without sudo
PUID=$(id -u) PGID=$(id -g) docker compose up -d

# With sudo (automatically uses SUDO_UID/SUDO_GID)
PUID=${SUDO_UID:-$(id -u)} PGID=${SUDO_GID:-$(id -g)} sudo docker compose up -d
```

**Note:** Using `./drive.sh` is recommended as it handles this automatically.

**Option 3: Add to your shell profile (permanent - works with or without sudo)**
```bash
# Add to ~/.bashrc or ~/.zshrc
# This will work whether you use sudo or not
export PUID=${SUDO_UID:-$(id -u)}
export PGID=${SUDO_GID:-$(id -g)}
```

**How it works:**
- `${SUDO_UID:-$(id -u)}` means: use `SUDO_UID` if it exists (when using sudo), otherwise use `$(id -u)`
- When you use `sudo`, the environment variables `SUDO_UID` and `SUDO_GID` are automatically set to your real user's IDs
- When you don't use `sudo`, it falls back to `$(id -u)` and `$(id -g)`
- This ensures the container always runs with your real user's permissions, not root's

After setting these variables, restart the container:
```bash
./drive.sh down
./drive.sh up -d
```

**What it does:**
- `PUID`: Your user ID on the host system (detects automatically, works with or without sudo)
- `PGID`: Your group ID on the host system (detects automatically, works with or without sudo)
- The container will run with these IDs, matching your host user permissions
- If not set, defaults to `1000:1000` (works for most Linux systems)
- **Important:** Works identically whether you use `sudo` or not - it automatically detects your real user ID

**Verification:**
```bash
# Check what UID/GID the container is using
docker compose exec infinite id

# Should match your host user ID
id
```

**Note:** Use `docker compose exec` for commands inside the container, and `./drive.sh` for container management commands.

**Note:** If you've already created files with wrong permissions, you may need to fix them:
```bash
# Fix ownership of existing data (works with or without sudo)
# This uses your real user ID, even if you run it with sudo
sudo chown -R ${SUDO_UID:-$(id -u)}:${SUDO_GID:-$(id -g)} ./persistent-data
```

## Rebuild Image

**Note:** In Drive, services use pre-built images from Docker Hub. Rebuilding is typically only needed if you're developing custom images.

```bash
cd drive/services/node0-infinite

# Rebuild image
./drive.sh build

# Rebuild without cache (fresh build)
./drive.sh build --no-cache

# Rebuild and restart
./drive.sh up -d --build
```

**What it does:**
- `build`: Rebuilds the image using the Dockerfile, using cache when possible
- `build --no-cache`: Forces a complete rebuild ignoring cache
- `up -d --build`: Rebuilds and starts the container in one command

**Expected output:** Build progress showing each step being executed.

**When to use:** 
- Only if you've modified the Dockerfile or need to build locally
- In Drive, images come pre-built from Docker Hub, so this is rarely needed

## Updating the System

This section explains how to update both the repository code and Docker images to ensure you're running the latest version of the system.

### Overview

The update process involves:
1. Stopping running containers
2. Updating the Git repository (drive)
3. Updating Docker images
4. Restarting services

**Important:** The `drive` repository is an independent Git repository (submodule). Always perform Git operations from the `drive` root directory.

### Complete Update Process

#### Step 1: Stop All Services

Stop all running services before updating:

```bash
# Stop each service individually
cd services/node0-infinite
./drive.sh down

cd ../node1-infinite-testnet
./drive.sh down

cd ../node2-infinite-creative
./drive.sh down

cd ../node3-qom
./drive.sh down
```

**Alternative:** If you want to stop all services at once, you can use a loop:

```bash
# From drive root directory
for service in services/node*/; do
    cd "$service"
    ./drive.sh down
    cd ../..
done
```

#### Step 2: Update Git Repository

Navigate to the `drive` root directory and pull the latest changes:

```bash
# Navigate to drive root
cd /path/to/drive  # or wherever your drive repository is located

# Pull latest changes from Git
git pull

# If drive is a submodule, you may need to update submodules:
# git submodule update --remote --merge
```

**Note:** If you encounter conflicts or need to reset to the latest version:

```bash
# Fetch latest changes
git fetch origin

# Reset to latest (WARNING: discards local changes)
git reset --hard origin/main  # or origin/dev, depending on your branch

# Or merge/rebase if you have local changes
git pull --rebase
```

#### Step 3: Update Docker Images

Since all services use the same image (`deepthoughtlabs/infinite-drive:dev`), you only need to pull it once from any service directory:

```bash
# Navigate to any service directory
cd services/node0-infinite

# Pull the latest image from Docker Hub
docker compose pull
```

**What this does:**
- Downloads/updates the `deepthoughtlabs/infinite-drive:dev` image from Docker Hub
- The updated image is available globally for all services (Docker images are shared system-wide)
- You don't need to run `pull` in each service directory

**Verify the image was updated:**

```bash
# Check image details
docker images | grep "deepthoughtlabs/infinite-drive"
```

#### Step 4: Restart Services

After updating both the repository and Docker images, restart each service:

```bash
# Restart each service
cd services/node0-infinite
./drive.sh up -d

cd ../node1-infinite-testnet
./drive.sh up -d

cd ../node2-infinite-creative
./drive.sh up -d

cd ../node3-qom
./drive.sh up -d
```

**Alternative:** Restart all services at once:

```bash
# From drive root directory
for service in services/node*/; do
    cd "$service"
    ./drive.sh up -d
    cd ../..
done
```

### Quick Update (Single Service)

If you only need to update a single service:

```bash
# Navigate to the service directory
cd services/node0-infinite

# Stop the service
./drive.sh down

# Update Docker image
docker compose pull

# Restart the service
./drive.sh up -d
```

**Note:** For code updates, you still need to update the Git repository from the `drive` root directory.

### Update Checklist

Use this checklist to ensure a complete update:

- [ ] Stop all running services (`./drive.sh down` in each service)
- [ ] Navigate to `drive` root directory
- [ ] Pull latest Git changes (`git pull`)
- [ ] Navigate to any service directory
- [ ] Pull latest Docker image (`docker compose pull`)
- [ ] Restart all services (`./drive.sh up -d` in each service)
- [ ] Verify services are running (`./drive.sh ps`)

### Troubleshooting Updates

**Issue: Git pull fails with conflicts**

```bash
# Option 1: Stash local changes
git stash
git pull
git stash pop

# Option 2: Reset to remote (WARNING: loses local changes)
git fetch origin
git reset --hard origin/main  # or your branch name
```

**Issue: Docker image not updating**

```bash
# Force pull without cache
docker compose pull --no-cache

# Or remove old image and pull fresh
docker rmi deepthoughtlabs/infinite-drive:dev
docker compose pull
```

**Issue: Service won't start after update**

```bash
# Check container logs
./drive.sh logs

# Recreate container
./drive.sh down
./drive.sh up -d --force-recreate
```

### Important Notes

- **Always stop services before updating** to prevent data corruption
- **Git operations** should be performed from the `drive` root directory
- **Docker image pull** only needs to be done once (images are shared system-wide)
- **Restart each service** after updating to use the new image
- **Use `drive.sh`** for all container management commands when possible
- **Backup important data** before major updates if needed

## Managing Multiple Services

Each service in Drive is independent. You can manage them separately:

```bash
# Service 1: Mainnet
cd drive/services/node0-infinite
./drive.sh up -d
docker compose exec infinite node-ui

# Service 2: Testnet (in another terminal)
cd drive/services/node1-infinite-testnet
./drive.sh up -d
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

