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

### Configuring Firewall Ports

**⚠️ CRITICAL WARNING - SSH PORT MUST BE OPEN FIRST:**

**If you are configuring the firewall remotely via SSH, you MUST enable the SSH port (usually port 22) BEFORE applying any firewall rules. Otherwise, you will lose your SSH connection and may be locked out of your server.**

**Always enable SSH first, then configure other ports.**

**Important:** For your node to participate in the blockchain network, you need to open the P2P port (and optionally the RPC port) in your system's firewall. This allows other nodes to connect to your node.

**Required Ports:**
- **SSH Port** (CRITICAL if accessing remotely): Required for remote access
  - Default SSH port: `22` (or your custom SSH port)
  - **⚠️ MUST be enabled FIRST if configuring firewall remotely**
- **P2P Port** (required): Used for peer-to-peer network communication
  - Mainnet: `26656`
  - Testnet: `26666`
  - See [Port Allocation Strategy](PORT_ALLOCATION.md) for all service ports
- **RPC Port** (optional): Used for API access (only needed if you want external RPC access)
  - Mainnet: `26657`
  - Testnet: `26667`

<details>
<summary><strong>macOS</strong> - Click to expand firewall configuration</summary>

**Note:** If you're configuring macOS firewall remotely via SSH, ensure SSH access is allowed before making changes that might affect your connection.

**Using macOS Firewall (System Preferences):**

1. Open **System Settings** (or **System Preferences** on older macOS)
2. Go to **Network** → **Firewall** (or **Security & Privacy** → **Firewall**)
3. Click the lock icon and enter your password
4. Click **Firewall Options...**
5. Click **+** to add a new rule
6. Select your application or add a port rule:
   - For **Docker Desktop**: Allow incoming connections
   - Or add a port rule: Allow TCP port `26656` (and `26657` if needed)
7. Click **OK** to save

**Using Command Line (pfctl):**

```bash
# Check current firewall status
sudo pfctl -s info

# Allow P2P port (mainnet)
sudo pfctl -a com.apple/250.ApplicationFirewall -t com.apple/250.ApplicationFirewall -T add 26656

# Allow RPC port (optional, mainnet)
sudo pfctl -a com.apple/250.ApplicationFirewall -t com.apple/250.ApplicationFirewall -T add 26657
```

**Note:** macOS firewall configuration can be complex. If you're running Docker Desktop, it may handle port forwarding automatically. For production nodes, consider using a dedicated firewall management tool.

</details>

<details>
<summary><strong>Linux</strong> - Click to expand firewall configuration</summary>

Linux firewall configuration depends on which firewall service you're using. Choose the method that matches your system:

**Installing UFW (if not already installed):**

UFW is usually pre-installed on Ubuntu/Debian systems. To check if it's installed:

```bash
# Check if UFW is installed
which ufw

# If not installed, install it:
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install ufw
```

**Using UFW (Ubuntu/Debian - Most Common):**

```bash
# Check UFW status
sudo ufw status

# ⚠️ CRITICAL: Allow SSH port FIRST (if accessing remotely)
# This prevents losing your SSH connection when enabling the firewall
sudo ufw allow 22/tcp
# Or if you use a custom SSH port, replace 22 with your port:
# sudo ufw allow YOUR_SSH_PORT/tcp

# Allow P2P port (mainnet)
sudo ufw allow 26656/tcp

# Allow RPC port (optional, mainnet)
sudo ufw allow 26657/tcp

# For testnet, use different ports:
sudo ufw allow 26666/tcp  # Testnet P2P
sudo ufw allow 26667/tcp  # Testnet RPC

# Enable UFW if not already enabled
sudo ufw enable

# Verify the rules were added
sudo ufw status numbered
```

**Installing firewalld (if not already installed):**

firewalld is usually pre-installed on CentOS/RHEL/Fedora systems. To check if it's installed:

```bash
# Check if firewalld is installed
which firewall-cmd

# If not installed, install it:
# CentOS/RHEL:
sudo yum install firewalld
# Or on newer versions:
sudo dnf install firewalld

# Fedora:
sudo dnf install firewalld

# Start and enable firewalld service
sudo systemctl start firewalld
sudo systemctl enable firewalld
```

**Using firewalld (CentOS/RHEL/Fedora):**

```bash
# Check firewalld status
sudo firewall-cmd --state

# ⚠️ CRITICAL: Allow SSH service FIRST (if accessing remotely)
# This prevents losing your SSH connection when enabling the firewall
sudo firewall-cmd --permanent --add-service=ssh
# Or if you use a custom SSH port:
# sudo firewall-cmd --permanent --add-port=YOUR_SSH_PORT/tcp

# Allow P2P port (mainnet)
sudo firewall-cmd --permanent --add-port=26656/tcp

# Allow RPC port (optional, mainnet)
sudo firewall-cmd --permanent --add-port=26657/tcp

# For testnet:
sudo firewall-cmd --permanent --add-port=26666/tcp  # Testnet P2P
sudo firewall-cmd --permanent --add-port=26667/tcp  # Testnet RPC

# Reload firewall to apply changes
sudo firewall-cmd --reload

# Verify the rules
sudo firewall-cmd --list-ports
```

**Installing iptables-persistent (for saving rules):**

