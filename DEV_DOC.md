# Inception - Developer Documentation

## Overview

This document provides comprehensive technical information for developers working on the Inception project. It covers setup, architecture, commands, and data management.

## Prerequisites

### System Requirements

- **Operating System**: Linux (Ubuntu 20.04+, Debian 11+) or macOS
- **CPU**: 2+ cores recommended
- **RAM**: 4GB minimum, 8GB recommended
- **Disk Space**: 5GB+ free space
- **Network**: Internet connection for image building

### Required Software

| Software | Minimum Version | Installation Command |
|----------|----------------|----------------------|
| Docker Engine | 20.10.0 | `curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh` |
| Docker Compose | 2.0.0 | Included with Docker Desktop, or install plugin |
| Make | 4.0+ | `sudo apt install make` (Ubuntu/Debian) |
| Git | 2.20+ | `sudo apt install git` |
| OpenSSL | 1.1.1+ | `sudo apt install openssl` |

### User Permissions

Add your user to the Docker group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verify Docker access:
```bash
docker run hello-world
```

## Environment Setup from Scratch

### 1. Clone and Navigate

```bash
git clone <repository-url> inception
cd inception
```

### 2. Create Directory Structure

The project expects the following structure:

```
inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── .dockerignore
│       │   ├── conf/
│       │   │   └── nginx.conf
│       │   └── tools/
│       │       └── setup.sh
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── .dockerignore
│       │   ├── conf/
│       │   │   └── www.conf
│       │   └── tools/
│       │       └── setup.sh
│       └── mariadb/
│           ├── Dockerfile
│           ├── .dockerignore
│           ├── conf/
│           │   └── 50-server.cnf
│           └── tools/
│               └── init.sh
```

### 3. Configure Environment Variables

Create `srcs/.env` file:

```bash name=srcs/.env
# Domain Configuration
DOMAIN_NAME=VICTORxEVO.42.fr

# MySQL/MariaDB Configuration
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD_FILE=/run/secrets/db_password

# WordPress Configuration
WP_ADMIN_USER=VICTORxEVO
WP_ADMIN_PASSWORD_FILE=/run/secrets/credentials
WP_ADMIN_EMAIL=VICTORxEVO@student.42.fr

WP_USER=editor
WP_USER_PASSWORD_FILE=/run/secrets/credentials
WP_USER_EMAIL=editor@student.42.fr

# Container Configuration
WP_TITLE=Inception Project
WP_URL=https://VICTORxEVO.42.fr
```

**Variable Descriptions:**

| Variable | Purpose | Example |
|----------|---------|---------|
| `DOMAIN_NAME` | Your 42 domain | `login.42.fr` |
| `MYSQL_ROOT_PASSWORD_FILE` | Path to root password secret | `/run/secrets/db_root_password` |
| `MYSQL_DATABASE` | WordPress database name | `wordpress` |
| `MYSQL_USER` | WordPress database user | `wp_user` |
| `WP_ADMIN_USER` | WordPress admin username | Must not contain "admin" |
| `WP_TITLE` | Website title | Any string |

### 4. Create Secrets

Create secret files with secure passwords:

```bash
mkdir -p secrets

# Generate secure passwords
openssl rand -base64 32 > secrets/db_root_password.txt
openssl rand -base64 32 > secrets/db_password.txt
openssl rand -base64 32 > secrets/credentials.txt

# Set proper permissions (read-only)
chmod 600 secrets/*
```

**Security Notes:**
- Never commit secrets to Git
- Use strong, random passwords (32+ characters)
- Different password for each service
- Limit file permissions to owner only

### 5. Configure Domain Name

Add domain to `/etc/hosts`:

```bash
sudo sh -c 'echo "127.0.0.1 VICTORxEVO.42.fr" >> /etc/hosts'
```

Verify:
```bash
ping VICTORxEVO.42.fr
```

### 6. Generate SSL Certificates

NGINX Dockerfile should include certificate generation, but you can generate manually:

```bash
mkdir -p srcs/requirements/nginx/tools/certs

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout srcs/requirements/nginx/tools/certs/nginx-selfsigned.key \
  -out srcs/requirements/nginx/tools/certs/nginx-selfsigned.crt \
  -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=VICTORxEVO/CN=VICTORxEVO.42.fr"
```

## Building and Launching

### Using Makefile

The Makefile provides convenient commands:

