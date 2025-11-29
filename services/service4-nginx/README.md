# Nginx Web Server

Primary web server and reverse proxy for Drive infrastructure management platform.

**Service Number:** 4  
**Service Name:** `nginx`  
**Container Name:** `nginx`

---

## Quick Start

### Start the Service

```bash
cd services/service4-nginx
./drive.sh up -d
```

### Access the Web Server

- **HTTP:** Open `http://localhost` in your browser
- **HTTPS:** Open `https://localhost` in your browser (requires SSL certificates)

### Verify Status

```bash
./drive.sh ps
```

You should see the container status as "Up" with ports `0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp`.

---

## Port Configuration

⚠️ **IMPORTANT:** This service is an **exception** to the standard port allocation strategy. It uses standard web ports (80, 443) instead of calculated ports, as it's the primary web/proxy server.

- **HTTP Port:** 80 (standard HTTP port)
- **HTTPS Port:** 443 (standard HTTPS port)

For complete port configuration details, see [`../../config/ports/services/service4-nginx.md`](../../config/ports/services/service4-nginx.md).

---

## Directory Structure

```
service4-nginx/
├── docker-compose.yml
├── drive.sh
└── persistent-data/
    ├── html/              # Web content (HTML, CSS, JS, images)
    │   └── index.html     # Default welcome page
    ├── conf.d/            # Nginx site configurations
    │   └── .gitkeep
    ├── logs/              # Nginx access and error logs
    │   └── .gitkeep
    └── ssl/               # SSL certificates for HTTPS
        └── .gitkeep
```

### Directory Descriptions

- **`html/`** - Place your website files here. This directory is served as the web root.
- **`conf.d/`** - Add Nginx site configuration files (`.conf`) here. These are automatically loaded by Nginx.
- **`logs/`** - Nginx access and error logs are written here.
- **`ssl/`** - Place SSL certificates here for HTTPS functionality.

---

## Configuration

### Adding Website Content

1. Place your HTML, CSS, JS, and image files in `persistent-data/html/`
2. The default `index.html` will be served at the root URL
3. Restart the container if needed: `./drive.sh restart`

### Initial Setup

**Important:** Before the web server can serve content, you need a configuration file. Copy the example configuration:

```bash
cd services/service4-nginx
cp conf.d.default.conf.example persistent-data/conf.d/default.conf
./drive.sh restart
```

### Configuring Virtual Hosts

**Note:** A default configuration file (`default.conf`) should be created from the example. You can modify it or create additional configuration files.

1. Create a configuration file in `persistent-data/conf.d/` (e.g., `mysite.conf`)
2. Configure your site settings:

```nginx
server {
    listen 80;
    listen 443 ssl;
    server_name example.com;

    ssl_certificate /etc/nginx/ssl/certificate.crt;
    ssl_certificate_key /etc/nginx/ssl/private.key;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

3. Restart the container: `./drive.sh restart`

### Setting Up HTTPS

1. Place your SSL certificates in `persistent-data/ssl/`:
   - Certificate file: `certificate.crt`
   - Private key: `private.key`

2. Reference them in your site configuration (see example above)

3. Restart the container: `./drive.sh restart`

---

## Common Operations

### View Logs

```bash
# View recent logs
./drive.sh logs --tail=50

# Follow logs in real-time
./drive.sh logs -f
```

### Restart Service

```bash
./drive.sh restart
```

### Stop Service

```bash
./drive.sh stop
```

### Check Nginx Configuration

```bash
docker compose exec nginx nginx -t
```

---

## Cache Management

**Important:** Nginx cache is **not persistent**. Cache is stored inside the container and is automatically cleared when the container is restarted. This ensures a clean cache state on each restart.

To manually clear the cache, restart the container:
```bash
./drive.sh restart
```

---

## Firewall Configuration

If you're running a firewall (e.g., UFW on Ubuntu), you need to allow HTTP and HTTPS traffic:

```bash
# Allow HTTP traffic
sudo ufw allow 80/tcp

# Allow HTTPS traffic
sudo ufw allow 443/tcp
```

---

## Troubleshooting

### Cannot Access Web Server

1. **Check if container is running:**
   ```bash
   ./drive.sh ps
   ```

2. **Check container logs:**
   ```bash
   ./drive.sh logs
   ```

3. **Verify port mapping:**
   ```bash
   docker compose ps
   ```
   Should show: `0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp`

4. **Check firewall:**
   ```bash
   sudo ufw status
   ```

### Configuration Errors

1. **Test Nginx configuration:**
   ```bash
   docker compose exec nginx nginx -t
   ```

2. **Check configuration files in `persistent-data/conf.d/`**

3. **View error logs:**
   ```bash
   ./drive.sh logs | grep error
   ```

### SSL Certificate Issues

1. **Verify certificates exist:**
   ```bash
   ls -la persistent-data/ssl/
   ```

2. **Check certificate paths in site configuration**

3. **Verify certificate permissions** (should be readable by Nginx)

---

## See Also

- **[Port Configuration](../../config/ports/services/service4-nginx.md)** - Complete port configuration
- **[Port Allocation Strategy](../../config/ports/strategy.md)** - General port allocation strategy
- **[Container Management](../../docs/container-management.md)** - Container management guide

---

## Notes

- This service uses standard web ports (80, 443) and does NOT follow the port offset formula
- Only one Nginx service should use ports 80/443 to avoid conflicts
- Cache is not persistent and clears on container restart
- Both HTTP and HTTPS ports are always enabled

