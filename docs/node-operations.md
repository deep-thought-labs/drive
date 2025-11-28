# Node Operations

Complete guide to managing your Infinite Drive blockchain node. This guide covers both the **graphical interface (recommended for beginners)** and **command-line operations (for advanced users)**.

## Quick Access: Graphical Interface (Recommended)

The **easiest way** to manage your node is through the built-in graphical interface. This method requires no command memorization and guides you through every operation.

### Open the Graphical Interface

```bash
# Navigate to your service directory
cd drive/services/node0-infinite

# Start the container (if not running) - use drive.sh for automatic permission handling
./drive.sh up -d

# Open the graphical interface
docker compose exec infinite node-ui
```

**Note:** Use `./drive.sh` for container management commands (up, down, ps, etc.) to automatically handle permissions. Use `docker compose exec` for commands inside the container.

### What You Can Do in the Interface

The graphical interface provides access to all operations through visual menus:

- **Key Management** - Create, list, show, delete keys
- **Node Operations** - Start, stop, restart the node
- **Advanced Operations** - Initialize node, validate genesis, clean data
- **Node Monitoring** - View logs, check status, network diagnosis, system information

**All operations are self-descriptive** - each menu option explains what it does, making it perfect for beginners.

## Available Commands

For command-line operations, here are all available commands:

| Command | Description |
|---------|-------------|
| `node-init` | Initialize node (first time only) |
| `node-init --recover` | Initialize with existing seed phrase |
| `node-keys create [name] [--dry-run]` | Create new cryptographic key (prompts for name if not provided) |
| `node-keys add [name]` | Add existing key from seed phrase to keyring |
| `node-keys list` | List all keys in keyring |
| `node-keys show <name>` | Show detailed information about a specific key |
| `node-keys delete <name> [--yes]` | Delete a key from keyring |
| `node-start` | Start node as daemon |
| `node-stop` | Stop node gracefully |
| `node-process-status` | Check node process status |
| `node-logs` | View node logs |
| `node-help` | Show all available commands |
| `node-ui` | Interactive graphical menu interface (TUI) |

**All commands must be executed from the service directory:**

```bash
cd drive/services/node0-infinite
docker compose exec infinite <command>
```

## Initialize Node

### Using Graphical Interface (Easiest)

1. Open the interface: `docker compose exec infinite node-ui`
2. Navigate to **"Node Operations"** → **"Advanced Operations"**
3. Choose:
   - **"Initialize Node (Simple)"** - For full nodes (no validator keys needed)
   - **"Initialize with Recovery (Validator)"** - For validator nodes (requires seed phrase)
4. Follow the interactive prompts:
   - Enter a moniker (node name) when requested
   - If using recovery mode, enter your seed phrase
   - Confirm any warnings about random keys (if using simple mode)

### Using Command Line

#### Simple Initialization

```bash
cd drive/services/node0-infinite
docker compose exec infinite node-init
```

**What it does:** Creates a new node with default configuration. Generates a random seed phrase automatically (not displayed) and downloads the official genesis file from the network repository.

**When to use:** First-time setup for a full node that won't act as a validator.

**Expected output:**
- Success message: `✅ Node initialized successfully!`
- Configuration location: `/home/ubuntu/.infinited/`
- Instructions to start the node

**What happens behind the scenes:**
1. Creates configuration files (`config.toml`, `app.toml`, `client.toml`)
2. Generates node keys and validator keys
3. Downloads official genesis file from GitHub
4. Sets chain ID based on service configuration

**Note:** If the node is already initialized, the command will show an error. To reinitialize, you must delete the data directory first.

#### Recovery Mode (For Validators)

```bash
cd drive/services/node0-infinite
docker compose exec infinite node-init --recover
# or
docker compose exec infinite node-init -r
```

**What it does:** Initializes the node using an existing seed phrase. Prompts you to enter your 12 or 24-word mnemonic phrase to recover your keys.

**When to use:** Setting up a validator node with existing keys, or restoring a node from a backup seed phrase.

**Expected output:**
- Prompt: `Enter your bip39 mnemonic`
- Enter your seed phrase (12 or 24 words)
- Success message after initialization completes

**Important:** You must have your seed phrase ready before running this command. The seed phrase is typically obtained from `node-keys create` or from a previous node setup.

## Key Management

> **📖 Complete Key Management Guide:** For comprehensive documentation on generating, backing up, and managing keys, see the [Key Management](key-management.md) guide.

### Using Graphical Interface (Easiest)