#### Build and Start
```bash
make
# or
make all
```

**What it does:**
1. Creates data directories on host
2. Builds Docker images from Dockerfiles
3. Creates Docker network
4. Starts containers via docker-compose

#### Stop Containers
```bash
make down
```

Stops containers but preserves volumes and images.

#### Clean Containers
```bash
make clean
```

Stops and removes containers, networks (keeps volumes and images).

#### Remove Everything
```bash
make fclean
```

⚠️ **Destructive**: Removes containers, images, volumes, networks, and build cache.

#### Rebuild Everything
```bash
make re
```

Equivalent to `make fclean && make`.

#### View Logs
```bash
make logs
```

Shows real-time logs from all containers.

### Using Docker Compose Directly

Navigate to `srcs/` directory:

```bash
cd srcs
```

#### Build Images
```bash
docker-compose build
```

Options:
- `--no-cache`: Build without using cache
- `--pull`: Always pull newer base images
- `--parallel`: Build images in parallel

#### Start Services
```bash
docker-compose up -d
```

Options:
- `-d`: Detached mode (background)
- `--force-recreate`: Recreate containers even if config unchanged
- `--build`: Build images before starting

#### Stop Services
```bash
docker-compose down
```

Options:
- `-v`: Remove volumes too
- `--rmi all`: Remove all images

#### View Logs
```bash
docker-compose logs -f
```

Options:
- `-f`: Follow log output
- `<service>`: Show logs for specific service (e.g., `nginx`)

## Managing Containers and Volumes

### Container Management Commands

#### List Running Containers
```bash
docker ps
```

#### List All Containers (including stopped)
```bash
docker ps -a
```

#### Inspect Container
```bash
docker inspect <container_name>
```

#### Execute Command in Container
```bash
docker exec -it <container_name> <command>
```

Examples:
```bash
# Access NGINX shell
docker exec -it inception_nginx_1 sh

# Check NGINX configuration
docker exec inception_nginx_1 nginx -t

# Access WordPress shell
docker exec -it inception_wordpress_1 sh

# Access MariaDB shell
docker exec -it inception_mariadb_1 mysql -u root -p

# Check PHP version
docker exec inception_wordpress_1 php -v
```

#### View Container Logs
```bash
docker logs <container_name>
```

Options:
- `-f`: Follow log output
- `--tail 100`: Show last 100 lines
- `--since 30m`: Show logs from last 30 minutes

#### Stop Container
```bash
docker stop <container_name>
```

#### Start Container
```bash
docker start <container_name>
```

#### Restart Container
```bash
docker restart <container_name>
```

#### Remove Container
```bash
docker rm <container_name>
```

Use `-f` to force remove running container.

### Volume Management Commands

#### List Volumes
```bash
docker volume ls
```

#### Inspect Volume
```bash
docker volume inspect <volume_name>
```

Shows mount point, driver, and other details.

#### Show Volume Size
```bash
docker system df -v
```

#### Access Volume Data (Host)
```bash
# WordPress files
ls -la /home/VICTORxEVO/data/wordpress/

# MariaDB files
ls -la /home/VICTORxEVO/data/mariadb/
```

⚠️ May require sudo depending on permissions.

#### Backup Volume
```bash
# Using docker cp
docker run --rm -v inception_wordpress_data:/data -v $(pwd):/backup ubuntu tar -czf /backup/wordpress-backup.tar.gz -C /data .

# Direct backup (if accessible)
sudo tar -czf wordpress-backup.tar.gz /home/VICTORxEVO/data/wordpress/
```

#### Restore Volume
```bash
# Stop containers first
make down

# Restore data
sudo tar -xzf wordpress-backup.tar.gz -C /home/VICTORxEVO/data/

# Start containers
make
```

#### Remove Volume
```bash
docker volume rm <volume_name>
```

⚠️ **Data will be lost!** Backup first.

#### Remove All Unused Volumes
```bash
docker volume prune
```

### Network Management Commands

#### List Networks
```bash
docker network ls
```

#### Inspect Network
```bash
docker network inspect inception_network
```

Shows connected containers and their IP addresses.

#### Test Container Connectivity
```bash
# From WordPress to MariaDB
docker exec inception_wordpress_1 ping mariadb

# From NGINX to WordPress
docker exec inception_nginx_1 ping wordpress
```

#### View Network Traffic
```bash
docker network inspect inception_network | grep -A 10 "Containers"
```

