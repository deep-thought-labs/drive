# Node Operations

Complete guide to managing your Infinite Drive blockchain node. This guide covers both the **graphical interface (recommended for beginners)** and **command-line operations (for advanced users)**.

## Quick Access: Graphical Interface (Recommended)

The **easiest way** to manage your node is through the built-in graphical interface. This method requires no command memorization and guides you through every operation.

### Open the Graphical Interface

```bash
# Navigate to your service directory
cd drive/services/infinite-mainnet

# Start the container (if not running) - use drive.sh for automatic permission handling
./drive.sh up -d

# Open the graphical interface
./drive.sh exec infinite-mainnet node-ui
```

**Note:** Use `./drive.sh` for all commands - both container management (up, down, ps, etc.) and commands inside the container (exec). This automatically handles permissions.

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
cd drive/services/infinite-mainnet
./drive.sh exec infinite-mainnet <command>
```

## Initialize Node

### Using Graphical Interface (Easiest)

1. Open the interface: `./drive.sh exec infinite-mainnet node-ui`
2. Navigate to **"Node Operations"** → **"Advanced Operations"**
3. Choose:
   - **"Initialize Node (Simple)"** - For full nodes (no validator keys needed)
   - **"Initialize with Recovery (Validator)"** - **Required for validator nodes** (requires seed phrase)
4. Follow the interactive prompts:
   - Enter a moniker (node name) when requested
   - If using recovery mode (required for validator nodes), enter your seed phrase
   - Confirm any warnings about random keys (if using simple mode)

### Using Command Line

#### Simple Initialization

```bash
cd drive/services/infinite-mainnet
./drive.sh exec infinite-mainnet node-init
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

#### Recovery Mode (Required for Validator Nodes)

```bash
cd drive/services/infinite-mainnet
./drive.sh exec -it infinite-mainnet node-init --recover
# or
./drive.sh exec -it infinite-mainnet node-init -r
```

**What it does:** Initializes the node using an existing seed phrase. Prompts you to enter your 12 or 24-word mnemonic phrase to recover your keys.

**When to use:** **Required for validator nodes** - you must use recovery mode to initialize a validator node with your seed phrase. Also used for restoring a node from a backup seed phrase.

**Expected output:**
- Prompt: `Enter your bip39 mnemonic`
- Enter your seed phrase (12 or 24 words)
- Success message after initialization completes

**Important:** You must have your seed phrase ready before running this command. The seed phrase is typically obtained from `node-keys create` or from a previous node setup.

## Key Management

This section covers all aspects of key management for your Infinite Drive node, including creating keys, backing up seed phrases, and managing your keyring.

**⚠️ IMPORTANT - Read Before Proceeding:**

If you're setting up a **validator node**, you **MUST** add keys to your keyring **BEFORE** initializing the node. The seed phrase (12 or 24 words) you generate or add will be used to:
- Initialize your node in recovery mode (required for validator nodes)
- Create and operate your validator
- Sign blocks and transactions

**Both options (Generate and Save Key, or Add Existing Key) will save the key to your keyring** - the system needs the key stored to use it during initialization and validator operations.

### Using Graphical Interface (Easiest)

**Step-by-Step Guide:**

1. **Open the interface:**
   ```bash
   ./drive.sh exec infinite-mainnet node-ui
   ```

2. **Navigate to "Key Management"** from the main menu

3. **Choose the appropriate option based on your situation:**
   
   **Option A: Generate and Save Key** (if starting fresh)
   - Use this if you don't have a key yet
   - The system will generate a new cryptographic key
   - **⚠️ CRITICAL:** The system will display your **seed phrase (12 or 24 words)**
   - **You MUST save this seed phrase immediately and securely**
   - The key will be saved to your keyring automatically
   
   **Option B: Add Existing Key from Seed Phrase** (if you already have keys)
   - Use this if you already have a seed phrase from a previous setup
   - You'll be prompted to enter your existing seed phrase
   - The key will be added to your keyring
   
   **Option C: Generate Key (Dry-Run)** (for reference only)
   - This option generates a key and shows the seed phrase **without saving it to the keyring**
   - Use this only if you want to see what a seed phrase looks like, or if you prefer to manage keys externally
   - **Note:** If you use this option, you'll need to manually add the key later using "Add Existing Key from Seed Phrase"
   - **Not recommended** for most users - use "Generate and Save Key" instead

