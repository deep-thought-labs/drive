# Relayer Hermes (IBC)

Servicio Drive que ejecuta [Hermes](https://hermes.informal.systems/) (relayer IBC) en un contenedor basado en Ubuntu. No expone puertos; solo realiza conexiones salientes a los RPC/gRPC de las cadenas configuradas.

## Requisitos previos

- Docker (y `docker compose` o `docker-compose`)
- Dos cadenas Cosmos con RPC y gRPC accesibles, y una cuenta en cada una con fondos para gas (para el relayer)

## Estructura

- **`config.toml.example`** — Plantilla de configuración; copiar a `persistent-data/config.toml` y editar (ver más abajo qué significa cada campo).
- **`persistent-data/`** — Se monta como `~/.hermes` dentro del contenedor. Aquí van:
  - **`config.toml`** — Configuración de cadenas (RPC, gRPC, chain ID, prefijos, etc.).
  - **`keys/`** — Claves del relayer por cadena (Hermes las crea al ejecutar `keys add`).

Si `config.toml` no existe o está vacío, Hermes fallará al arrancar.

---

## Orden de pasos para echarlo andar

Sigue los pasos en este orden. **Primero se construye y se levanta el contenedor**; luego se edita la config en tu máquina y se añaden las claves desde dentro del contenedor.

### Paso 1 — Construir la imagen y levantar el contenedor

Desde la carpeta del servicio (`drive/services/relayer-hermes`):

```bash
./drive.sh up -d --build
```

Esto crea la imagen Docker, el directorio `persistent-data/` si no existe, y deja el contenedor corriendo. A partir de aquí puedes editar archivos en `persistent-data/` en tu máquina (se montan dentro del contenedor) y usar `./drive.sh exec ...` para ejecutar comandos Hermes dentro del contenedor.

### Paso 2 — Crear y editar la configuración

En tu máquina (no dentro del contenedor):

```bash
cp config.toml.example persistent-data/config.toml
```

Edita `persistent-data/config.toml` con un editor de texto. Debes rellenar **cada cadena** con los datos reales. Qué significa cada campo y de dónde sacarlos está en la sección [Campos de `config.toml`](#campos-de-configtoml) más abajo.

**Alternativa:** Si tus cadenas están en el [Cosmos Chain Registry](https://github.com/cosmos/chain-registry), puedes generar un `config.toml` base con  
`./drive.sh run --rm relayer-hermes config auto --output /root/.hermes/config.toml --chain <chain-id-1> <chain-id-2>`  
y luego copiar el archivo generado desde el contenedor a `persistent-data/config.toml` (o ajustar gas/keys según necesites).

### Paso 3 — Añadir las claves del relayer (una por cadena)

Hermes necesita una clave (cuenta) en cada cadena para firmar transacciones y pagar gas. El comando `keys add` **importa** una clave a partir de una **frase de recuperación (mnemonic)** que **tú ya tienes** (de tu wallet o de una cuenta que creaste).

- **Qué es el “mnemonic file”:** un archivo de texto que **tú creas** y en el que pegas tu frase de recuperación (las 12 o 24 palabras). No es un archivo que genere Hermes; es la semilla de la cuenta que usará el relayer.
- **Dónde ponerlo:** como el contenedor monta `persistent-data` en `/root/.hermes`, crea el archivo en tu máquina para que el comando lo vea dentro del contenedor:

  1. Crea un archivo, por ejemplo `persistent-data/mnemonic.txt`.
  2. Pega en él tu frase de recuperación (una línea, las palabras separadas por espacios). Usa una cuenta que tenga fondos para gas en esa cadena.
  3. Ejecuta (sustituye `<chain-id>` por el `id` de esa cadena tal como está en `config.toml`):

     ```bash
     ./drive.sh exec -it relayer-hermes hermes keys add --chain <chain-id> --mnemonic-file /root/.hermes/mnemonic.txt
     ```

  4. Repite para la otra cadena (misma o otra mnemonic, según si usas la misma cuenta en ambas redes o no).
  5. Por seguridad, borra o vacía `persistent-data/mnemonic.txt` cuando termines (y no lo subas a git).

El `key_name` que elijas al añadir (o el que viene por defecto) debe coincidir con el `key_name` que pusiste en `config.toml` para esa cadena.

### Paso 4 — Validar la config y comprobar conectividad

Sin necesidad de tener el relayer “relayeando” aún, comprueba que la config sea válida y que el contenedor llegue a los nodos:

```bash
./drive.sh run --rm relayer-hermes config validate
./drive.sh run --rm relayer-hermes health check
```

`run --rm` lanza un contenedor temporal, monta tu `persistent-data/` y ejecuta el comando. Si algo falla, revisa URLs y chain IDs en `config.toml`.

### Paso 5 — Crear el canal IBC (solo una vez por par de cadenas)

Crea cliente, conexión y canal de transfer entre las dos cadenas (sustituye los chain IDs por los `id` de tu `config.toml`):

```bash
./drive.sh run --rm relayer-hermes create channel \
  --a-chain <chain-id-a> --b-chain <chain-id-b> \
  --a-port transfer --b-port transfer --new-client-connection --channel-version ics20-1
```

### Paso 6 — Dejar el relayer en marcha

Si en el paso 1 ya hiciste `./drive.sh up -d --build`, el contenedor **ya está corriendo** y Hermes ya está relayando (o intentándolo). Para ver los logs:

```bash
./drive.sh logs -f
```

Si en algún momento paraste el servicio (`./drive.sh down`), vuelve a levantarlo con:

```bash
./drive.sh up -d
```

No hace falta volver a construir salvo que cambies el Dockerfile o la versión de Hermes.

---

## Campos de `config.toml`

Cada cadena en `config.toml` tiene estos campos. **De dónde sacar los datos:** la documentación oficial de la cadena, o el [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) (cada cadena tiene un directorio con `chain.json` y a veces `assetlist.json`; ahí suelen venir `chain_id`, `bech32_prefix`, y a veces APIs).

| Campo | Significado | Dónde obtenerlo |
|-------|-------------|-----------------|
| **`id`** | **Chain ID oficial** de la red (ej. `cosmoshub-4`, `osmosis-1`, `infinite_421018-1`). No es un alias local; es el mismo identificador que usa la propia cadena. | Documentación de la red o Chain Registry (`chain.json` → `chain_id`). |
| **`rpc_addr`** | URL del endpoint RPC del nodo (puerto típico 26657). Debe ser alcanzable desde el contenedor (si el nodo está en tu máquina, en muchos entornos puedes usar `http://host.docker.internal:26657`). | Quien te dé acceso al nodo; o Chain Registry → `apis.rpc`. |
| **`grpc_addr`** | URL del endpoint gRPC (puerto típico 9090). | Igual: documentación del nodo o Chain Registry → `apis.grpc`. |
| **`account_prefix`** | Prefijo bech32 de las direcciones en **esa** cadena (ej. `cosmos`, `osmo`, `infinite`). Es el prefijo que ves al inicio de una dirección (ej. `cosmos1...`, `osmo1...`). | Documentación de la cadena o Chain Registry (`chain.json` → `bech32_prefix` o `address_prefix`). |
| **`key_name`** | Nombre **local** que Hermes usa para identificar la clave en esa cadena. Puede ser cualquiera (ej. `relayer-a`); debe ser el mismo que uses al hacer `hermes keys add` para esa cadena. | Lo eliges tú. |
| **`store_prefix`** | Prefijo del store del módulo IBC en la cadena. En cadenas Cosmos SDK estándar es casi siempre **`ibc`**. Solo cambia en redes con configuración distinta. | Documentación de la cadena; si no aparece, usar `ibc`. En el Chain Registry a veces viene en la descripción de la cadena. |

**Resumen:** `id` = chain ID real; `account_prefix` = prefijo de las direcciones (cosmos, osmo, infinite…); `store_prefix` = casi siempre `ibc`. RPC y gRPC los obtienes del nodo o del chain registry.

---

## Comandos útiles una vez en marcha

```bash
# Ver logs del relayer (contenedor ya en marcha)
./drive.sh logs -f

# Comandos puntuales (lanza un contenedor temporal; no hace falta que el servicio esté up)
./drive.sh run --rm relayer-hermes health check
./drive.sh run --rm relayer-hermes keys list --chain <chain-id>
./drive.sh run --rm relayer-hermes query channels --chain <chain-id>

# Comando interactivo dentro del contenedor en marcha (requiere que hayas hecho up -d)
./drive.sh exec -it relayer-hermes hermes <comando> ...
```

Parar el servicio: `./drive.sh down`. Volver a levantarlo: `./drive.sh up -d`.

---

## Qué hace y qué no hace este servicio

- **Sí hace:** Conecta dos o más cadenas Cosmos vía IBC: observa eventos en ambas, crea/actualiza clientes ligeros, conexiones y canales, y relayea paquetes (p. ej. transfer de tokens ICS-20). Solo realiza conexiones salientes a los RPC/gRPC que configures; no abre puertos de escucha.
- **No hace:** No expone API ni puertos; no es un nodo blockchain. Las cadenas deben tener ya módulo IBC transfer (ICS-20) y endpoints RPC/gRPC accesibles. Tú debes proveer cuentas con fondos para gas en cada cadena y crear una vez el path (cliente + conexión + canal) con `create channel`.

**Troubleshooting:** Si `health check` falla, revisa que `rpc_addr` y `grpc_addr` en `config.toml` sean alcanzables desde el contenedor (misma red Docker o IPs públicas). Si el relay no entrega paquetes, comprueba saldos de las cuentas del relayer y que el canal exista en ambas cadenas (`hermes query channels --chain <chain-id>`).

**Apple Silicon (M1/M2/M3):** La imagen es multi-arquitectura; al construir en Mac con chip Apple se usa el binario Hermes para Linux arm64 (aarch64), sin emulación.

---

## Configuración

- **Dockerfile:** Imagen Ubuntu 22.04 con el **binario oficial** de Hermes descargado desde [GitHub Releases](https://github.com/informalsystems/hermes/releases) (sin compilar), para la arquitectura de construcción (amd64 o arm64). La única imagen preconstruida en Docker Hub (`informaldev/hermes`) está desactualizada (años sin actualizar), por eso usamos el binario oficial. La versión se controla con el build-arg `HERMES_VERSION` en `docker-compose.yml` (por defecto `1.13.3`).
- **Puertos:** Este servicio no mapea ni expone puertos; el relayer solo hace conexiones salientes a los RPC/gRPC de las cadenas configuradas.

## Documentación relacionada

- [Hermes — Configuration](https://hermes.informal.systems/documentation/configuration/configure-hermes.html)
