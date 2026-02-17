# Inception - User Documentation

## Overview

This document provides clear instructions for end users and administrators to use the Inception infrastructure. The system provides a WordPress website with a database backend, all running in isolated Docker containers.

## Services Provided

The Inception stack includes the following services:

### 1. **NGINX Web Server**
- **Purpose**: Handles HTTPS connections and serves as reverse proxy
- **Port**: 443 (HTTPS only)
- **Features**: TLSv1.2/TLSv1.3 encryption, request forwarding to WordPress

### 2. **WordPress CMS**
- **Purpose**: Content management system for website
- **Access**: Through NGINX (not directly accessible)
- **Features**: Full WordPress installation with two user accounts

### 3. **MariaDB Database**
- **Purpose**: Stores WordPress content and configuration
- **Access**: Internal only (from WordPress container)
- **Features**: Persistent data storage with automatic backups

### 4. **Data Volumes**
- **WordPress Files**: Located at `/home/viktorevo/data/wordpress`
- **Database Files**: Located at `/home/viktorevo/data/db`

## Getting Started

### Starting the Project

1. Open a terminal in the project directory
2. Run the startup command:

```bash
make
# or explicitly:
make up
```

**What happens:**
- Setup script creates directories and generates secure passwords (if needed)
- Docker images are built (first time only - may take 5-10 minutes)
- Containers are created and started
- Services perform initialization (database creation, WordPress setup)
- System becomes available at https://ysbai-jo.42.fr
- Logs are displayed automatically (Ctrl+C to exit)

### Stopping the Project

To stop all services while preserving data:

```bash
make down
```

**What happens:**
- All containers are stopped gracefully
- Data in volumes is preserved
- Network is removed
- Images remain intact for fast restart
- Next startup will be faster (no rebuild needed)

### Monitoring Services

#### Check Container Status

```bash
make ps
```

Shows which containers are running and their current state.

#### View Live Logs

```bash
make logs
```

Displays real-time logs from all containers. Press Ctrl+C to exit.

#### Monitor Resource Usage

```bash
make stats
```

Shows CPU, memory, network, and disk usage for each container in real-time.

### Cleanup Commands

#### Basic Cleanup (Preserve Images)

```bash
make clean
```

**What happens:**
- Stops all containers
- Removes all volumes (⚠️ **WordPress and database data lost**)
- Keeps Docker images (fast rebuild)

**Use when:** You want to reset data but keep images

#### Full Docker Cleanup

```bash
make fclean
```

⚠️ **WARNING**: This command will:
- Stop all containers
- Remove all volumes (⚠️ **ALL DATA WILL BE LOST**)
- Delete all Docker images
- Prune Docker system (cache, unused networks, etc.)
- Clean build cache

**Use when:** You want to completely rebuild from scratch

#### Complete Reset with Restart

```bash
make clear
```

⚠️ **NUCLEAR OPTION**: This command will:
- Perform full cleanup (same as `fclean`)
- Delete data directory from host system (`/home/viktorevo/data`)
- Automatically rebuild and restart everything

**Use when:** You want absolutely everything deleted and recreated fresh

### Rebuild and Restart

```bash
make re
```

Equivalent to: `make fclean` then `make all`

**Use this when:**
- Configuration changes were made in Dockerfiles
- Environment variables were modified
- You need a clean rebuild with fresh images

## Accessing the Website

### WordPress Frontend

Visit the public website:
- **URL**: https://ysbai-jo.42.fr
- **Browser**: Any modern browser (Chrome, Firefox, Safari)
- **Certificate Warning**: You may see a security warning (self-signed certificate) - this is expected. Click "Advanced" → "Proceed to site"

### WordPress Administration Panel

Access the admin dashboard:
- **URL**: https://ysbai-jo.42.fr/wp-login
- **Default Credentials**: See the "Managing Credentials" section below

**Admin Features:**
- Create and edit posts/pages
- Manage media uploads
- Install plugins and themes
- Manage users
- Configure site settings

## Managing Credentials

### Locating Credentials

Credentials are stored in two locations:

#### 1. **Secrets Directory** (Secure files)
Located at: `./secrets/`

```
secrets/
├── db_root_password.txt         # Database root password
├── db_user_password.txt         # Database user password
├── wp_admin_password.txt        # WordPress admin password
├── wp_user_password.txt         # WordPress user password
├── ftp_admin_password.txt       # FTP admin password (bonus)
├── ftp_user_password.txt        # FTP user password (bonus)
└── portainer_admin_password.txt # Portainer password (bonus)
```

**Password Generation:**
- Passwords are automatically generated on first run using secure random generation (OpenSSL)
- Each password is 25 characters long with high entropy
- Existing passwords are never overwritten - they're preserved between rebuilds

To view a password:
```bash
cat secrets/db_root_password.txt
```

#### 2. **Environment File** (Configuration)
Located at: `srcs/.env`

```bash
cat srcs/.env
```

Contains:
- Domain name
- Database name
- Usernames (non-sensitive)
- Other configuration options

### User Accounts

The WordPress installation includes two users:

| User Type | Username | Role | Capabilities |
|-----------|----------|------|--------------|
| Administrator | (from .env) | Admin | Full site control |
| Regular User | (from .env) | Editor/Author | Content creation |

### Changing Passwords

#### WordPress Passwords:
1. Log in as administrator
2. Navigate to: Users → All Users
3. Click on username → Edit
4. Scroll to "Account Management"
5. Click "Generate Password" or enter new password
6. Click "Update Profile"