1. Open the interface: `docker compose exec infinite node-ui`
2. Navigate to **"Key Management"**
3. Choose from available options:
   - Generate Key (Dry-Run - Recommended)
   - Generate and Save Key
   - Add Existing Key from Seed Phrase
   - List All Keys
   - Show Key Details
   - Delete Key
   - Reset Keyring Password

The interface guides you through each operation with clear prompts and explanations.

### Using Command Line

The `node-keys` command provides tools for managing cryptographic keys for your node. Keys are essential for:
- Identifying your node on the blockchain network
- Signing transactions and blocks (if acting as a validator)
- Managing funds associated with the node's address

**Quick Reference:**

```bash
cd drive/services/node0-infinite

# Generate key without saving (recommended)
docker compose exec infinite node-keys create my-validator --dry-run

# Generate and save key directly
docker compose exec -it node0-infinite node-keys create my-validator

# Add existing key from seed phrase
docker compose exec -it node0-infinite node-keys add my-validator

# List all keys
docker compose exec infinite node-keys list

# Show key details
docker compose exec infinite node-keys show my-validator

# Delete key
docker compose exec infinite node-keys delete my-validator --yes
```

## Start Node

### Using Graphical Interface (Easiest)

1. Open the interface: `docker compose exec infinite node-ui`
2. Navigate to **"Node Operations"** → **"Start Node"**
3. The interface will show the startup process and confirm when the node is running

### Using Command Line

```bash
cd drive/services/node0-infinite
docker compose exec infinite node-start
```

**What it does:** Starts the blockchain node as a background daemon process. The node runs continuously until stopped manually.

**When to use:** After initializing the node, or whenever you need to start the node after it has been stopped.

**Expected output:**
- Shows configuration details: Chain ID, EVM Chain ID, Home directory, Log location
- Success message: `✅ Node started successfully (PID: 123)`
- Instructions for viewing logs and stopping the node

**What happens behind the scenes:**
1. Verifies the node is initialized (checks for `config.toml`)
2. Checks that no other instance is running
3. Starts the node process in background
4. Redirects all output to `/var/log/node/node.log`
5. Saves the process ID for tracking

**If node is already running:** The command will show a warning with the existing PID and exit without starting a duplicate instance.

## Stop Node

### Using Graphical Interface (Easiest)

1. Open the interface: `docker compose exec infinite node-ui`
2. Navigate to **"Node Operations"** → **"Stop Node"**
3. Confirm the operation

### Using Command Line

```bash
cd drive/services/node0-infinite
docker compose exec infinite node-stop
```

**What it does:** Gracefully stops the running node process. Sends a termination signal (SIGTERM) and waits for the process to shut down cleanly.

**When to use:** Before making configuration changes, updating the node, or when you need to stop the node temporarily.

**Expected output:**
- Header: `Stopping Infinite Drive Blockchain Node`
- Message: `Stopping node process (PID: 123)...`
- Success: `✅ Node stopped successfully`

**Graceful shutdown:** The node saves its state before stopping, ensuring data integrity. This is important for validators to avoid slashing.

## Check Status

### Using Graphical Interface (Easiest)

1. Open the interface: `docker compose exec infinite node-ui`
2. Navigate to **"Node Monitoring"** → **"Node Process Status"**

### Using Command Line

```bash
cd drive/services/node0-infinite
docker compose exec infinite node-process-status
```

**What it does:** Verifies if the node process is currently running and displays process information.

**Expected output:**
- **If running:** Shows PID, user, CPU time, and full command
- **If not running:** Shows error message with instructions to start the node

**When to use:** Quick verification that the node process is active, especially useful for troubleshooting or monitoring scripts.

**Note:** This checks the process status, not the blockchain sync status. Use `infinited status` to check sync status.

## View Logs

### Using Graphical Interface (Easiest)

1. Open the interface: `docker compose exec infinite node-ui`
2. Navigate to **"Node Monitoring"** → **"View Logs"** or **"Follow Logs"**

### Using Command Line

#### Last N Lines

```bash
cd drive/services/node0-infinite

# Last 50 lines (default)
docker compose exec infinite node-logs

# Last N lines (specify number)
docker compose exec infinite node-logs 100
docker compose exec infinite node-logs 200
```

**What it does:** Displays the last N lines from the node log file (`/var/log/node/node.log`).

**Expected output:** Recent log entries showing:
- Node startup messages
- Sync progress
- Block processing
- Errors or warnings
- Connection status

#### Follow Logs in Real-Time