## Data Persistence

### How Data Persists

#### WordPress Volume
- **Docker Volume**: `inception_wordpress_data`
- **Host Path**: `/home/VICTORxEVO/data/wordpress/`
- **Container Mount**: `/var/www/html`
- **Contains**:
  - WordPress core files
  - Themes (`wp-content/themes/`)
  - Plugins (`wp-content/plugins/`)
  - Uploads (`wp-content/uploads/`)
  - Configuration (`wp-config.php`)

#### MariaDB Volume
- **Docker Volume**: `inception_mariadb_data`
- **Host Path**: `/home/VICTORxEVO/data/mariadb/`
- **Container Mount**: `/var/lib/mysql`
- **Contains**:
  - Database files (`.frm`, `.ibd`)
  - Binary logs
  - InnoDB system tablespace
  - MySQL internal databases

### Data Lifecycle

```
Container Start → Check if volume exists
                    ↓
                  Yes: Mount existing data
                    ↓
                  No: Initialize fresh data
                    ↓
                Service runs with persistent data
                    ↓
              Container Stop → Data remains in volume
                    ↓
              Next Start → Mounts same data (persistent)
```

### Verifying Data Persistence

#### Test WordPress Persistence:
1. Start services: `make`
2. Create a test post via WordPress admin
3. Stop services: `make down`
4. Start services again: `make`
5. Verify test post still exists

#### Test Database Persistence:
```bash
# Create test data
docker exec inception_mariadb_1 mysql -u root -p$(cat secrets/db_root_password.txt) -e "CREATE DATABASE test_db;"

# Stop containers
make down

# Start containers
make

# Verify data exists
docker exec inception_mariadb_1 mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW DATABASES;"
```

### Data Backup Strategy

#### Automated Backup Script

```bash name=backup.sh url=
#!/bin/bash

BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup WordPress files
echo "Backing up WordPress files..."
sudo tar -czf "$BACKUP_DIR/wordpress.tar.gz" /home/VICTORxEVO/data/wordpress/

# Backup database
echo "Backing up database..."
docker exec inception_mariadb_1 mysqldump -u root -p$(cat secrets/db_root_password.txt) --all-databases > "$BACKUP_DIR/database.sql"

# Backup configurations
echo "Backing up configurations..."
cp -r srcs/.env secrets/ "$BACKUP_DIR/"

echo "Backup complete: $BACKUP_DIR"
```

Usage:
```bash
chmod +x backup.sh
./backup.sh
```

## Debugging and Troubleshooting

### Common Issues

#### Issue: Port 443 Already in Use

**Symptoms:**
```
Error: bind: address already in use
```

**Solution:**
```bash
# Find process using port 443
sudo lsof -i :443

# Kill process
sudo kill -9 <PID>

# Or use different port in docker-compose.yml (not recommended for this project)
```

#### Issue: Permission Denied on Volumes

**Symptoms:**
```
Error: cannot write to /var/www/html
```

**Solution:**
```bash
# Fix ownership
sudo chown -R www-data:www-data /home/VICTORxEVO/data/wordpress/
sudo chown -R mysql:mysql /home/VICTORxEVO/data/mariadb/
```

#### Issue: Database Connection Failed

**Symptoms:**
```
Error establishing a database connection
```

**Solutions:**
1. Verify MariaDB is running: `docker ps | grep mariadb`
2. Check MariaDB logs: `docker logs inception_mariadb_1`
3. Verify credentials in `.env` match secrets
4. Wait 30 seconds for database initialization
5. Test connection:
```bash
docker exec inception_wordpress_1 mysql -h mariadb -u $MYSQL_USER -p$(cat secrets/db_password.txt) -e "SHOW DATABASES;"
```

#### Issue: NGINX 502 Bad Gateway

**Symptoms:**
Browser shows "502 Bad Gateway"

**Solutions:**
1. Check if WordPress is running: `docker ps | grep wordpress`
2. Check WordPress logs: `docker logs inception_wordpress_1`
3. Verify NGINX can reach WordPress:
```bash
docker exec inception_nginx_1 ping wordpress
docker exec inception_nginx_1 nc -zv wordpress 9000
```
4. Check PHP-FPM status:
```bash
docker exec inception_wordpress_1 ps aux | grep php-fpm
```

### Development Tips

#### Live Configuration Changes

