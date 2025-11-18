# Quick Start

Get your Infinite Drive blockchain node up and running in minutes using the easiest method first, then explore advanced options.

## Prerequisites

- **Git** - For cloning the repository
- **Docker** (20.10+) - For running containers
- **Docker Compose** (1.29+) - For managing multi-container applications

**Important Note on Permissions:**
- On Linux, you may need to add your user to the `docker` group to run Docker commands without `sudo`
- The `drive.sh` script works with or without `sudo`, but Docker itself may require `sudo` if not configured
- See the installation instructions below for how to configure this

### Installing Git

<details>
<summary><strong>macOS</strong> - Click to expand Git installation</summary>

**Git Installation:**

Git is usually pre-installed on macOS. To check if it's installed:

```bash
git --version
```

**If Git is not installed:**

1. **Using Homebrew (Recommended):**
   ```bash
   # Install Homebrew if you don't have it:
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Install Git:
   brew install git
   ```

2. **Using Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```

**Verification:**
```bash
git --version
```

</details>

<details>
<summary><strong>Linux</strong> - Click to expand Git installation</summary>

**Git Installation:**

Git is usually pre-installed on most Linux distributions. To check if it's installed:

```bash
git --version
```

**If Git is not installed:**

```bash
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install git

# CentOS/RHEL/Fedora:
sudo yum install git
# Or on newer versions:
sudo dnf install git
```

**Verification:**
```bash
git --version
```

</details>

<details>
<summary><strong>Windows</strong> - Click to expand Git installation</summary>

**Git Installation:**

1. **Download Git for Windows:**
   - Visit [git-scm.com/download/win](https://git-scm.com/download/win)
   - Download the installer
   - Run the installer and follow the setup wizard
   - Accept the default options (recommended)

2. **Or install via package manager:**
   ```powershell
   # Using Chocolatey (if installed):
   choco install git
   
   # Using winget (Windows 10/11):
   winget install Git.Git
   ```

**Verification:**
```powershell
git --version
```

**Note:** After installation, you may need to restart your terminal or PowerShell window.

</details>

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

**Understanding macOS Firewall Options:**

macOS provides two ways to configure the firewall. **You can use either method** - they configure the same firewall system:

- **GUI Method (System Settings/Preferences)**: Easy, visual interface. **Recommended for most users.**
- **Command Line (pfctl)**: Advanced, scriptable configuration. **For advanced users or automation.**

**Note:** If you're configuring macOS firewall remotely via SSH, ensure SSH access is allowed before making changes that might affect your connection.

**Which method should you use?**
- **Use GUI** if you prefer a visual interface and are configuring manually
- **Use Command Line** if you need to script the configuration or prefer terminal-based tools

---

### Option 1: Using macOS Firewall GUI (Recommended)

**What is this?**
The macOS built-in firewall GUI provides an easy-to-use interface for managing firewall rules through System Settings (or System Preferences on older macOS versions). This is the simplest method for most users.

**Configuring via GUI:**

1. Open **System Settings** (or **System Preferences** on older macOS)
2. Go to **Network** → **Firewall** (or **Security & Privacy** → **Firewall**)
3. Click the lock icon and enter your password
4. Click **Firewall Options...**
5. Click **+** to add a new rule
6. Select your application or add a port rule:
   - For **Docker Desktop**: Allow incoming connections
   - Or add a port rule: Allow TCP port `26656` (and `26657` if needed)
7. Click **OK** to save

---

### Option 2: Using Command Line (pfctl) - Advanced

**What is pfctl?**
pfctl (Packet Filter Control) is the command-line interface to macOS's packet filter firewall. It provides direct control over firewall rules and is useful for scripting or advanced configurations.

**⚠️ Important:** pfctl configuration can be complex and may interfere with the GUI settings. Use this method only if you're comfortable with command-line tools and understand macOS firewall architecture.

**Configuring via Command Line:**

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

**Understanding Linux Firewall Tools:**

Linux systems use different firewall management tools. **You only need ONE of these tools** - they are alternatives to each other, not meant to be used together. Each tool manages the same underlying firewall (iptables/netfilter), but provides different interfaces:

- **UFW (Uncomplicated Firewall)**: Simple, user-friendly firewall tool. **Most common on Ubuntu/Debian systems.**
- **firewalld (Firewall Daemon)**: Dynamic firewall manager with zones. **Most common on CentOS/RHEL/Fedora systems.**
- **iptables**: Low-level, direct firewall configuration. **Advanced users only.** Usually pre-installed on all Linux systems.

**Which tool should you use?**
- Use the tool that's **already installed** on your system (most systems come with one pre-installed)
- If you're not sure, check which one is installed using the commands below
- **Do NOT install multiple tools** - they can conflict with each other

**Step 1: Identify Which Firewall Tool You Have**

Run these commands to check which firewall tool is installed on your system:

```bash
# Check for UFW
which ufw
systemctl is-active ufw 2>/dev/null || echo "UFW not active"

