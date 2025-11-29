# Port Configuration: Nginx Web Server

**Service Number:** 4  
**Service Name:** `nginx`  
**Container Name:** `nginx`  
**Service Type:** Web Server / Reverse Proxy

⚠️ **IMPORTANT:** This service is an **exception** to the standard port allocation strategy. As the primary web/proxy server, it uses standard HTTP/HTTPS ports (80, 443) and does NOT follow the `+10 offset` rule.

---

## Quick Reference

**Service Number:** 4  
**Port Offset:** **N/A** (uses standard ports, exception to offset rule)

| Port Type | Host Port | Container Port | Description |
|-----------|-----------|----------------|-------------|
| HTTP | 80 | 80 | Standard HTTP port |
| HTTPS | 443 | 443 | Standard HTTPS port (SSL/TLS) |

---

## Port Calculation

This service uses **standard web ports** and does NOT apply the port offset formula:

- **HTTP**: Port **80** (standard HTTP port, no offset applied)
- **HTTPS**: Port **443** (standard HTTPS port, no offset applied)

**Why standard ports?**
- This is the primary web server and reverse proxy
- Standard ports (80, 443) are expected for web services
- No port offset needed as this is the main web entry point
- Users expect web services on ports 80 and 443

---

## Required Ports

Both HTTP and HTTPS ports are **required** and always enabled:

| Port Type | Host Port | Container Port | Description |
|-----------|-----------|----------------|-------------|
| **HTTP** | 80 | 80 | Web server HTTP traffic |
| **HTTPS** | 443 | 443 | Web server HTTPS traffic (SSL/TLS) |

**Note:** Both ports are always active. SSL certificates must be configured in `persistent-data/ssl/` for HTTPS to function properly.

---

## Docker Compose Configuration

```yaml
services:
  nginx:
    image: nginx:latest
    container_name: nginx
    restart: unless-stopped
    
    ports:
      - "80:80"      # HTTP (required)
      - "443:443"    # HTTPS (required)
    
    volumes:
      - ./persistent-data/html:/usr/share/nginx/html:ro
      - ./persistent-data/conf.d:/etc/nginx/conf.d:ro
      - ./persistent-data/logs:/var/log/nginx
      - ./persistent-data/ssl:/etc/nginx/ssl:ro
```

---

## Firewall Configuration (Ubuntu UFW)

Both HTTP and HTTPS ports must be opened:

```bash
# Allow HTTP traffic
sudo ufw allow 80/tcp

# Allow HTTPS traffic
sudo ufw allow 443/tcp
```

**Note:** The `/tcp` suffix is optional in UFW but included here for clarity.

---

## SSL Certificate Setup

To enable HTTPS functionality:

1. Place your SSL certificates in `persistent-data/ssl/`
2. Configure your site in `persistent-data/conf.d/` to use the certificates
3. Restart the container: `./drive.sh restart`

**Certificate locations:**
- Certificates should be placed in `persistent-data/ssl/`
- Reference them in your site configuration as `/etc/nginx/ssl/certificate.crt` and `/etc/nginx/ssl/private.key`

**Example site configuration** (`persistent-data/conf.d/default.conf`):
```nginx
server {
    listen 80;
    listen 443 ssl;
    server_name example.com;

    ssl_certificate /etc/nginx/ssl/certificate.crt;
    ssl_certificate_key /etc/nginx/ssl/private.key;

    root /usr/share/nginx/html;
    index index.html;
}
```

---

## Cache Management

**Important:** Nginx cache is **not persistent**. Cache is stored inside the container and is automatically cleared when the container is restarted. This ensures a clean cache state on each restart.

If you need to manually clear the cache, restart the container:
```bash
./drive.sh restart
```

---

## Notes

- This service is an **exception** to the standard port allocation strategy
- Uses standard web ports (80, 443) as it's the primary web/proxy server
- Both HTTP and HTTPS ports are **always enabled** (not optional)
- Only one Nginx service should use ports 80/443 to avoid conflicts
- For additional web services, consider using the standard offset formula or reverse proxy through this service
- Cache is not persistent and clears on container restart

---

## See Also

- [Port Allocation Strategy](../strategy.md) - General port allocation strategy
- [Port Reference Guide](../reference.md) - Detailed port descriptions

