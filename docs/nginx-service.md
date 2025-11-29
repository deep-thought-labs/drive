# Nginx Web Server Service

Complete guide to managing the Nginx web server and reverse proxy service in Drive. This service provides HTTP/HTTPS web serving capabilities and can act as a reverse proxy for other services.

---

## Overview

The Nginx service is Drive's primary web server and reverse proxy. It uses standard web ports (80 for HTTP, 443 for HTTPS) and serves as the main entry point for web traffic.

**Service Information:**
- **Service Number:** 4
- **Service Name:** `nginx`
- **Container Name:** `nginx`
- **Service Location:** `services/service4-nginx/`
- **Image:** `nginx:latest`

**⚠️ Important:** This service is an **exception** to the standard port allocation strategy. It uses standard web ports (80, 443) instead of calculated ports, as it's the primary web/proxy server.

---

## Quick Start

### Starting the Service

```bash
cd services/service4-nginx
./drive.sh up -d
```

### Accessing the Web Server

Once started, the web server is accessible at:
- **HTTP:** `http://localhost` (port 80)
- **HTTPS:** `https://localhost` (port 443, requires SSL certificates)

### Verifying Status

```bash
./drive.sh ps
```

You should see the container status as "Up" with ports `0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp`.

---

## Directory Structure

The service uses the following directory structure:

```
service4-nginx/
├── docker-compose.yml
├── drive.sh
├── README.md
├── resources/             # Configuration examples and templates
│   ├── README.md          # Guide to all configuration examples
│   ├── configurations/    # Ready-to-use configuration files
│   │   ├── file-downloads.conf
│   │   ├── reverse-proxy-rpc.conf
│   │   ├── https-ssl.conf
│   │   └── ... (more examples)
│   ├── snippets/          # Reusable configuration snippets
│   └── examples/          # Complete example configurations
└── persistent-data/
    ├── html/              # Web content (HTML, CSS, JS, images)
    │   └── index.html     # Default welcome page
    ├── conf.d/            # Nginx site configurations
    │   ├── default.conf   # Default server configuration (versioned)
    │   └── .gitignore     # Ignores user configs, keeps default.conf
    ├── logs/              # Nginx access and error logs
    │   └── .gitkeep
    └── ssl/               # SSL certificates for HTTPS
        └── .gitkeep
```

### Directory Descriptions

- **`resources/`** - Configuration examples and templates. Contains ready-to-use configuration files that you can copy to `conf.d/`. See [resources/README.md](../services/service4-nginx/resources/README.md) for a complete guide.
  - **`configurations/`** - Complete, ready-to-use configuration files (file downloads, reverse proxy, HTTPS, rate limiting, CORS, etc.)
  - **`snippets/`** - Reusable configuration fragments (gzip compression, SSL parameters, logging formats)
  - **`examples/`** - Complete example configurations combining multiple features (blockchain API gateway, file sharing server)
- **`html/`** - Place your website files here. This directory is served as the web root (`/usr/share/nginx/html` inside the container).
- **`conf.d/`** - Add Nginx site configuration files (`.conf`) here. These are automatically loaded by Nginx.
  - Copy configuration files from `resources/configurations/` to this directory
  - The `default.conf` file is already present and versioned
- **`logs/`** - Nginx access and error logs are written here. Logs persist across container restarts.
- **`ssl/`** - Place SSL certificates here for HTTPS functionality. Certificates are mounted to `/etc/nginx/ssl/` inside the container.

---

## Basic Configuration

### Initial Setup

**Note:** A default configuration file (`default.conf`) is already included in `persistent-data/conf.d/`. The web server is ready to use immediately after starting the container.

The default configuration file provides a basic server block that:
- Listens on port 80 (HTTP)
- Serves files from `/usr/share/nginx/html` (mapped to `persistent-data/html/`)
- Automatically loads configuration files from `/etc/nginx/conf.d/` (mapped to `persistent-data/conf.d/`)

### Adding Website Content

1. **Place your files in `persistent-data/html/`:**
   ```bash
   cd services/service4-nginx/persistent-data/html
   # Add your HTML, CSS, JS, and image files here
   ```

2. **The default `index.html` will be served at the root URL**

3. **Restart the container if needed:**
   ```bash
   ./drive.sh restart
   ```

---

## Configuring Virtual Hosts

You can configure multiple websites by creating site configuration files in `persistent-data/conf.d/`.

### Basic Site Configuration

1. **Create a configuration file:**
   ```bash
   cd services/service4-nginx/persistent-data/conf.d
   nano mysite.conf
   ```

2. **Add your site configuration:**
   ```nginx
   server {
       listen 80;
       server_name example.com www.example.com;

       root /usr/share/nginx/html;
       index index.html;

       location / {
           try_files $uri $uri/ =404;
       }
   }
   ```

3. **Restart the container:**
   ```bash
   ./drive.sh restart
   ```

### Advanced Site Configuration

Example with custom root directory and error pages:

