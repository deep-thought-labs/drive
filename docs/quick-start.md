# Quick Start

Get your Infinite Drive blockchain node up and running in minutes using the easiest method first, then explore advanced options.

## Prerequisites

- Docker (20.10+)
- Docker Compose (1.29+)

**Important Note on Permissions:**
- On Linux, you may need to add your user to the `docker` group to run Docker commands without `sudo`
- The `drive.sh` script works with or without `sudo`, but Docker itself may require `sudo` if not configured
- See the Docker installation instructions below for how to configure this

### Installing Docker

<details>
<summary><strong>macOS</strong> - Click to expand installation instructions</summary>

**Installation with Docker Desktop:**

1. Download Docker Desktop for Mac from [docker.com](https://www.docker.com/products/docker-desktop/)
2. Open the downloaded `.dmg` file
3. Drag Docker to the Applications folder
4. Open Docker from Applications
5. Complete the initial setup

**Verification:**
```bash
docker --version
docker compose version
```

</details>

<details>
<summary><strong>Linux</strong> - Click to expand installation instructions</summary>

**Installation with official script:**

```bash
# Update packages
sudo apt-get update

# Install dependencies
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine and Docker Compose
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# IMPORTANT: Add your user to the docker group to avoid using sudo with Docker
# This step is REQUIRED if you want to run Docker commands without sudo
sudo usermod -aG docker $USER
```

**⚠️ IMPORTANT:** After adding your user to the docker group, you **MUST** log out and log back in (or restart your terminal session) for the changes to take effect.

**Without this step:** You will need to use `sudo` with all Docker commands (including `./drive.sh`). The `drive.sh` script supports both cases (with or without sudo), but Docker itself requires sudo if your user is not in the docker group.

**Verification:**
```bash
docker --version
docker compose version
```

</details>

<details>
<summary><strong>Windows</strong> - Click to expand installation instructions</summary>

**Installation with Docker Desktop:**

1. Download Docker Desktop for Windows from [docker.com](https://www.docker.com/products/docker-desktop/)
2. Run the downloaded `.exe` installer
3. Accept the terms and conditions
4. Complete the installation (may require restart)
5. Open Docker Desktop from the start menu

**Requirements:**
- Windows 10 64-bit: Pro, Enterprise, or Education (Build 19041 or higher)
- Windows 11 64-bit
- WSL 2 enabled (Docker Desktop will configure it automatically if available)

**Verification:**
```bash
docker --version
docker compose version
```

</details>

## Step 1: Navigate to Your Service

Drive organizes services in separate directories. Each service is independent and can run simultaneously.

```bash
# Navigate to the Infinite Mainnet service
cd drive/services/infinite-mainnet
```

**Available Services:**
- `infinite-mainnet/` - Mainnet blockchain node
- `infinite-testnet/` - Testnet blockchain node (when available)

## Step 2: Start the Container

Start the Docker container for your service using the `drive.sh` script (recommended):

```bash
./drive.sh up -d
```

**Why use `./drive.sh`?** It automatically configures correct user permissions, preventing volume permission errors. Works with or without `sudo`.

**What happens:**
- Docker pulls the pre-built image from Docker Hub (first time only, ~2-3 minutes)
- Container starts in the background
- Service is ready for initialization

**Verify container is running:**
```bash
./drive.sh ps
```

You should see the container status as "Up".

**Alternative:** If you prefer to use `docker compose` directly, you may need to configure permissions manually. See [Container Management](container-management.md#fixing-permission-issues) for details.

## Step 3: Choose Your Node Type (IMPORTANT - Read First!)

**⚠️ CRITICAL DECISION BEFORE INITIALIZATION:**

Before initializing your node, you need to decide what type of node you're setting up:

### 🔴 Validator Node (Requires Seed Phrase)

**If you plan to run a validator node**, you **MUST** create a cryptographic key first and save the seed phrase. This is **REQUIRED** and cannot be skipped.

**Why?** Validator nodes need a recoverable seed phrase to:
- Sign blocks and transactions
- Recover your validator keys if needed
- Maintain control over your validator identity

**⚠️ BEFORE INITIALIZATION - Create Your Key:**

1. **Create a new key** and **save the seed phrase** (see [Key Management Guide](key-management.md) for complete instructions)
2. **Back up the seed phrase securely** (paper, metal, encrypted storage - your choice)
3. **Use that seed phrase** during initialization with recovery mode

**📖 Complete Guide:** See the [Key Management Guide](key-management.md) for detailed instructions on creating and backing up keys.

### ✅ Simple Node (No Validator)

**If you're running a full node (not a validator)**, you can proceed directly with simple initialization. No key creation needed - the system will generate random keys automatically.

**Safe to proceed:** Simple initialization is perfect for full nodes that won't act as validators.

---

## Step 4: Use the Graphical Interface (Recommended - Easiest Method)

The **easiest and recommended way** to manage your node is through the built-in graphical interface. This method requires no command memorization and guides you through every step.

### Open the Graphical Interface

```bash
# Make sure container is running first
./drive.sh up -d

# Open the graphical interface
./drive.sh exec infinite-mainnet node-ui
```

**Note:** Use `./drive.sh` for all commands - both container management (up, down, ps, etc.) and commands inside the container (exec).

### What You'll See

The graphical interface provides:
- **Visual menus** - Navigate with arrow keys and Enter
- **Self-descriptive options** - Each option explains what it does
- **Interactive wizards** - Step-by-step guidance for all operations
- **Real-time information** - Status, logs, and monitoring in one place

### First-Time Setup Through the Interface

#### For Validator Nodes (Requires Seed Phrase)

**⚠️ IMPORTANT:** Complete these steps in order:

1. **Ensure container is running:** `./drive.sh up -d`
2. **Open the interface:** `./drive.sh exec infinite-mainnet node-ui`
3. **Navigate to "Key Management"** → **"Generate Key (Dry-Run - Recommended)"**
4. **Create your key:**
   - Enter a name for your key (e.g., `my-validator`)
   - The system will display your **seed phrase** (12 or 24 words)
   - **⚠️ CRITICAL:** Write down and securely back up this seed phrase immediately
   - This seed phrase is the **ONLY** way to recover your validator keys
5. **Navigate to "Advanced Operations"** → **"Initialize with Recovery (Validator)"**
6. **Enter your seed phrase** when prompted (the one you just created and backed up)
7. **Enter a moniker** (node name) when requested
8. **After initialization, select "Start Node"** from Node Operations
9. **Use "Node Monitoring"** to check status and view logs

**📖 Need Help?** See the [Key Management Guide](key-management.md) for complete key creation and backup procedures.

#### For Simple Nodes (No Validator)

1. **Ensure container is running:** `./drive.sh up -d`
2. **Open the interface:** `./drive.sh exec infinite-mainnet node-ui`
3. **Navigate to "Advanced Operations"** → **"Initialize Node (Simple)"**
3. **Follow the interactive prompts:**
   - Enter a moniker (node name) when requested
   - Confirm any warnings about random keys (these are safe for non-validator nodes)
4. **After initialization, select "Start Node"** from Node Operations
5. **Use "Node Monitoring"** to check status and view logs

**That's it!** The interface handles everything else. You can perform all operations through the menus without remembering any commands.

### Common Operations in the Interface

- **Key Management** - Create, list, show, or delete keys (see [Key Management Guide](key-management.md))
- **Node Operations** - Start, stop, restart the node
- **Node Monitoring** - View logs, check status, network diagnosis
- **System Information** - Container and node details

## Step 5: Advanced - Command Line Interface (Optional)

If you prefer command-line operations or need to automate tasks, you can use direct commands. This method is for advanced users who are comfortable with terminal commands.

### Initialize Node (First Time Only)

#### 🔴 Validator Node (Requires Seed Phrase - READ THIS FIRST!)

**⚠️ CRITICAL:** If you're setting up a validator node, you **MUST** create a key first and save the seed phrase before initialization.

**Step-by-step workflow:**

1. **Start the container (if not running):**
   ```bash
   cd drive/services/infinite-mainnet
   ./drive.sh up -d
   ```

2. **Create your key (REQUIRED FIRST STEP):**
   ```bash
   ./drive.sh exec infinite-mainnet node-keys create my-validator --dry-run
   ```
   
   **What happens:**
   - The system generates a cryptographic key
   - **Displays your seed phrase (12 or 24 words)**
   - **⚠️ CRITICAL:** Write down and securely back up this seed phrase immediately
   - The key is NOT saved to the keyring (that's why it's called "dry-run")
   
   **📖 Complete Guide:** See the [Key Management Guide](key-management.md) for detailed instructions on creating, backing up, and managing keys.

3. **Back up your seed phrase securely:**
   - Write it on paper and store it safely
   - Or use a metal backup solution
   - Or store it in encrypted storage
   - **This is the ONLY way to recover your validator keys**

4. **Initialize with recovery (use your seed phrase):**
   ```bash
   ./drive.sh exec -it infinite-mainnet node-init --recover
   ```
   
   **What happens:**
   - Prompts you to enter your seed phrase (the one you just created and backed up)
   - Prompts you to enter a moniker (node name)
   - Initializes the node with your validator keys
   
5. **(Optional) Add key to keyring for later use:**
   ```bash
   ./drive.sh exec -it infinite-mainnet node-keys add my-validator
   ```
   Enter your seed phrase when prompted to add it to the keyring.

**Why use dry-run first?** This approach gives you complete control:
- You generate the key and back it up yourself
- You verify your backup before committing
- You maintain full ownership of your keys
- You can choose when/if to add the key to the keyring

#### ✅ Simple Node (No Validator)

**If you're NOT running a validator**, you can proceed directly with simple initialization:

```bash
cd drive/services/infinite-mainnet
# Start the container first (if not running)
./drive.sh up -d
# Initialize the node
./drive.sh exec infinite-mainnet node-init
```

**What it does:** Creates a new node with default configuration. Generates random keys automatically (not displayed). Suitable for full nodes that won't act as validators.

**Safe to proceed:** No key creation needed - the system handles everything automatically.

### Start the Node

```bash
# Ensure container is running
./drive.sh up -d
# Start the node
./drive.sh exec infinite-mainnet node-start
```

### Verify Status

```bash
# Check node process status
./drive.sh exec infinite-mainnet node-process-status
```

## Working with Multiple Services

You can run multiple services simultaneously. Each service is completely independent:

```bash
# Terminal 1: Mainnet node
cd drive/services/infinite-mainnet
./drive.sh up -d
./drive.sh exec infinite-mainnet node-ui

# Terminal 2: Testnet node (when available)
cd drive/services/infinite-testnet
./drive.sh up -d
./drive.sh exec infinite-testnet node-ui
```

Each service has:
- Its own container name
- Its own persistent data directory
- Its own network configuration
- Its own environment variables

## Next Steps

- **[Node Operations](node-operations.md)** - Complete guide to all available commands
- **[Container Management](container-management.md)** - Container management with `drive.sh`
- **[Configuration](configuration.md)** - Customize your service
- **[Monitoring](monitoring.md)** - Monitor your node health
- **[Troubleshooting](troubleshooting.md)** - Solve common issues

## Quick Reference

### Using the Graphical Interface (Easiest)

```bash
cd drive/services/infinite-mainnet
./drive.sh up -d
./drive.sh exec infinite-mainnet node-ui
```

**Note:** Use `./drive.sh` for all commands - both container management (up, down, ps, etc.) and commands inside the container (exec).

### Using Command Line (Advanced)

```bash
cd drive/services/infinite-mainnet
./drive.sh up -d
./drive.sh exec infinite-mainnet node-init
./drive.sh exec infinite-mainnet node-start
./drive.sh exec infinite-mainnet node-process-status
```

**Note:** Use `./drive.sh` for all commands to automatically handle permissions and ensure consistency.

## Tips

- **Start with the graphical interface** - It's the easiest way and guides you through everything
- **Use command line for automation** - Scripts and automation benefit from direct commands
- **Each service is independent** - You can run mainnet and testnet nodes simultaneously
- **Data persists** - Your blockchain data is stored in `persistent-data/` directory

