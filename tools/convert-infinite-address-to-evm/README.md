# Convert Infinite address to EVM format

Converts an **Infinite (Bech32)** account address (e.g. `infinite1...`) to **EVM (hex)** format (`0x...`). Useful when you need the same account in tools or contracts that expect an Ethereum-style address (MetaMask, dApps, JSON-RPC, etc.).

The same account has two representations on Infinite Drive:

- **Bech32**: `infinite1n6t7eruukpulejn473rd9trr6kj7e3ge5ucy5c` (Cosmos-style, used in CLI and gRPC)
- **EVM**: `0x9e97ec8f9cb079fcca75f446d2ac63d5a5ecc519` (20-byte hex, used in EVM RPC and wallets)

This tool only converts **Bech32 → EVM**. The reverse (EVM → Bech32) is deterministic if you use the Infinite prefix (`infinite`).

## Requirements

- **Python 3.6+**
- **bech32** package:

  ```bash
  pip install bech32
  ```

  Or with a virtualenv:

  ```bash
  pip install -r requirements.txt
  ```

## Usage

```bash
# Argument
python3 convert-infinite-address-to-evm.py "infinite1n6t7eruukpulejn473rd9trr6kj7e3ge5ucy5c"

# From stdin
echo "infinite1n6t7eruukpulejn473rd9trr6kj7e3ge5ucy5c" | python3 convert-infinite-address-to-evm.py
```

### Example output

```
0x9e97ec8f9cb079fcca75f446d2ac63d5a5ecc519
```

The script prints only the EVM address to stdout; errors go to stderr. Exit code `0` on success, `1` on invalid input or missing dependency.

## Notes

- Only **account** addresses (20 bytes after decoding) are supported. Validator and consensus addresses have different lengths and are not converted by this tool.
- The Bech32 human-readable prefix (HRP) can be any valid prefix; the decoded bytes are the same for the same account. This script does not validate the HRP (e.g. `infinite`); it only decodes Bech32 and outputs the 20-byte hex.

## Authorship and rights

**Copyright 2025, Deep Thought Labs.**

This tool is part of the **Infinite Drive** ecosystem (**Project 42**).

- **Infinite Drive**: [https://infinitedrive.xyz](https://infinitedrive.xyz) · [https://docs.infinitedrive.xyz](https://docs.infinitedrive.xyz)
- **Deep Thought Labs**: [https://deep-thought.computer](https://deep-thought.computer)
