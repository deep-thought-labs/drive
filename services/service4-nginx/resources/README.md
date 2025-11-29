# Nginx Configuration Resources

This directory contains ready-to-use Nginx configuration examples and snippets. All files are complete and can be copied directly to `persistent-data/conf.d/` with minimal modifications.

## Quick Start

1. **Copy the desired configuration file** from `configurations/` to `persistent-data/conf.d/`
2. **Modify the configuration** according to your needs (look for `# MODIFY:` comments)
3. **Test the configuration:** `docker compose exec nginx nginx -t`
4. **Reload Nginx:** `docker compose exec nginx nginx -s reload`

## Configuration Files

### Most Common (Start Here)

#### 📥 [file-downloads.conf](configurations/file-downloads.conf)
**Purpose:** Serve downloadable files from a specific directory/endpoint.

**Use Case:** Create a file sharing or download area accessible via a URL path (e.g., `/downloads/`).

**Key Features:**
- Serves files from a dedicated directory
- Configures proper MIME types for downloads
- Optional directory listing
- File size limits

**Copy to:** `persistent-data/conf.d/file-downloads.conf`

---

#### 🔄 [reverse-proxy-rpc.conf](configurations/reverse-proxy-rpc.conf)
**Purpose:** Proxy requests to blockchain node RPC endpoints.

**Use Case:** Expose blockchain node RPC (port 26657) or gRPC (port 9090) through Nginx with SSL termination and security.

**Key Features:**
- Proxies to localhost RPC endpoints
- Proper headers for blockchain RPC
- Error handling
- Can be combined with SSL configuration

**Copy to:** `persistent-data/conf.d/reverse-proxy-rpc.conf`

---

#### 🔒 [https-ssl.conf](configurations/https-ssl.conf)
**Purpose:** Complete HTTPS/SSL configuration with HTTP to HTTPS redirect.

**Use Case:** Enable SSL/TLS encryption for your website or API.

**Key Features:**
- HTTP to HTTPS redirect
- Modern SSL configuration
- Security headers (HSTS)
- Ready for production use

**Copy to:** `persistent-data/conf.d/https-ssl.conf`

---

### Security & Performance

#### 🛡️ [rate-limiting.conf](configurations/rate-limiting.conf)
**Purpose:** Protect endpoints from abuse with rate limiting.

**Use Case:** Limit requests per IP address to prevent DDoS or API abuse.

**Key Features:**
- Per-IP rate limiting
- Per-endpoint rate limiting
- Custom error responses
- Configurable limits

**Copy to:** `persistent-data/conf.d/rate-limiting.conf`

---

#### 🌐 [cors-api.conf](configurations/cors-api.conf)
**Purpose:** Configure CORS headers for API endpoints.

**Use Case:** Allow cross-origin requests from web applications to your API.

**Key Features:**
- Configurable allowed origins
- Preflight request handling
- Credentials support
- Method and header restrictions

**Copy to:** `persistent-data/conf.d/cors-api.conf`

---

#### 🔐 [basic-auth.conf](configurations/basic-auth.conf)
**Purpose:** Protect routes with HTTP Basic Authentication.

**Use Case:** Add username/password protection to admin areas or sensitive endpoints.

**Key Features:**
- HTTP Basic Auth
- Per-location protection
- Exception paths
- Requires password file generation

**Copy to:** `persistent-data/conf.d/basic-auth.conf`

---

### Application Configurations

#### ⚛️ [spa-application.conf](configurations/spa-application.conf)
**Purpose:** Serve Single Page Applications (React, Vue, Angular, etc.).

**Use Case:** Deploy modern web applications that use client-side routing.

**Key Features:**
- Fallback to index.html for all routes
- Static asset caching
- API proxy support
- Production-ready setup

**Copy to:** `persistent-data/conf.d/spa-application.conf`

---

#### 🌍 [multiple-domains.conf](configurations/multiple-domains.conf)
**Purpose:** Configure multiple domains/virtual hosts in one file.

**Use Case:** Host multiple websites on the same Nginx instance.

**Key Features:**
- Multiple server blocks
- Wildcard domain support
- Separate root directories
- Per-domain configuration

**Copy to:** `persistent-data/conf.d/multiple-domains.conf`

---

#### 🔒 [security-headers.conf](configurations/security-headers.conf)
**Purpose:** Add security headers to all responses.

**Use Case:** Enhance security with modern security headers (CSP, X-Frame-Options, etc.).

**Key Features:**
- Content Security Policy
- X-Frame-Options
- X-Content-Type-Options
- Referrer-Policy
- Can be included as snippet

**Copy to:** `persistent-data/conf.d/security-headers.conf` or use as snippet

---

## Snippets (Reusable Components)

Snippets are reusable configuration fragments that can be included in your server blocks.

### 📦 [gzip-compression.conf](snippets/gzip-compression.conf)
Enable gzip compression for text-based files to reduce bandwidth usage.

**Usage:** Add `include /path/to/gzip-compression.conf;` in your server block.

---

### 📝 [logging-format.conf](snippets/logging-format.conf)
Custom log format for detailed request logging.

**Usage:** Include in your server block and reference the format name.

---

### 🔒 [ssl-params.conf](snippets/ssl-params.conf)
Optimized SSL/TLS parameters for security and performance.

**Usage:** Include in SSL server blocks.

---

## Complete Examples

### 🚀 [blockchain-api-gateway.conf](examples/blockchain-api-gateway.conf)
Complete example combining reverse proxy, SSL, rate limiting, and CORS for a blockchain API gateway.

**Use Case:** Production-ready API gateway for blockchain node RPC endpoints.

---

### 📁 [file-sharing-server.conf](examples/file-sharing-server.conf)
Complete file sharing server with downloads, authentication, and security.

**Use Case:** Secure file sharing/download server.

---

## Usage Tips

1. **Test Before Reloading:** Always test configurations with `nginx -t` before reloading
2. **One File Per Site:** Create separate `.conf` files for each site/domain
3. **Combine Configurations:** You can combine multiple configurations by copying relevant sections
4. **Use Snippets:** Include snippets in your server blocks to avoid duplication
5. **Check Logs:** Monitor `persistent-data/logs/error.log` for configuration issues

## File Locations Reference

- **Configuration files go to:** `persistent-data/conf.d/`
- **SSL certificates go to:** `persistent-data/ssl/`
- **Web content goes to:** `persistent-data/html/`
- **Logs are in:** `persistent-data/logs/`

## Need Help?

- See [Nginx Service Documentation](../../docs/nginx-service.md) for detailed usage
- Check [Nginx Official Documentation](https://nginx.org/en/docs/) for advanced configuration
- Review error logs: `tail -f persistent-data/logs/error.log`