# Check for firewalld
which firewall-cmd
systemctl is-active firewalld 2>/dev/null || echo "firewalld not active"

# Check for iptables (usually always present)
which iptables
```

**Based on the results:**
- If `ufw` is found → Use **UFW** (go to UFW section below)
- If `firewall-cmd` is found → Use **firewalld** (go to firewalld section below)
- If only `iptables` is found → Use **iptables** (go to iptables section below)
- If none are active → Install UFW (recommended for beginners) or firewalld

---

### Option 1: Using UFW (Recommended for Ubuntu/Debian)

**What is UFW?**
UFW (Uncomplicated Firewall) is a simple, user-friendly interface for managing iptables. It's the default firewall tool on Ubuntu and most Debian-based systems. It's designed to be easy to use while still being powerful enough for most use cases.

**Installing UFW (if not already installed):**

UFW is usually pre-installed on Ubuntu/Debian systems. If it's not installed:

```bash
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install ufw
```

**Configuring UFW:**

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

---

### Option 2: Using firewalld (Recommended for CentOS/RHEL/Fedora)

**What is firewalld?**
firewalld (Firewall Daemon) is a dynamic firewall manager that uses zones and services to manage firewall rules. It's the default firewall tool on CentOS, RHEL, and Fedora systems. It provides more advanced features like runtime configuration changes without losing connections.

**Installing firewalld (if not already installed):**

firewalld is usually pre-installed on CentOS/RHEL/Fedora systems. If it's not installed:

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

**Configuring firewalld:**

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

---

### Option 3: Using iptables (Advanced Users Only)

**What is iptables?**
iptables is the low-level, direct interface to the Linux kernel's netfilter firewall. It provides the most control but requires more technical knowledge. Most systems have iptables installed, but it's usually managed through UFW or firewalld. Only use iptables directly if:
- You're an advanced user
- You need fine-grained control
- UFW or firewalld are not available or not suitable for your needs

**⚠️ Important:** If you're using UFW or firewalld, **do NOT** configure iptables directly - they will conflict. Disable UFW/firewalld first if you want to use iptables directly.

**Installing iptables-persistent (for saving rules):**

iptables is usually pre-installed on Linux systems, but you may need to install `iptables-persistent` to save rules permanently:

```bash
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install iptables-persistent