4. **After adding your key:**
   - You can verify it was saved by selecting "List All Keys"
   - Proceed to initialize your node using the recovery mode option (required for validator nodes)

**⚠️ CRITICAL SECURITY REMINDER - Seed Phrase Backup:**

Your seed phrase is the **ONLY** way to recover your validator keys and access your validator. Follow these security practices:

- **✅ DO:**
  - Write it down on paper and store it in a secure physical location (safe, safety deposit box, etc.)
  - Use a metal backup solution for long-term durability
  - Store it in encrypted digital storage if you must keep a digital copy
  - Make multiple secure backups in different locations
  - Verify your backup is correct before proceeding

- **❌ DON'T:**
  - Store it in plain text on digital devices (computers, phones, cloud storage without encryption)
  - Share it with anyone - not even support staff or "helpers"
  - Take screenshots or photos of it
  - Store it in email or messaging apps
  - Write it in easily accessible locations

**Remember:** You will need this seed phrase when:
- Initializing your node in recovery mode (required for validator nodes)
- Creating your validator
- Recovering your validator if you lose access
- Signing transactions and blocks

### Other Key Management Operations

The interface also provides these options for managing your keys:

- **List All Keys** - View all keys currently in your keyring
- **Show Key Details** - Display detailed information about a specific key
- **Delete Key** - Remove a key from your keyring (use with caution)
- **Reset Keyring Password** - Change the password that protects your keyring

The interface guides you through each operation with clear prompts and explanations.

### Using Command Line

The `node-keys` command provides tools for managing cryptographic keys for your node. Keys are essential for:
- Identifying your node on the blockchain network
- Signing transactions and blocks (if acting as a validator)
- Managing funds associated with the node's address

**Quick Reference:**

```bash
cd drive/services/infinite-mainnet

# Create and save key directly
./drive.sh exec -it infinite-mainnet node-keys create my-validator

# Add existing key from seed phrase
./drive.sh exec -it infinite-mainnet node-keys add my-validator

# List all keys
./drive.sh exec infinite-mainnet node-keys list

# Show key details
./drive.sh exec infinite-mainnet node-keys show my-validator

# Delete key
./drive.sh exec infinite-mainnet node-keys delete my-validator --yes
```

## Start Node

### Using Graphical Interface (Easiest)

1. Open the interface: `./drive.sh exec infinite-mainnet node-ui`
2. Navigate to **"Node Operations"** → **"Start Node"**
3. The interface will show the startup process and confirm when the node is running

### Using Command Line

```bash
cd drive/services/infinite-mainnet
./drive.sh exec infinite-mainnet node-start
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

1. Open the interface: `./drive.sh exec infinite-mainnet node-ui`
2. Navigate to **"Node Operations"** → **"Stop Node"**
3. Confirm the operation

### Using Command Line

```bash
cd drive/services/infinite-mainnet
./drive.sh exec infinite-mainnet node-stop
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

1. Open the interface: `./drive.sh exec infinite-mainnet node-ui`
2. Navigate to **"Node Monitoring"** → **"Node Process Status"**

### Using Command Line

```bash
cd drive/services/infinite-mainnet
./drive.sh exec infinite-mainnet node-process-status
```

**What it does:** Verifies if the node process is currently running and displays process information.

**Expected output:**
- **If running:** Shows PID, user, CPU time, and full command
- **If not running:** Shows error message with instructions to start the node

**When to use:** Quick verification that the node process is active, especially useful for troubleshooting or monitoring scripts.