```bash
cd drive/services/node0-infinite
docker compose exec infinite node-logs -f
# or
docker compose exec infinite node-logs --follow
```

**What it does:** Streams log entries in real-time as they're written to the log file (similar to `tail -f`).

**Expected output:** Shows message `ℹ️  Following node logs (Ctrl+C to exit)...` followed by a continuous stream of log entries. Press `Ctrl+C` to stop.

**When to use:** Monitor node activity while it's running, watch sync progress, or debug issues as they happen.

## Interactive Graphical Interface

```bash
cd drive/services/node0-infinite
docker compose exec infinite node-ui
```

**What it does:** Launches an interactive graphical menu interface (TUI - Text User Interface) that provides easy access to all node operations through a menu-driven interface.

**Features:**
- **Main Menu** with organized categories:
  - Key Management
  - Node Operations
  - Node Monitoring
  - Help & Documentation

- **Submenus** for each category with specific operations
- **Interactive dialogs** for input and confirmation
- **Visual feedback** for all operations
- **Easy navigation** using arrow keys and Enter

**Expected output:** A graphical menu interface where you can:
- Navigate using arrow keys (↑↓)
- Select options with Enter
- Go back with Esc or Cancel
- See results of commands before returning to menu

**When to use:**
- **Recommended for beginners** - No need to remember commands
- When you prefer a graphical interface over command-line
- When you're learning the available commands
- When you want quick access to all operations in one place

**Example workflow:**
1. Launch interface: `docker compose exec infinite node-ui`
2. Navigate to "Key Management" → "Generate Key (Dry-Run)"
3. Follow prompts to create a key
4. Return to main menu and navigate to "Advanced Operations" → "Initialize with Recovery"
5. Complete initialization through the interface

## Get Help

### Using Graphical Interface

1. Open the interface: `docker compose exec infinite node-ui`
2. Navigate to **"Help & Documentation"**

### Using Command Line

```bash
cd drive/services/node0-infinite
docker compose exec infinite node-help
```

**What it does:** Displays a summary of all available node commands, their locations, and usage examples.

**Expected output:** Help menu showing:
- List of all available `node-*` commands
- Important file locations (config, data, logs)
- Useful `infinited` binary commands
- Example workflows for common tasks

## Common Workflows

### Daily Operations

**Using Graphical Interface (Easiest):**
1. Open interface: `docker compose exec infinite node-ui`
2. Use "Node Monitoring" to check status and view logs
3. Use "Node Operations" to start/stop/restart

**Using Command Line:**
```bash
cd drive/services/node0-infinite

# Check if node is running
docker compose exec infinite node-process-status

# View recent logs
docker compose exec infinite node-logs 50

# Restart node if needed
docker compose exec infinite node-stop
docker compose exec infinite node-start
```

### Validator Setup

**Using Graphical Interface (Easiest):**
1. Open interface: `docker compose exec infinite node-ui`
2. Navigate to "Key Management" → "Generate Key (Dry-Run - Recommended)"
3. Save the seed phrase displayed
4. Navigate to "Advanced Operations" → "Initialize with Recovery (Validator)"
5. Enter the seed phrase when prompted
6. Start the node from "Node Operations"

**Using Command Line:**
```bash
cd drive/services/node0-infinite

# 1. Generate key (dry-run recommended - back up seed phrase yourself)
docker compose exec infinite node-keys create validator-main --dry-run

# 2. Initialize with recovery (enter seed phrase when prompted)
docker compose exec -it node0-infinite node-init --recover

# 3. (Optional) Add key to keyring for validator operations
docker compose exec -it node0-infinite node-keys add validator-main

# 4. Start node
docker compose exec infinite node-start
```

## Working with Multiple Services

Each service in Drive is independent. You can run commands for different services:

```bash
# Mainnet node
cd drive/services/node0-infinite
./drive.sh up -d
docker compose exec infinite node-ui

# Testnet node (in another terminal)
cd drive/services/node1-infinite-testnet
./drive.sh up -d
docker compose exec infinite-testnet node-ui
```

**Note:** Use `./drive.sh` for container management (up, down, ps, etc.) to automatically handle permissions.

Each service maintains its own:
- Container name
- Persistent data directory
- Configuration
- Environment variables

## Tips

- **Start with the graphical interface** - It's the easiest way and guides you through everything
- **Use command line for automation** - Scripts and automation benefit from direct commands
- **Always navigate to service directory first** - Commands must be run from the service directory
- **Each service is independent** - You can run mainnet and testnet nodes simultaneously