# During installation, you'll be asked if you want to save current rules
# Answer "Yes" to both IPv4 and IPv6 rules
```

**Configuring iptables:**

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

**Understanding Windows Firewall Options:**

Windows provides two ways to configure the firewall. **You can use either method** - they configure the same Windows Firewall system:

- **GUI Method (Windows Defender Firewall)**: Easy, visual interface. **Recommended for most users.**
- **PowerShell (Command Line)**: Fast, scriptable configuration. **For advanced users or automation.**

**Note:** If you're configuring Windows Firewall remotely via RDP or SSH, ensure your remote access port (RDP: 3389, SSH: 22) is allowed before making changes. Windows Firewall typically doesn't block existing connections, but it's good practice to verify.

**Which method should you use?**
- **Use GUI** if you prefer a visual interface and are configuring manually
- **Use PowerShell** if you need to script the configuration, prefer command-line tools, or want to configure multiple ports quickly

---

### Option 1: Using Windows Firewall GUI (Recommended)

**What is this?**
Windows Defender Firewall provides a graphical interface for managing firewall rules through the Windows Control Panel. This is the simplest method for most users and provides a clear visual representation of your firewall rules.

**Configuring via GUI:**

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

---

### Option 2: Using PowerShell (Command Line) - Advanced

**What is PowerShell NetFirewallRule?**
PowerShell's `New-NetFirewallRule` cmdlet provides a command-line interface to Windows Firewall. It's faster for configuring multiple ports and can be scripted for automation.

**Configuring via PowerShell:**

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

---

## Verifying Port Access (Optional)

**What are verification tools?**

After configuring your firewall, you may want to verify that the ports are actually accessible. These are **optional** tools that help you test if your firewall configuration is working correctly:

- **telnet**: A network protocol and command-line tool used to test connectivity to a specific port. It's simple but may not be installed by default on all systems.
- **netcat (nc)**: A versatile networking utility that can read and write data across network connections. It's more powerful than telnet and often pre-installed on Linux systems.

**When to use these tools:**
- To verify that your firewall rules are working correctly
- To test if ports are accessible from other machines on your network
- To troubleshoot connection issues

**Note:** These tools are **optional** - your node will work fine without them. They're only useful for verification and troubleshooting.

---

<details>
<summary><strong>macOS - Installing Verification Tools</strong></summary>

**Installing telnet:**

telnet is not included by default on newer macOS versions. To install it:

```bash
# Install via Homebrew (if you have Homebrew installed)
brew install telnet

# If you don't have Homebrew, install it first:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Installing netcat (nc):**

netcat is usually pre-installed on macOS. To check if it's available:

```bash
# Check if netcat is installed
which nc

# If not installed, install via Homebrew:
brew install netcat
```

**Verifying Port Access on macOS:**

```bash
# Test from another machine on your network
# Replace YOUR_IP with your machine's IP address

# Using telnet:
telnet YOUR_IP 26656

# Or using netcat:
nc -zv YOUR_IP 26656

# To test from the same machine (localhost):
nc -zv localhost 26656
```

</details>

<details>
<summary><strong>Linux - Installing Verification Tools</strong></summary>

**Installing telnet:**

telnet may not be installed by default on all Linux distributions:

```bash
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install telnet

# CentOS/RHEL/Fedora:
sudo yum install telnet
# Or on newer versions:
sudo dnf install telnet
```

**Installing netcat (nc):**

netcat is often pre-installed on Linux systems, but if not:

```bash
# Ubuntu/Debian:
sudo apt-get update
sudo apt-get install netcat

# CentOS/RHEL/Fedora:
sudo yum install nc
# Or on newer versions:
sudo dnf install nc
```

**Verifying Port Access on Linux:**

```bash
# Test from another machine on your network
# Replace YOUR_IP with your machine's IP address

# Using telnet:
telnet YOUR_IP 26656

# Or using netcat (recommended):
nc -zv YOUR_IP 26656

# To test from the same machine (localhost):
nc -zv localhost 26656
```

</details>

<details>
<summary><strong>Windows - Installing Verification Tools</strong></summary>

**Installing telnet:**

telnet is not enabled by default on Windows, but it can be enabled:

```powershell
# Run PowerShell as Administrator

# Enable telnet client (Windows 10/11)
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient

# Or using Command Prompt as Administrator:
# dism /online /Enable-Feature /FeatureName:TelnetClient
```

**Alternative: Using Test-NetConnection (Built-in PowerShell)**

Windows includes a built-in PowerShell cmdlet that doesn't require installation:

```powershell
# Test if a port is open (from PowerShell)
Test-NetConnection -ComputerName YOUR_IP -Port 26656

# Test localhost:
Test-NetConnection -ComputerName localhost -Port 26656
```

**Installing netcat (nc):**

netcat is not included with Windows by default. You can:

1. **Use Test-NetConnection instead** (recommended - no installation needed)
2. **Download netcat for Windows** from a trusted source (not recommended unless necessary)

**Verifying Port Access on Windows:**