iptables is usually pre-installed on Linux systems, but you may need to install `iptables-persistent` to save rules permanently:

```bash
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install iptables-persistent

# During installation, you'll be asked if you want to save current rules
# Answer "Yes" to both IPv4 and IPv6 rules
```

**Using iptables (Advanced/Manual Configuration):**

```bash
# ⚠️ CRITICAL: Allow SSH port FIRST (if accessing remotely)
# This prevents losing your SSH connection when applying firewall rules
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
# Or if you use a custom SSH port, replace 22 with your port:
# sudo iptables -A INPUT -p tcp --dport YOUR_SSH_PORT -j ACCEPT

# Allow P2P port (mainnet)
sudo iptables -A INPUT -p tcp --dport 26656 -j ACCEPT

# Allow RPC port (optional, mainnet)
sudo iptables -A INPUT -p tcp --dport 26657 -j ACCEPT

# For testnet:
sudo iptables -A INPUT -p tcp --dport 26666 -j ACCEPT  # Testnet P2P
sudo iptables -A INPUT -p tcp --dport 26667 -j ACCEPT  # Testnet RPC

# Save rules (method depends on your distribution)
# Ubuntu/Debian (if iptables-persistent is installed):
sudo netfilter-persistent save

# Or manually save to file:
sudo iptables-save > /etc/iptables/rules.v4
```

**Important Notes:**
- If you're running multiple services (mainnet + testnet), open all required ports
- The P2P port is **required** for your node to participate in the network
- The RPC port is **optional** unless you need external API access
- See [Port Allocation Strategy](PORT_ALLOCATION.md) for complete port information

</details>

<details>
<summary><strong>Windows</strong> - Click to expand firewall configuration</summary>

**Note:** If you're configuring Windows Firewall remotely via RDP or SSH, ensure your remote access port (RDP: 3389, SSH: 22) is allowed before making changes. Windows Firewall typically doesn't block existing connections, but it's good practice to verify.

**Using Windows Firewall (GUI):**

1. Open **Windows Defender Firewall** (search for "Firewall" in Start menu)
2. Click **Advanced settings** on the left
3. Click **Inbound Rules** → **New Rule...**
4. Select **Port** → **Next**
5. Select **TCP** and enter the port number:
   - For mainnet P2P: `26656`
   - For mainnet RPC (optional): `26657`
   - For testnet P2P: `26666`
   - For testnet RPC (optional): `26667`
6. Select **Allow the connection** → **Next**
7. Check all profiles (Domain, Private, Public) → **Next**
8. Give it a name (e.g., "Infinite Drive Mainnet P2P") → **Finish**
9. Repeat for each port you need

**Using PowerShell (Command Line):**

```powershell
# Run PowerShell as Administrator

# Allow P2P port (mainnet)
New-NetFirewallRule -DisplayName "Infinite Drive Mainnet P2P" -Direction Inbound -Protocol TCP -LocalPort 26656 -Action Allow

# Allow RPC port (optional, mainnet)
New-NetFirewallRule -DisplayName "Infinite Drive Mainnet RPC" -Direction Inbound -Protocol TCP -LocalPort 26657 -Action Allow

# For testnet:
New-NetFirewallRule -DisplayName "Infinite Drive Testnet P2P" -Direction Inbound -Protocol TCP -LocalPort 26666 -Action Allow
New-NetFirewallRule -DisplayName "Infinite Drive Testnet RPC" -Direction Inbound -Protocol TCP -LocalPort 26667 -Action Allow

# Verify rules were created
Get-NetFirewallRule -DisplayName "Infinite Drive*"
```

**Note:** Docker Desktop on Windows may handle some port forwarding automatically, but you still need to configure Windows Firewall for external access.

</details>

**Installing Verification Tools:**

To verify that ports are accessible, you may need to install network testing tools:

**Installing telnet:**
```bash
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install telnet

# CentOS/RHEL/Fedora:
sudo yum install telnet
# Or on newer versions:
sudo dnf install telnet

# macOS:
# telnet is not included by default on newer macOS versions
# Install via Homebrew:
brew install telnet
```

**Installing netcat (nc):**
```bash
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install netcat

# CentOS/RHEL/Fedora:
sudo yum install nc
# Or on newer versions:
sudo dnf install nc

# macOS:
# netcat is usually pre-installed, but if not:
brew install netcat
```

**Verifying Port Access:**

After configuring your firewall, you can verify that the ports are accessible:

```bash
# From another machine on your network, test if the port is open
# Replace YOUR_IP with your machine's IP address

# Using telnet:
telnet YOUR_IP 26656

# Or using netcat (if available):
nc -zv YOUR_IP 26656

# To test from the same machine (localhost):
nc -zv localhost 26656
```

**Important:** If you're behind a router/NAT, you may also need to configure port forwarding on your router. Consult your router's documentation for port forwarding setup.

## Step 1: Navigate to Your Service

Drive organizes services in separate directories. Each service is independent and can run simultaneously.

```bash
# Navigate to the Infinite Mainnet service
cd drive/services/infinite-mainnet
```

**Available Services:**
- `infinite-mainnet/` - Mainnet blockchain node
- `infinite-testnet/` - Testnet blockchain node

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

# Terminal 2: Testnet node
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

