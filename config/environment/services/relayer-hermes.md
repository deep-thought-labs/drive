# Environment Variables: Relayer Hermes (IBC)

**Service Name:** `relayer-hermes`

Este servicio no utiliza variables de entorno obligatorias. La configuración se hace mediante:

- **`persistent-data/config.toml`** — cadenas, RPC, gRPC, key names, etc.
- **`persistent-data/keys/`** — claves del relayer por cadena (añadidas con `hermes keys add`).

Opcionalmente se puede sobrescribir la ruta del config pasando argumentos a Hermes (p. ej. `--config /ruta/config.toml` vía `command` en `docker-compose.yml`).
