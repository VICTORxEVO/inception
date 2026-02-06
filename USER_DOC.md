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
- **WordPress Files**: Located at `/home/ysbai-jo/data/wordpress`
- **Database Files**: Located at `/home/ysbai-jo/data/mariadb`

## Getting Started

### Starting the Project

1. Open a terminal in the project directory
2. Run the startup command:

```bash
make
```

**What happens:**
- Docker images are built (first time only - may take 5-10 minutes)
- Containers are created and started
- Services perform initialization (database creation, WordPress setup)
- System becomes available at https://ysbai-jo.42.fr

**Expected output:**
```
Building mariadb...
Building wordpress...
Building nginx...
Creating inception_mariadb_1...
Creating inception_wordpress_1...
Creating inception_nginx_1...
```

### Stopping the Project

To stop all services while preserving data:

```bash
make down
```

**What happens:**
- All containers are stopped gracefully
- Data in volumes is preserved
- Network is removed
- Next startup will be faster (images already built)

### Restarting the Project

To stop and start fresh:

```bash
make re
```

**Use this when:**
- Configuration changes were made
- Issues require a clean restart
- Environment variables were modified

### Complete Reset

To remove everything and start from scratch:

```bash
make fclean
```

⚠️ **WARNING**: This command will:
- Stop all containers
- Delete all Docker images
- Remove all volumes (⚠️ **ALL DATA WILL BE LOST**)
- Clean the build cache

Use this only when you want to completely rebuild the project.

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
├── credentials.txt          # WordPress user credentials
├── db_password.txt          # Database user password
└── db_root_password.txt     # Database root password
```

To view:
```bash
cat secrets/credentials.txt
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
nano secrets/db_password.txt
nano secrets/db_root_password.txt
```

2. Update `.env` file if necessary:
```bash
nano srcs/.env
```

3. Rebuild and restart:
```bash
make fclean
make
```

## Checking Service Status

### Quick Health Check

1. **Check if containers are running:**
```bash
docker ps
```

Expected output (3 running containers):
```
CONTAINER ID   IMAGE       STATUS          PORTS                   NAMES
abc123def456   nginx       Up 5 minutes    0.0.0.0:443->443/tcp   inception_nginx_1
def456ghi789   wordpress   Up 5 minutes                           inception_wordpress_1
ghi789jkl012   mariadb     Up 5 minutes                           inception_mariadb_1
```

2. **Check website accessibility:**
```bash
curl -k https://ysbai-jo.42.fr
```

Should return HTML content (not error message).

### Detailed Service Checks

#### NGINX Status:
```bash
docker logs inception_nginx_1
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
docker logs inception_wordpress_1
```

✅ **Healthy output:**
```
WordPress installed successfully
PHP-FPM started
```

#### MariaDB Status:
```bash
docker logs inception_mariadb_1
```

✅ **Healthy output:**
```
MariaDB started successfully
Database initialized
```

### Testing Database Connection

```bash
docker exec inception_mariadb_1 mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW DATABASES;"
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
3. Restart services: `make re`

### Issue: "Database connection error"

**Solution:**
1. Check MariaDB logs: `docker logs inception_mariadb_1`
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
sudo tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz /home/ysbai-jo/data/wordpress/
```

#### Database:
```bash
docker exec inception_mariadb_1 mysqldump -u root -p$(cat secrets/db_root_password.txt) --all-databases > database-backup-$(date +%Y%m%d).sql
```

### Restoring Data

#### WordPress Files:
```bash
sudo tar -xzf wordpress-backup-YYYYMMDD.tar.gz -C /home/ysbai-jo/data/
```

#### Database:
```bash
cat database-backup-YYYYMMDD.sql | docker exec -i inception_mariadb_1 mysql -u root -p$(cat secrets/db_root_password.txt)
```

## Maintenance

### Regular Maintenance Tasks

**Weekly:**
- Check disk space: `df -h /home/ysbai-jo/data/`
- Review logs for errors
- Backup data

**Monthly:**
- Update WordPress core and plugins (via admin panel)
- Clean up old Docker images: `docker system prune`
- Test backup restoration

## Support

If you encounter issues:

1. **Check logs** for all containers
2. **Consult** DEV_DOC.md for technical details
3. **Review** configuration files for typos
4. **Restart** services with `make re`

For critical issues, contact the system administrator or refer to the project repository.