```nginx
server {
    listen 80;
    server_name example.com;

    root /usr/share/nginx/html/mysite;
    index index.html index.htm;

    # Custom error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
}
```

---

## HTTPS/SSL Configuration

### Setting Up SSL Certificates

1. **Place your SSL certificates in `persistent-data/ssl/`:**
   ```bash
   cd services/service4-nginx/persistent-data/ssl
   # Place your certificate.crt and private.key files here
   ```

2. **Update your site configuration to use SSL:**
   ```nginx
   server {
       listen 80;
       listen 443 ssl;
       server_name example.com;

       # SSL certificate configuration
       ssl_certificate /etc/nginx/ssl/certificate.crt;
       ssl_certificate_key /etc/nginx/ssl/private.key;

       # SSL configuration (recommended settings)
       ssl_protocols TLSv1.2 TLSv1.3;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;

       root /usr/share/nginx/html;
       index index.html;

       location / {
           try_files $uri $uri/ =404;
       }
   }
   ```

3. **Restart the container:**
   ```bash
   ./drive.sh restart
   ```

### Redirecting HTTP to HTTPS

To automatically redirect all HTTP traffic to HTTPS:

```nginx
server {
    listen 80;
    server_name example.com;
    
    # Redirect all HTTP traffic to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
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

---

## Reverse Proxy Configuration

Nginx can act as a reverse proxy for other services. This is useful for:
- Proxying requests to blockchain node RPC endpoints
- Load balancing between multiple services
- Adding SSL termination for services that don't support HTTPS

### Basic Reverse Proxy Example

```nginx
server {
    listen 80;
    server_name api.example.com;

    location / {
        # Proxy to a blockchain node RPC endpoint
        proxy_pass http://localhost:26657;
        
        # Proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Reverse Proxy with SSL

```nginx
server {
    listen 443 ssl;
    server_name api.example.com;

    ssl_certificate /etc/nginx/ssl/certificate.crt;
    ssl_certificate_key /etc/nginx/ssl/private.key;

    location / {
        # Proxy to internal service
        proxy_pass http://localhost:26657;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Note:** When proxying to services running in Docker containers, use the container name or Docker network IP instead of `localhost`.

---

## Common Operations

### Viewing Logs

```bash
# View recent logs
./drive.sh logs --tail=50

# Follow logs in real-time
./drive.sh logs -f

# View only error logs
./drive.sh logs | grep error

# View access logs from persistent-data
tail -f persistent-data/logs/access.log
```

### Restarting the Service

```bash
./drive.sh restart
```

### Stopping the Service

```bash
./drive.sh stop
```

### Testing Nginx Configuration

Before restarting, test your configuration:

```bash
docker compose exec nginx nginx -t
```

This will validate your configuration files and report any syntax errors.

### Reloading Configuration Without Restart

To reload configuration without stopping the service:

```bash
docker compose exec nginx nginx -s reload
```

---

## Cache Management

**Important:** Nginx cache is **not persistent**. Cache is stored inside the container and is automatically cleared when the container is restarted. This ensures a clean cache state on each restart.

### Clearing Cache

To manually clear the cache, restart the container:

```bash
./drive.sh restart
```

### Disabling Cache (Development)

If you want to disable caching during development, add this to your site configuration:

```nginx
location / {
    add_header Cache-Control "no-cache, no-store, must-revalidate";
    add_header Pragma "no-cache";
    add_header Expires "0";
}
```

---

## Firewall Configuration

If you're running a firewall (e.g., UFW on Ubuntu), you need to allow HTTP and HTTPS traffic:

```bash
# Allow HTTP traffic
sudo ufw allow 80/tcp

# Allow HTTPS traffic
sudo ufw allow 443/tcp

# Verify firewall rules
sudo ufw status
```

---

## Troubleshooting

### Cannot Access Web Server

**Symptoms:**
- Browser shows "Connection refused" or timeout
- Cannot reach `http://localhost`

**Solutions:**

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

4. **Check if port 80 is already in use:**
   ```bash
   sudo lsof -i :80
   # or
   sudo netstat -tulpn | grep :80
   ```

5. **Check firewall:**
   ```bash
   sudo ufw status
   ```

### Configuration Errors

**Symptoms:**
- Container fails to start
- Nginx reports configuration errors

**Solutions:**

1. **Test Nginx configuration:**
   ```bash
   docker compose exec nginx nginx -t
   ```

2. **Check configuration files in `persistent-data/conf.d/`:**
   ```bash
   ls -la persistent-data/conf.d/
   cat persistent-data/conf.d/*.conf
   ```

3. **View error logs:**
   ```bash
   ./drive.sh logs | grep error
   # or
   tail -f persistent-data/logs/error.log
   ```

4. **Check for syntax errors in configuration files**

### SSL Certificate Issues

**Symptoms:**
- HTTPS connection fails
- Browser shows certificate errors

**Solutions:**

1. **Verify certificates exist:**
   ```bash
   ls -la persistent-data/ssl/
   ```

2. **Check certificate paths in site configuration:**
   - Certificates should be referenced as `/etc/nginx/ssl/certificate.crt`
   - Private key should be referenced as `/etc/nginx/ssl/private.key`

3. **Verify certificate permissions:**
   ```bash
   ls -la persistent-data/ssl/
   ```
   Certificates should be readable by Nginx (inside the container)

4. **Test certificate validity:**
   ```bash
   openssl x509 -in persistent-data/ssl/certificate.crt -text -noout
   ```

### 404 Not Found Errors

**Symptoms:**
- Pages return 404 errors
- Files not found

**Solutions:**

1. **Check file locations:**
   ```bash
   ls -la persistent-data/html/
   ```

2. **Verify root directory in configuration:**
   - Default root is `/usr/share/nginx/html` (mapped to `persistent-data/html/`)
   - Ensure your files are in the correct location

3. **Check file permissions:**
   ```bash
   ls -la persistent-data/html/
   ```
   Files should be readable

### Reverse Proxy Not Working

**Symptoms:**
- Proxy returns errors
- Cannot reach backend service

**Solutions:**

1. **Verify backend service is running:**
   ```bash
   # Check if the service you're proxying to is running
   docker compose ps
   ```

2. **Use container name or Docker network IP:**
   - Instead of `localhost`, use the container name or Docker network IP
   - Example: `proxy_pass http://infinite:26657;` (if proxying to the infinite container)

3. **Check proxy headers:**
   - Ensure `proxy_set_header` directives are correct
   - Verify `Host` header matches the backend service

---

## Best Practices

### Security

1. **Always use HTTPS in production:**
   - Configure SSL certificates for all production sites
   - Redirect HTTP to HTTPS

2. **Keep Nginx updated:**
   - The `nginx:latest` image is automatically updated
   - Pull latest image: `docker compose pull`

3. **Restrict access when possible:**
   ```nginx
   # Deny access to hidden files
   location ~ /\. {
       deny all;
   }
   ```

4. **Use strong SSL configuration:**
   ```nginx
   ssl_protocols TLSv1.2 TLSv1.3;
   ssl_ciphers HIGH:!aNULL:!MD5;
   ```

### Performance

1. **Enable gzip compression:**
   ```nginx
   gzip on;
   gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
   ```

2. **Set appropriate cache headers:**
   ```nginx
   location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   ```

3. **Monitor logs regularly:**
   - Check access logs for unusual patterns
   - Monitor error logs for issues

---

## Port Configuration

This service uses standard web ports and does NOT follow the port offset formula:

- **HTTP:** Port 80 (standard HTTP port)
- **HTTPS:** Port 443 (standard HTTPS port)

For complete port configuration details, see [`../config/ports/services/service4-nginx.md`](../config/ports/services/service4-nginx.md).

---

## Configuration Resources

Ready-to-use configuration examples are available in the `resources/` directory:

- **[Configuration Examples Guide](../services/service4-nginx/resources/README.md)** - Complete guide to all available configurations
- **Most Common Configurations:**
  - [File Downloads](../services/service4-nginx/resources/configurations/file-downloads.conf) - Serve downloadable files from a directory
  - [Reverse Proxy RPC](../services/service4-nginx/resources/configurations/reverse-proxy-rpc.conf) - Proxy requests to blockchain node RPC endpoints
  - [HTTPS/SSL](../services/service4-nginx/resources/configurations/https-ssl.conf) - Complete HTTPS/SSL setup with HTTP to HTTPS redirect
  - [Rate Limiting](../services/service4-nginx/resources/configurations/rate-limiting.conf) - Protect endpoints from abuse
  - [CORS API](../services/service4-nginx/resources/configurations/cors-api.conf) - Configure CORS headers for API endpoints

All configuration files are complete and ready to copy to `persistent-data/conf.d/`. Each file includes `# MODIFY:` comments indicating where to customize the configuration.

## See Also

- **[Port Configuration](../config/ports/services/service4-nginx.md)** - Complete port configuration
- **[Port Allocation Strategy](../config/ports/strategy.md)** - General port allocation strategy
- **[Container Management](container-management.md)** - Container management guide
- **[Service README](../services/service4-nginx/README.md)** - Service-specific documentation

---

## Quick Reference

### Most Common Commands

```bash
# Start service
cd services/service4-nginx
./drive.sh up -d

# View logs
./drive.sh logs -f

# Restart service
./drive.sh restart

# Test configuration
docker compose exec nginx nginx -t

# Reload configuration
docker compose exec nginx nginx -s reload

# Stop service
./drive.sh stop
```

### File Locations

- **Web content:** `persistent-data/html/`
- **Site configs:** `persistent-data/conf.d/`
- **SSL certificates:** `persistent-data/ssl/`
- **Logs:** `persistent-data/logs/`

### Access URLs

- **HTTP:** `http://localhost`
- **HTTPS:** `https://localhost` (requires SSL certificates)