#### Database Passwords:
⚠️ Requires rebuilding containers:

1. Edit secret files:
```bash
nano secrets/db_user_password.txt
nano secrets/db_root_password.txt
```

2. Rebuild and restart:
```bash
make clean  # or make fclean for complete rebuild
make
```

**Note:** Updating secrets requires rebuilding because they're read during container initialization.

## Checking Service Status

### Quick Health Check

1. **Check if containers are running:**
```bash
docker ps
```

Expected output (3 running containers):
```
CONTAINER ID   IMAGE       STATUS          PORTS                   NAMES
abc123def456   nginx       Up 5 minutes    0.0.0.0:443->443/tcp   nginx
def456ghi789   wordpress   Up 5 minutes                           wordpress
ghi789jkl012   mariadb     Up 5 minutes                           mariadb
```

2. **Check website accessibility:**
```bash
curl -k https://ysbai-jo.42.fr
```

Should return HTML content (not error message).

### Detailed Service Checks

#### NGINX Status:
```bash
docker logs nginx
```

✅ **Healthy output:**
```
Server is ready
Nginx started successfully
```

❌ **Problem indicators:**
```
Connection refused
SSL certificate error
Cannot connect to wordpress
```

#### WordPress Status:
```bash
docker logs wordpress
```

✅ **Healthy output:**
```
WordPress installed successfully
PHP-FPM started
```

#### MariaDB Status:
```bash
docker logs mariadb
```

✅ **Healthy output:**
```
MariaDB started successfully
Database initialized
```

### Testing Database Connection

```bash
docker exec -it mariadb sh -c 'mariadb -u root -p$(cat /run/secrets/db_root_password) -e "SHOW DATABASES;"'
```

Should list the WordPress database.

## Common Issues and Solutions

### Issue: "Cannot access website"

**Solution:**
1. Check if containers are running: `docker ps`
2. Verify domain in `/etc/hosts`:
```bash
cat /etc/hosts | grep ysbai-jo.42.fr
```
Should contain: `127.0.0.1 ysbai-jo.42.fr`
3. Restart services: `make re`

### Issue: "Database connection error"

**Solution:**
1. Check MariaDB logs: `docker logs mariadb`
2. Verify database is initialized: Wait 30 seconds after starting
3. Check credentials match in `.env` and secrets

### Issue: "Certificate warning won't go away"

**Explanation:** Self-signed certificates always show warnings. This is normal for development environments.

**To proceed:** Click "Advanced" → "Accept Risk and Continue"

### Issue: "Containers keep restarting"

**Solution:**
1. Check logs for the failing container:
```bash
docker logs <container_name>
```
2. Common causes:
   - Invalid configuration file syntax
   - Missing environment variables
   - Port already in use (443)

## Data Backup

### Backing Up Your Data

#### WordPress Content:
```bash
sudo tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz /home/viktorevo/data/wordpress/
```

#### Database:
```bash
docker exec mariadb sh -c 'mariadb-dump -u root -p$(cat /run/secrets/db_root_password) --all-databases' > database-backup-$(date +%Y%m%d).sql
```

### Restoring Data

#### WordPress Files:
```bash
sudo tar -xzf wordpress-backup-YYYYMMDD.tar.gz -C /home/viktorevo/data/
```

#### Database:
```bash
cat database-backup-YYYYMMDD.sql | docker exec -i mariadb sh -c 'mariadb -u root -p$(cat /run/secrets/db_root_password)'
```

## Maintenance

### Regular Maintenance Tasks

**Weekly:**
- Check disk space: `df -h /home/viktorevo/data/`
- Review logs for errors
- Backup data

**Monthly:**
- Update WordPress core and plugins (via admin panel)
- Clean up old Docker images: `docker system prune`
- Test backup restoration

## Quick Reference

### All Make Commands

| Command | Effect | Data Loss | Use Case |
|---------|--------|-----------|----------|
| `make` or `make up` | Start all services | ✅ No | Normal startup |
| `make down` | Stop services | ✅ No | Temporary shutdown |
| `make ps` | Show container status | ✅ No | Health check |
| `make logs` | View live logs | ✅ No | Debugging |
| `make stats` | Show resource usage | ✅ No | Performance monitoring |
| `make clean` | Stop + remove volumes | ⚠️ Yes (data) | Reset data |
| `make fclean` | Full Docker cleanup | ⚠️ Yes (all) | Fresh rebuild |
| `make clear` | Nuclear reset + restart | ⚠️ Yes (all + host data) | Complete wipe |
| `make re` | Rebuild from scratch | ⚠️ Yes (all) | After config changes |

### Container Names

- **nginx**: Web server and TLS termination
- **wordpress**: PHP-FPM and WordPress application
- **mariadb**: Database server

### Important File Locations

| Item | Location |
|------|----------|
| Environment config | `srcs/.env` |
| Password secrets | `secrets/*.txt` |
| WordPress data | `/home/viktorevo/data/wordpress` |
| Database data | `/home/viktorevo/data/db` |
| Docker compose | `srcs/docker-compose.yml` |

## Support

If you encounter issues:

1. **Check logs** for all containers
2. **Consult** DEV_DOC.md for technical details
3. **Review** configuration files for typos
4. **Restart** services with `make re`

For critical issues, contact the system administrator or refer to the project repository.