# Developer Documentation

## Prerequisites

- A Linux Virtual Machine (Debian/Ubuntu recommended)
- Docker Engine and Docker Compose (v2)
- `make`
- `sudo` privileges (for data directory creation)

## Environment Setup

### 1. Configure Environment Variables

```bash
make env
```

This generates `srcs/.env` interactively. Key variables:

| Variable | Example |
|----------|---------|
| `LOGIN` | `ysbai-jo` |
| `DOMAIN_NAME` | `ysbai-jo.42.fr` |
| `MYSQL_USER` | `wp_user` |
| `MYSQL_DATABASE` | `wordpress` |
| `WP_ADMIN_USER` | `imperor` (must not contain "admin") |
| `FTP_ADMIN_USER` / `FTP_USER` | FTP credentials |

### 2. Create Secrets

```bash
make secrets
```

Populates `secrets/*.txt` files with passwords. These are mounted as Docker secrets at runtime and **must never be committed to Git**.

### 3. DNS

Add to `/etc/hosts`:

```
127.0.0.1  ysbai-jo.42.fr
```

## Build & Launch

```bash
make          # Equivalent to `make up`
```

## Makefile Commands

| Command | Action |
|---------|--------|
| `make up` | Build images and start stack |
| `make down` | Stop containers |
| `make ps` | List container status |
| `make logs` | Tail container logs |
| `make stats` | Live resource usage |
| `make clean` | Stop containers, prune volumes/networks |
| `make delete` | Remove host data directory |
| `make clear` | Full reset: clean + delete + rebuild |
| `make re` | Alias for `fclean` then `all` |

## Docker Compose Quick Commands

```bash
# Build and start (detached)
docker compose up -d --build
# Stop and remove containers (retain volumes)
docker compose down
# Stop, remove containers and volumes
docker compose down --volumes --remove-orphans
# View logs (follow)
docker compose logs -f
# Execute a shell in a service
docker compose exec <service> sh
# List services
docker compose ps
```

## Project Architecture

```
srcs/
├── docker-compose.yml
├── .env
└── requirements/
    ├── nginx/          # Reverse proxy (TLS termination, port 443)
    ├── wordpress/      # WordPress + php-fpm
    ├── mariadb/        # Database
    ├── tools/          # setup.sh (env/secrets/data-dir helpers)
    └── bonus/
        ├── redis/      # Object cache
        ├── ftp/        # FTP access to wp_data volume
        ├── adminer/    # DB admin UI (port 8080)
        ├── portainer/  # Docker management (port 9443)
        └── apache/     # Static website (port 8888)
```

## Networks

| Network | Type | Connects |
|---------|------|----------|
| `external_net` | Bridge | NGINX, WordPress, FTP, Adminer, Portainer, Apache |
| `wp_net` | Internal | NGINX ↔ WordPress, FTP |
| `db_net` | Internal | WordPress ↔ MariaDB, Adminer |
| `cache_net` | Internal | WordPress ↔ Redis |

## Data Persistence

Host data root: `/home/ysbai-jo/data/` — contains DB and WordPress files; back up this directory to preserve state.

All persistent data lives on the host at `/home/ysbai-jo/data/`:

| Volume | Host Path | Container Mount |
|--------|-----------|-----------------|
| `db_data` | `/home/ysbai-jo/data/db` | `/var/lib/mysql` |
| `wp_data` | `/home/ysbai-jo/data/wp` | `/var/www/html` |
| `portainer_data` | Docker-managed | `/data` |

These are bind-mount volumes. Deleting `/home/ysbai-jo/data/` removes all persistent state. Use `make delete` or `make clear` to do this via the Makefile.
