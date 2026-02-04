# Relayer Hermes (IBC)

Servicio Drive que ejecuta [Hermes](https://hermes.informal.systems/) (relayer IBC) en un contenedor basado en Ubuntu. No expone puertos; solo realiza conexiones salientes a los RPC/gRPC de las cadenas configuradas.

## Requisitos previos

- Docker (y `docker compose` o `docker-compose`)
- Archivo de configuración de Hermes y, opcionalmente, claves en `persistent-data/`

## Estructura

- **`persistent-data/`** — Se monta como `~/.hermes` dentro del contenedor. Aquí debes tener:
  - **`config.toml`** — Configuración de cadenas y paths (RPC, gRPC, chain IDs, etc.).
  - **`keys/`** — Claves del relayer por cadena (añadidas con `hermes keys add` o copiadas aquí).

Si `config.toml` no existe o está vacío, Hermes fallará al arrancar con un error claro.

## Uso

```bash
# Desde la raíz del repo drive
cd drive/services/relayer-hermes

# 1. Añadir config y keys en persistent-data/ (config.toml y, si aplica, keys)
# 2. Construir y levantar
./drive.sh up -d --build

# Ver logs
./drive.sh logs -f

# Parar
./drive.sh down
```

### Comandos Hermes dentro del contenedor

```bash
# Ejecutar un comando en el contenedor (ej. health check, listar keys)
./drive.sh run --rm relayer-hermes health check
./drive.sh run --rm relayer-hermes keys list --chain <chain-id>
```

Para comandos interactivos (p. ej. `hermes keys add` con mnemonic), usa `exec` con `-it`:

```bash
./drive.sh exec -it relayer-hermes hermes keys add --chain <chain-id> --mnemonic-file /root/.hermes/mnemonic.txt
```

## Configuración

- **Dockerfile:** Imagen Ubuntu 22.04 con el **binario oficial** de Hermes descargado desde [GitHub Releases](https://github.com/informalsystems/hermes/releases) (sin compilar). La única imagen preconstruida en Docker Hub (`informaldev/hermes`) está desactualizada (años sin actualizar), por eso usamos el binario oficial. La versión se controla con el build-arg `HERMES_VERSION` en `docker-compose.yml` (por defecto `1.13.3`).
- **Puertos:** Este servicio no mapea ni expone puertos. Ver [PLANEACION_SERVICIO_IBC_RELAYER.md](../../docs/PLANEACION_SERVICIO_IBC_RELAYER.md).

## Documentación relacionada

- [Planeación del servicio IBC Relayer en Drive](../../docs/PLANEACION_SERVICIO_IBC_RELAYER.md)
- [Planeación del puente IBC entre cadenas Cosmos](../../../docs/PLANEACION_PUENTE_IBC_COSMOS.md) (configuración de Hermes y paths)
- [Hermes — Configuration](https://hermes.informal.systems/documentation/configuration/configure-hermes.html)
