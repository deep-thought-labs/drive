# Updating the System

This guide explains how to update services that use the `deepthoughtlabs/infinite-drive` Docker image. This includes all services with the `node` prefix in their folder name (e.g., `node0-infinite`, `node1-infinite-testnet`, `node2-infinite-creative`, `node3-qom`).

**Note:** 
- The Docker image version (tag) used depends on your environment (e.g., `dev` for development, `latest` or `test` for production). Check your `docker-compose.yml` files to see which version you're using.
- Future services that do not use the `infinite-drive` image may have different update procedures, which will be documented separately.

## Overview

The update process involves:
1. Stopping running containers
2. Updating the Git repository (drive)
3. Updating Docker images
4. Restarting services

**Important:** Always perform Git operations from the `drive` root directory.

## Complete Update Process

### Step 1: Stop All Services

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

### Step 2: Update Git Repository

Navigate to the `drive` root directory and pull the latest changes:

```bash
# Navigate to drive root
cd /path/to/drive  # or wherever your drive repository is located

# Pull latest changes from Git
git pull
```

**Note:** If you encounter conflicts or need to reset to the latest version:

```bash
# Fetch latest changes
git fetch origin

# Get the current branch name
CURRENT_BRANCH=$(git branch --show-current)

# Restore to latest version (WARNING: discards local changes)
# This will restore all files to match the remote repository
git restore .
git reset --hard origin/$CURRENT_BRANCH

# Pull latest changes
git pull
```

**Alternative:** If you prefer to specify the branch manually:

```bash
# Fetch latest changes
git fetch origin

# Restore to latest version (WARNING: discards local changes)
# Replace 'main' with your branch name (e.g., 'dev', 'test', etc.)
git restore .
git reset --hard origin/main  # Change 'main' to your branch name

# Pull latest changes
git pull
```

**Important:** 
- Restoring from the remote repository will update all configuration files to match the latest version
- **Persistent data files (node data, blockchain state, keys, etc.) are NOT affected** - they are stored separately and will remain intact
- Only configuration files in the repository will be updated

### Step 3: Update Docker Images

Since all services use the same Docker image (check your `docker-compose.yml` to see which version/tag you're using), you only need to pull it once from any service directory:

```bash
# Navigate to any service directory
cd services/node0-infinite

# Pull the latest image from Docker Hub
# This will pull the version specified in docker-compose.yml
docker compose pull
```

**What this does:**
- Downloads/updates the Docker image specified in your `docker-compose.yml` file
- The image version depends on your configuration (e.g., `dev` for development, `latest` or `test` for production)
- The updated image is available globally for all services (Docker images are shared system-wide)
- You don't need to run `pull` in each service directory

**Verify the image was updated:**

```bash
# Check image details (shows all infinite-drive images)
docker images | grep "deepthoughtlabs/infinite-drive"
```

**Note:** The image version you're using is specified in each service's `docker-compose.yml` file under the `image:` field. Make sure you're pulling the correct version for your environment.

### Step 4: Restart Services

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

## Quick Update (Single Service)

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

## Update Checklist

Use this checklist to ensure a complete update:

- [ ] Stop all running services (`./drive.sh down` in each service)
- [ ] Navigate to `drive` root directory
- [ ] Pull latest Git changes (`git pull`)
- [ ] Navigate to any service directory
- [ ] Pull latest Docker image (`docker compose pull`)
- [ ] Restart all services (`./drive.sh up -d` in each service)
- [ ] Verify services are running (`./drive.sh ps`)

## Troubleshooting Updates

### Issue: Git pull fails with conflicts

If you encounter conflicts when pulling updates, restore from the remote repository:

```bash
# Navigate to drive root directory
cd /path/to/drive

# Fetch latest changes
git fetch origin

# Get the current branch name automatically
CURRENT_BRANCH=$(git branch --show-current)

# Restore all files to match remote (discards local changes)
git restore .
git reset --hard origin/$CURRENT_BRANCH

# Pull latest changes
git pull
```

**Alternative:** If you prefer to specify the branch manually:

```bash
# Navigate to drive root directory
cd /path/to/drive

# Fetch latest changes
git fetch origin

# Restore all files to match remote (discards local changes)
# Replace 'main' with your actual branch name (e.g., 'dev', 'test', etc.)
git restore .
git reset --hard origin/main  # Change 'main' to your branch name

# Pull latest changes
git pull
```

**Important:** 
- This will restore all configuration files to match the latest version from the repository
- **Your persistent data (node data, blockchain state, keys) will NOT be affected** - these are stored separately
- Only files tracked by Git will be updated

### Issue: Docker image not updating

```bash
# Force pull without cache
docker compose pull --no-cache

# Or remove old image and pull fresh
# First, check which image version you're using in docker-compose.yml
# Then remove that specific image (replace 'dev' with your actual version)
docker rmi deepthoughtlabs/infinite-drive:dev  # Change 'dev' to your version
docker compose pull
```

**Note:** Replace `dev` with the actual image version/tag you're using (check your `docker-compose.yml` file).

### Issue: Service won't start after update

```bash
# Check container logs
./drive.sh logs

# Recreate container
./drive.sh down
./drive.sh up -d --force-recreate
```

## Important Notes

- **Always stop services before updating** to prevent data corruption
- **Git operations** should be performed from the `drive` root directory
- **Docker image pull** only needs to be done once (images are shared system-wide)
- **Restart each service** after updating to use the new image
- **Use `drive.sh`** for all container management commands when possible
- **Persistent data is safe** - node data, blockchain state, and keys are stored separately and will not be affected by Git updates
- **This update process applies to services using `infinite-drive` image** - services with different images may have different procedures
- **Image version depends on your environment** - check `docker-compose.yml` files to see which version you're using (e.g., `dev`, `latest`, `test`)

## See Also

- [Container Management](./container-management.md) - General container management commands
- [Node Operations](./node-operations.md) - Managing blockchain nodes
- [Quick Start](./quick-start.md) - Initial setup guide