For NGINX configuration changes:
```bash
# Edit configuration
nano srcs/requirements/nginx/conf/nginx.conf

# Rebuild and restart NGINX only
docker-compose up -d --build nginx

# Test configuration
docker exec inception_nginx_1 nginx -t

# Reload NGINX
docker exec inception_nginx_1 nginx -s reload
```

For WordPress/PHP configuration:
```bash
# Edit configuration
nano srcs/requirements/wordpress/conf/www.conf

# Rebuild and restart WordPress only
docker-compose up -d --build wordpress
```

For MariaDB configuration:
```bash
# Edit configuration
nano srcs/requirements/mariadb/conf/50-server.cnf

# Restart required (rebuild not needed if conf is copied during build)
docker restart inception_mariadb_1
```

#### Accessing Service Directly

```bash
# MariaDB client
docker exec -it inception_mariadb_1 mysql -u root -p

# WordPress CLI
docker exec -it inception_wordpress_1 wp --info --allow-root

# Shell access
docker exec -it inception_nginx_1 sh
docker exec -it inception_wordpress_1 bash
docker exec -it inception_mariadb_1 bash
```

#### Monitoring Resources

```bash
# Real-time container stats
docker stats

# Disk usage
docker system df

# Detailed disk usage
docker system df -v
```

## Architecture Details

### Service Communication Flow

```
External Request (HTTPS:443)
        ↓
    [NGINX Container]
    - Terminates TLS
    - Validates request
        ↓
FastCGI (Port 9000) via Docker Network
        ↓
    [WordPress Container]
    - PHP-FPM processes request
    - Generates dynamic content
        ↓
MySQL Protocol (Port 3306) via Docker Network
        ↓
    [MariaDB Container]
    - Executes queries
    - Returns data
        ↓
Response flows back through chain
        ↓
    [NGINX] → Client (Encrypted HTTPS)
```

### Docker Compose Configuration

Key sections of `docker-compose.yml`:

```yaml
version: '3.8'

services:
  mariadb:
    build: ./requirements/mariadb
    container_name: inception_mariadb_1
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - inception_network
    restart: always
    secrets:
      - db_root_password
      - db_password

  wordpress:
    build: ./requirements/wordpress
    container_name: inception_wordpress_1
    depends_on:
      - mariadb
    volumes:
      - wordpress_data:/var/www/html
    networks:
      - inception_network
    restart: always
    secrets:
      - db_password
      - credentials

  nginx:
    build: ./requirements/nginx
    container_name: inception_nginx_1
    depends_on:
      - wordpress
    ports:
      - "443:443"
    volumes:
      - wordpress_data:/var/www/html:ro
    networks:
      - inception_network
    restart: always

volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/VICTORxEVO/data/mariadb

  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/VICTORxEVO/data/wordpress

networks:
  inception_network:
    driver: bridge

secrets:
  db_root_password:
    file: ../secrets/db_root_password.txt
  db_password:
    file: ../secrets/db_password.txt
  credentials:
    file: ../secrets/credentials.txt
```

## Contributing

### Code Style

- Use tabs for indentation in Makefiles
- Use spaces (2) for YAML files
- Comment complex bash scripts
- Follow Docker best practices (multi-stage builds, layer caching)

### Testing Before Commit

```bash
# Clean environment
make fclean

# Fresh build
make

# Verify services
docker ps
curl -k https://ysbai-jo.42.fr

# Check logs
docker-compose logs

# Test database
docker exec inception_mariadb_1 mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW DATABASES;"
```

### Git Workflow

```bash
# Never commit secrets!
git add srcs/ Makefile README.md USER_DOC.md DEV_DOC.md

# Verify no secrets in staging
git diff --cached

# Commit
git commit -m "feat: implement feature X"

# Push
git push origin main
```

## Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [WordPress Docker Image](https://hub.docker.com/_/wordpress) (for reference, not to use directly)
- [MariaDB Docker Image](https://hub.docker.com/_/mariadb) (for reference, not to use directly)
- [NGINX Docker Image](https://hub.docker.com/_/nginx) (for reference, not to use directly)

## Support

For technical issues:
1. Check logs: `docker-compose logs`
2. Verify configuration files
3. Consult this documentation
4. Review project requirements in `inception-text.txt`
5. Ask peers for code review

---

**Last Updated**: 2026-02-05  
**Maintainer**: ysbai-jo