**Note:** This checks the process status, not the blockchain sync status. Use `infinited status` to check sync status.

## View Logs

### Using Graphical Interface (Easiest)

1. Open the interface: `./drive.sh exec infinite-mainnet node-ui`
2. Navigate to **"Node Monitoring"** → **"View Logs"** or **"Follow Logs"**

### Using Command Line

#### Last N Lines

```bash
cd drive/services/infinite-mainnet

# Last 50 lines (default)
./drive.sh exec infinite-mainnet node-logs

# Last N lines (specify number)
./drive.sh exec infinite-mainnet node-logs 100
./drive.sh exec infinite-mainnet node-logs 200
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
cd drive/services/infinite-mainnet
./drive.sh exec infinite-mainnet node-logs -f
# or
./drive.sh exec infinite-mainnet node-logs --follow
```

**What it does:** Streams log entries in real-time as they're written to the log file (similar to `tail -f`).

**Expected output:** Shows message `ℹ️  Following node logs (Ctrl+C to exit)...` followed by a continuous stream of log entries. Press `Ctrl+C` to stop.

**When to use:** Monitor node activity while it's running, watch sync progress, or debug issues as they happen.

## Interactive Graphical Interface

```bash
cd drive/services/infinite-mainnet
./drive.sh exec infinite-mainnet node-ui
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
1. Launch interface: `./drive.sh exec infinite-mainnet node-ui`
2. Navigate to "Key Management" → "Generate and Save Key" or "Add Existing Key from Seed Phrase"
3. Follow prompts to create a key
4. Return to main menu and navigate to "Advanced Operations" → "Initialize with Recovery"
5. Complete initialization through the interface

## Get Help

### Using Graphical Interface

1. Open the interface: `./drive.sh exec infinite-mainnet node-ui`
2. Navigate to **"Help & Documentation"**

### Using Command Line

```bash
cd drive/services/infinite-mainnet
./drive.sh exec infinite-mainnet node-help
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
1. Open interface: `./drive.sh exec infinite-mainnet node-ui`
2. Use "Node Monitoring" to check status and view logs
3. Use "Node Operations" to start/stop/restart

**Using Command Line:**
```bash
cd drive/services/infinite-mainnet

# Check if node is running
./drive.sh exec infinite-mainnet node-process-status

# View recent logs
./drive.sh exec infinite-mainnet node-logs 50

# Restart node if needed
./drive.sh exec infinite-mainnet node-stop
./drive.sh exec infinite-mainnet node-start
```

### Validator Setup

**Using Graphical Interface (Easiest):**
1. Open interface: `./drive.sh exec infinite-mainnet node-ui`
2. Navigate to "Key Management" → "Generate and Save Key" (or "Add Existing Key from Seed Phrase" if you already have keys)
3. Save the seed phrase displayed
4. Navigate to "Advanced Operations" → "Initialize with Recovery (Validator)"
5. Enter the seed phrase when prompted
6. Start the node from "Node Operations"

**Using Command Line:**
```bash
cd drive/services/infinite-mainnet

# 1. Create key and add to keyring (if starting fresh)
./drive.sh exec -it infinite-mainnet node-keys create validator-main

# OR add existing key from seed phrase (if you already have keys)
./drive.sh exec -it infinite-mainnet node-keys add validator-main

# 2. Initialize with recovery (enter seed phrase when prompted)
./drive.sh exec -it infinite-mainnet node-init --recover

# 3. Start node
./drive.sh exec infinite-mainnet node-start
```

## Working with Multiple Services

Each service in Drive is independent. You can run commands for different services:

```bash
# Mainnet node
cd drive/services/infinite-mainnet
./drive.sh up -d
./drive.sh exec infinite-mainnet node-ui

# Testnet node (in another terminal)
cd drive/services/infinite-testnet
./drive.sh up -d
./drive.sh exec infinite-testnet node-ui
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

