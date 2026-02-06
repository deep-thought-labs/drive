# Relayer Hermes (IBC)

Drive service that runs [Hermes](https://hermes.informal.systems/) (IBC relayer) in an Ubuntu-based container. It does not expose any ports; it only makes outbound connections to the RPC/gRPC endpoints of the configured chains.

## Prerequisites

- Docker (and `docker compose` or `docker-compose`)
- Two Cosmos chains with accessible RPC and gRPC, and an account on each with funds for gas (for the relayer)

## Structure

- **`config.toml.example`** — Configuration template; copy to `persistent-data/config.toml` and edit (see below for what each field means).
- **`persistent-data/`** — Mounted as `~/.hermes` inside the container. It should contain:
  - **`config.toml`** — Chain configuration (RPC, gRPC, chain ID, prefixes, etc.).
  - **`keys/`** — Relayer keys per chain (Hermes creates these when you run `keys add`).

If `config.toml` is missing or empty, Hermes will fail to start.

---

## Step-by-step setup

Follow these steps in order. **Build and start the container first**; then edit the config on your machine and add keys from inside the container.

### Step 1 — Build the image and start the container

From the service directory (`drive/services/relayer-hermes`):

```bash
./drive.sh up -d --build
```

This creates the Docker image, the `persistent-data/` directory if it does not exist, and leaves the container running. From here you can edit files in `persistent-data/` on your machine (they are mounted inside the container) and use `./drive.sh exec ...` to run Hermes commands inside the container.

### Step 2 — Create and edit the configuration

On your machine (not inside the container):

```bash
cp config.toml.example persistent-data/config.toml
```

Edit `persistent-data/config.toml` with a text editor. You must fill in **each chain** with real data. What each field means and where to get the values is in the [Config fields](#config-fields) section below.

**Alternative:** If your chains are in the [Cosmos Chain Registry](https://github.com/cosmos/chain-registry), you can generate a base `config.toml` with  
`./drive.sh run --rm relayer-hermes config auto --output /root/.hermes/config.toml --chain <chain-id-1> <chain-id-2>`  
then copy the generated file from the container to `persistent-data/config.toml` (or adjust gas/keys as needed).

### Step 3 — Add relayer keys (one per chain)

Hermes needs a key (account) on each chain to sign transactions and pay gas. The `keys add` command **imports** a key from a **recovery phrase (mnemonic)** that **you already have** (from your wallet or an account you created).

- **What the "mnemonic file" is:** A text file **you create** containing your recovery phrase (12 or 24 words). It is not a file Hermes generates; it is the seed of the account the relayer will use.
- **Where to put it:** Since the container mounts `persistent-data` at `/root/.hermes`, create the file on your machine so the command can see it inside the container:

  1. Create a file, e.g. `persistent-data/mnemonic.txt`.
  2. Paste your recovery phrase into it (one line, words separated by spaces). Use an account that has funds for gas on that chain.
  3. Run the command with **the same `key_name`** as in `config.toml` for that chain (replace `<chain-id>` and `<key-name>` with the chain’s `id` and `key_name` from your config):

     ```bash
     ./drive.sh exec -it relayer-hermes hermes keys add \
       --chain <chain-id> \
       --key-name <key-name> \
       --mnemonic-file /root/.hermes/mnemonic.txt
     ```

     Example for a chain with `id = 'chain-a'` and `key_name = 'relayer-chain-a'` in `config.toml`:

     ```bash
     ./drive.sh exec -it relayer-hermes hermes keys add \
       --chain chain-a \
       --key-name relayer-chain-a \
       --mnemonic-file /root/.hermes/mnemonic.txt
     ```

  4. Repeat for the other chain (same or different mnemonic and key name, depending on whether you use the same account on both networks).
  5. For security, delete or clear `persistent-data/mnemonic.txt` when done (and do not commit it to git).

The `--key-name` value must match the `key_name` for that chain in `config.toml`.

**Matching the chain’s derivation path (HD path):** If you use the same mnemonic for an account that already has funds on the chain (e.g. you created it with the chain’s CLI), the address Hermes derives must match that account. Hermes and each chain’s CLI derive keys from the mnemonic using a **derivation path** (BIP44). If the path differs, you get a different address and the relayer will show no balance. Add the key with the same path the chain uses by passing `--hd-path "<path>"` to `hermes keys add`.

**Infinite (Drive):** The path used by `infinited keys add` comes from the Cosmos SDK config default for `--coin-type`. In the **current** codebase, `main()` was not calling `config.SetBip44CoinType(cfg)`, so the SDK default applied: **coin type 118**, path **`m/44'/118'/0'/0/0`**. So if you created the key on the Infinite node with that binary, use that path in Hermes:

```bash
# Path that matches keys created with infinited keys add (current behaviour)
--hd-path "m/44'/118'/0'/0/0"
```

A fix has been added so that `main()` calls `SetBip44CoinType(cfg)` (Ethereum-compatible path **`m/44'/60'/0'/0/0`**). After rebuilding the Infinite binary with that change, new keys will use `m/44'/60'/0'/0/0`; for those, use `--hd-path "m/44'/60'/0'/0/0"` in Hermes. **Use the path that matches how the key was created on the node** (118 vs 60 depending on binary version).

**Other chains (e.g. QOM):** Run the chain’s `keys add --help` and look for `--hd-path` or `--coin-type`; or check the chain’s source for `SetBip44CoinType`, `Bip44CoinType`, or `CreateHDPath` to see the default path.

Example with path for current Infinite behaviour:

```bash
./drive.sh exec -it relayer-hermes hermes keys add \
  --chain <chain-id> \
  --key-name <key-name> \
  --mnemonic-file /root/.hermes/mnemonic.txt \
  --hd-path "m/44'/118'/0'/0/0"
```

### Step 4 — Validate config and check connectivity

Without needing the relayer to be relaying yet, verify that the config is valid and the container can reach the nodes:

```bash
./drive.sh run --rm relayer-hermes config validate
./drive.sh run --rm relayer-hermes health-check
```

`run --rm` starts a temporary container, mounts your `persistent-data/`, and runs the command. If something fails, check URLs and chain IDs in `config.toml`.

### Step 5 — Create the IBC channel (once per chain pair)

Create client, connection, and transfer channel between the two chains (replace chain IDs with the `id` values from your `config.toml`):

```bash
./drive.sh run --rm relayer-hermes create channel \
  --a-chain <chain-id-a> --b-chain <chain-id-b> \
  --a-port transfer --b-port transfer --new-client-connection --channel-version ics20-1
```

### Step 6 — Keep the relayer running

If you already ran `./drive.sh up -d --build` in step 1, the container **is already running** and Hermes is already relaying (or attempting to). To view logs:

```bash
./drive.sh logs -f
```

If you stopped the service at some point (`./drive.sh down`), start it again with:

```bash
./drive.sh up -d
```

You do not need to rebuild unless you change the Dockerfile or Hermes version.

---

## Config fields

Each chain in `config.toml` has these fields. **Where to get the data:** the chain’s official documentation, or the [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) (each chain has a directory with `chain.json` and sometimes `assetlist.json`; these usually include `chain_id`, `bech32_prefix`, and sometimes API URLs).

| Field | Meaning | Where to get it |
|-------|---------|-----------------|
| **`id`** | **Official chain ID** of the network (e.g. `cosmoshub-4`, `osmosis-1`, `infinite_421018-1`). Not a local alias; it is the same identifier the chain uses. | Network documentation or Chain Registry (`chain.json` → `chain_id`). |
| **`rpc_addr`** | URL of the node’s RPC endpoint (typical port 26657). Must be reachable from the container (if the node is on your machine, in many setups you can use `http://host.docker.internal:26657`). | Whoever provides node access; or Chain Registry → `apis.rpc`. |
| **`grpc_addr`** | URL of the gRPC endpoint (typical port 9090). | Same: node documentation or Chain Registry → `apis.grpc`. |
| **`event_source`** | **Required.** How Hermes receives IBC events. Use `{ mode = 'push', url = 'ws://HOST:PORT/websocket', batch_delay = '500ms' }` (WebSocket; replace HOST:PORT with your RPC host and port, use `wss://` if TLS). Alternatively `{ mode = 'pull' }` to poll via RPC (e.g. for CosmWasm chains). | Derive from RPC: same host/port as `rpc_addr`, path `/websocket`; use `ws://` or `wss://`. |
| **`account_prefix`** | Bech32 prefix for addresses on **that** chain (e.g. `cosmos`, `osmo`, `infinite`). It is the prefix at the start of an address (e.g. `cosmos1...`, `osmo1...`). | Chain documentation or Chain Registry (`chain.json` → `bech32_prefix` or `address_prefix`). |
| **`key_name`** | **Local** name Hermes uses to identify the key on that chain. Must match the `--key-name` you pass to `hermes keys add` for that chain (see Step 3). | You choose it; use the same value in config and in `keys add --key-name`. |
| **`store_prefix`** | IBC module store prefix on the chain. On standard Cosmos SDK chains it is almost always **`ibc`**. Only differs on networks with different configuration. | Chain documentation; if not specified, use `ibc`. Sometimes in the chain’s description in the Chain Registry. |
| **`gas_price`** | **Required.** Fee for relay transactions: `{ price = 0.001, denom = 'stake' }`. Use the chain’s **native denom** (e.g. `uatom`, `uosmo`, `stake`) and a price that meets the chain’s minimum (check chain docs or `min_gas_price` in app.toml). | Chain documentation or Chain Registry; denom is usually the base unit of the native token. |

**Summary:** `id` = real chain ID; `account_prefix` = address prefix (cosmos, osmo, infinite…); `store_prefix` = usually `ibc`; `gas_price` = native denom + price. Get RPC and gRPC from the node or chain registry.

---

## Useful commands once running

```bash
# View relayer logs (container already running)
./drive.sh logs -f

# One-off commands (starts a temporary container; service does not need to be up)
./drive.sh run --rm relayer-hermes health check
./drive.sh run --rm relayer-hermes keys list --chain <chain-id>
./drive.sh run --rm relayer-hermes query channels --chain <chain-id>

# Interactive command inside the running container (requires up -d)
./drive.sh exec -it relayer-hermes hermes <command> ...
```

Stop the service: `./drive.sh down`. Start it again: `./drive.sh up -d`.

---

## What this service does and does not do

- **It does:** Connect two or more Cosmos chains via IBC: watch events on both, create/update light clients, connections and channels, and relay packets (e.g. ICS-20 token transfers). It only makes outbound connections to the RPC/gRPC you configure; it does not listen on any ports.
- **It does not:** Expose an API or ports; it is not a blockchain node. Chains must already have the IBC transfer module (ICS-20) and accessible RPC/gRPC endpoints. You must provide accounts with gas funds on each chain and create the path (client + connection + channel) once with `create channel`.

**Troubleshooting:** If `health check` fails, ensure `rpc_addr` and `grpc_addr` in `config.toml` are reachable from the container (same Docker network or public IPs). If the relay does not deliver packets, check the relayer account balances and that the channel exists on both chains (`hermes query channels --chain <chain-id>`).

**Apple Silicon (M1/M2/M3):** The image is multi-arch; when building on a Mac with Apple silicon, the Hermes binary for Linux arm64 (aarch64) is used, with no emulation.

---

## Configuration

- **Dockerfile:** Ubuntu 22.04 image with the **official** Hermes binary from [GitHub Releases](https://github.com/informalsystems/hermes/releases) (no compilation), for the build architecture (amd64 or arm64). The only pre-built image on Docker Hub (`informaldev/hermes`) is outdated (unmaintained for years), so we use the official binary. Version is controlled by the `HERMES_VERSION` build-arg in `docker-compose.yml` (default **1.8.2**). We use 1.8.2 when one chain has **IBC-Go 6.1.x** (e.g. QOM) and the other has **SDK 0.54** (e.g. Infinite Testnet): Hermes 1.8.2 marks QOM as healthy and Infinite as “not healthy” (compatibility warning), but Hermes still starts and can relay. Hermes 1.13.x requires IBC-Go ≥6.3.1, so QOM (6.1.0) would fail its check, and SDK 0.54 is not in 1.13’s supported range (<0.54); there is no single Hermes version that officially satisfies both chains. If both your chains use IBC-Go ≥6.3.1 and SDK ≤0.53.x, you can set `HERMES_VERSION: "1.13.3"` in `docker-compose.yml` and rebuild.
- **Ports:** This service does not map or expose any ports; the relayer only makes outbound connections to the configured chains’ RPC/gRPC.

## Related documentation

- [Hermes — Configuration](https://hermes.informal.systems/documentation/configuration/configure-hermes.html)