```powershell
# Using Test-NetConnection (recommended - no installation needed)
Test-NetConnection -ComputerName YOUR_IP -Port 26656

# Using telnet (if enabled):
telnet YOUR_IP 26656
```

</details>

**Important Notes:**
- These tools are **optional** - they're only for verification
- If you're behind a router/NAT, you may also need to configure port forwarding on your router
- Testing from the same machine (localhost) only verifies the firewall allows local connections
- Testing from another machine verifies external access is working

## Step 1: Clone the Repository

First, clone the Drive repository to your local machine:

```bash
# Clone the repository
git clone https://github.com/deep-thought-labs/drive.git

# Navigate into the repository
cd drive
```

**What is this repository?**
The Drive repository contains all the service configurations, documentation, and scripts needed to run Infinite Drive nodes. Each service (mainnet, testnet, etc.) is organized in separate directories.

**Verification:**
After cloning, you should see a `drive/` directory with subdirectories like `services/`, `docs/`, etc.

## Step 2: Navigate to Your Service

Drive organizes services in separate directories. Each service is independent and can run simultaneously.

**Choose which service you want to run:**

- **Mainnet** - Production blockchain network (recommended for most users)
- **Testnet** - Testing network (for development and testing)

**Navigate to your chosen service:**

```bash
# For Mainnet (production network):
cd services/infinite-mainnet

# OR for Testnet (testing network):
cd services/infinite-testnet
```

**Available Services:**
- `infinite-mainnet/` - Mainnet blockchain node (production network)
- `infinite-testnet/` - Testnet blockchain node (testing network)

**Note:** You can run multiple services simultaneously by opening separate terminal windows and navigating to different service directories.

## Step 3: Start the Container

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

## Step 4: Important Note Before Initialization

**⚠️ For Validator Nodes Only:**

If you're setting up a **validator node**, you must add keys to your keyring BEFORE initializing:

- **Create a new key** and add it to the keyring (if starting fresh)
- **Add an existing key** from seed phrase (if you already have keys)

See [Key Management](node-operations.md#key-management) for instructions.

**For Simple Nodes (Full Node, No Validator):**

You can proceed directly to initialization - no key setup needed.

---

## Step 5: Use the Graphical Interface (Recommended)

The easiest way to manage your node is through the built-in graphical interface.

### Open the Interface

```bash
# Ensure container is running
./drive.sh up -d

# Open the graphical interface
./drive.sh exec infinite-mainnet node-ui
```

### First-Time Setup

**⚠️ Reminder:** If you're setting up a validator node, add your keys to the keyring first:

1. Navigate to **"Key Management"**
   - **Create new key:** Choose **"Generate and Save Key"** (if starting fresh)
   - **Add existing key:** Choose **"Add Existing Key from Seed Phrase"** (if you already have keys)
2. Navigate to **"Advanced Operations"** → **"Initialize Node"**
   - For validators: Choose **"Initialize with Recovery (Validator)"** and select your key
   - For simple nodes: Choose **"Initialize Node (Simple)"**
3. Enter a moniker (node name) when prompted
4. After initialization, select **"Start Node"** from Node Operations
5. Use **"Node Monitoring"** to check status and view logs

The interface provides visual menus for all operations. See [Node Operations](node-operations.md) for complete documentation.

## Step 6: Command Line Interface (Advanced)

For command-line operations, use these commands:

### Add Keys to Keyring (Validators Only)

**⚠️ Reminder:** If you're setting up a validator node, add your keys to the keyring first:

```bash
# Create a new key and add to keyring (if starting fresh):
./drive.sh exec -it infinite-mainnet node-keys create my-validator

# Add an existing key from seed phrase (if you already have keys):
./drive.sh exec -it infinite-mainnet node-keys add my-validator
```

### Initialize Node

```bash
# For validator nodes (requires key in keyring):
./drive.sh exec -it infinite-mainnet node-init --recover

# For simple nodes:
./drive.sh exec infinite-mainnet node-init
```

### Start the Node

```bash
./drive.sh exec infinite-mainnet node-start
```

### Check Status

```bash
./drive.sh exec infinite-mainnet node-process-status
```

**Complete command reference:** See [Node Operations](node-operations.md) for all available commands.

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

