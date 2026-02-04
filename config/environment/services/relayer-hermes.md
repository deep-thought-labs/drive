# Environment Variables: Relayer Hermes (IBC)

**Service Name:** `relayer-hermes`

This service does not use any required environment variables. Configuration is done via:

- **`persistent-data/config.toml`** — chains, RPC, gRPC, key names, etc.
- **`persistent-data/keys/`** — relayer keys per chain (added with `hermes keys add`).

You can optionally override the config path by passing arguments to Hermes (e.g. `--config /path/config.toml` via `command` in `docker-compose.yml`).
