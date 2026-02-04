# Port Configuration: Relayer Hermes (IBC)

**Service Name:** `relayer-hermes`  
**Container Name:** `relayer-hermes`

Este servicio ejecuta Hermes (relayer IBC) y **no expone ningún puerto**. Solo realiza conexiones salientes hacia los endpoints RPC y gRPC de las cadenas configuradas.

---

## Puertos

| Port Type | Host Port | Container Port |
|-----------|-----------|----------------|
| N/A       | —         | —              |

**Nota:** No aplica la fórmula de asignación de puertos por número de servicio; el relayer no abre puertos de escucha.
