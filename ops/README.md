# Drive Ops

Utility scripts for managing Drive services (update, future Encic and TUI).

## update-drive.sh

Automatically updates all Drive services by:

1. **Detecting running services** - Identifies which services are currently running
2. **Stopping all services** - Safely stops all running services using `drive.sh down`
3. **Cleaning git changes** - Removes any uncommitted changes using `git restore`
4. **Updating repository** - Pulls latest changes from the remote repository
5. **Restarting services** - Restarts only the services that were running before the update

### Usage

From the repository root:

```bash
./ops/update-drive.sh
```

Or from anywhere:

```bash
cd /path/to/drive
./ops/update-drive.sh
```

### What it does

1. **Service Detection**: Scans all services in `services/` directory and checks which ones are running
2. **Safe Shutdown**: Stops each running service gracefully using `drive.sh down`
3. **Git Cleanup**: 
   - Restores only tracked files to their committed state
   - **Preserves all untracked files** (including persistent-data)
   - Does NOT delete any untracked files to prevent data loss
4. **Repository Update**: Pulls latest changes from the current branch
5. **Service Restart**: Restarts only the services that were running before the update

### Features

- ✅ **Safe**: Only restarts services that were running before
- ✅ **Automatic**: Detects and handles everything automatically
- ✅ **Clean**: Removes all uncommitted changes before updating
- ✅ **Informative**: Shows progress and summary of operations

### Example Output

```
==========================================
Drive Update Script
==========================================

📋 Step 1: Detecting running services...

   ✓ node0-infinite is running
   ○ node1-infinite-testnet is not running
   ○ node2-infinite-creative is not running
   ○ node3-qom is not running

Found 1 running service(s)

📋 Step 2: Stopping all services...

⏹️  Stopping node0-infinite...
✅ node0-infinite stopped

📋 Step 3: Cleaning git changes...

✅ No git changes to clean

📋 Step 4: Updating repository (git pull)...

Pulling latest changes from main...
✅ Repository updated successfully

📋 Step 5: Restarting previously running services...

Restarting 1 service(s)...

🚀 Starting node0-infinite...
✅ node0-infinite started

✅ All services restarted

==========================================
✅ Drive update completed successfully!
==========================================

📊 Summary:

   Services stopped: 1
   Services restarted: 1
   Repository updated: ✅

Restarted services:
   - node0-infinite

All done! 🎉
```

### Notes

- The script must be run from the repository root or with the correct path
- Requires `git` to be installed and the repository to be a valid git repository
- Services must have valid `docker-compose.yml` and `drive.sh` files
- The script preserves the state of which services were running
- **IMPORTANT**: The script only restores tracked files. All untracked files (including data in `persistent-data/`) are preserved to prevent data loss
