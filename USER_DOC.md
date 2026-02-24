# User Documentation

## Services Overview

| Service | Description | Access |
|---------|-------------|--------|
| **NGINX** | Reverse proxy with TLS (v1.2/v1.3) | `https://ysbai-jo.42.fr` |
| **WordPress** | CMS with php-fpm | Via NGINX |
| **MariaDB** | WordPress database | Internal only |
| **Redis** | WordPress object cache | Internal only |
| **FTP** | File access to WordPress volume | Port `21` |
| **Adminer** | Database management UI | `http://ysbai-jo.42.fr:8080` |
| **Portainer** | Docker management UI | `https://ysbai-jo.42.fr:9443` |
| **Apache** | Static website | `http://ysbai-jo.42.fr:8888` |


## First-Time Setup

Before starting the project for the first time, run:

```bash
make env      # Generate srcs/.env with your configuration
make secrets  # Create secrets/ files with passwords
```

## Start & Stop

```bash
make          # Build and start all services
make down     # Stop all services
```

## Accessing the Website

1. Ensure `ysbai-jo.42.fr` resolves to your VM's IP (configured in `/etc/hosts`).
2. Open **https://ysbai-jo.42.fr** in a browser (accept the self-signed certificate).
3. WordPress admin panel: **https://ysbai-jo.42.fr/wp-admin**

## Credentials

All passwords are stored as Docker secrets in the `secrets/` directory:

| File | Purpose |
|------|---------|
| `db_root_password.txt` | MariaDB root password |
| `db_user_password.txt` | MariaDB user password |
| `wp_admin_password.txt` | WordPress admin password |
| `wp_user_password.txt` | WordPress user password |
| `ftp_admin_password.txt` | FTP admin password |
| `ftp_user_password.txt` | FTP user password |
| `portainer_admin_password.txt` | Portainer admin password |

Usernames and other non-secret configuration are defined in `srcs/.env`.

## Checking Service Health

```bash
make ps       # Show container status
make logs     # Follow live logs (Ctrl+C to exit)
make stats    # Monitor resource usage
```

All containers are configured with health checks and automatic restart on crash.
