# Inception

*This project has been created as part of the 42 curriculum by ysbai-jo.*

## Project Description

Inception is a 42 system-administration project that builds a small production-like web infrastructure entirely with **Docker** and **Docker Compose**. Every service runs in its own container, built from scratch using custom `Dockerfile`s based on Alpine or Debian — no pre-built DockerHub images.

### Services (sources)

| Container | Role |
|-----------|------|
| `nginx` | Reverse proxy + TLS termination (TLSv1.2/1.3, port 443) |
| `wordpress` | CMS + PHP-FPM (no Apache) |
| `mariadb` | Relational database |
| `redis` | Object cache for WordPress |
| `ftp` | FTP access to the WordPress volume |
| `adminer` | Browser-based DB admin (port 8080) |
| `portainer` | Docker management UI (port 9443) |
| `apache` | Static demo site (port 8888) |

### Main Design Choices

- **Single entry point** — only NGINX is exposed externally; all other services communicate over isolated internal networks.
- **Secrets over env vars** — credentials are mounted via Docker secrets (`secrets/*.txt`), never stored in `.env` or images.
- **Bind-mount volumes** — data directories live on the host under `/home/ysbai-jo/data/` for transparent backup and recovery.
- **Minimal images** — each Dockerfile installs only what the service needs; processes run directly (`CMD`/`ENTRYPOINT`), not wrapped in a shell loop.

### Key Comparisons

#### Virtual Machines vs Docker

| | VM | Docker |
|--|----|----|
| Overhead | Full guest OS | Shares host kernel |
| Boot time | Minutes | Seconds |
| Isolation | Hardware-level | Process/namespace-level |
| Portability | Large disk images | Lightweight layers |

**Choice:** Docker is sufficient for this web stack, faster to iterate, and far lighter on resources.

#### Secrets vs Environment Variables

| | Secrets | Env Vars |
|--|--------|---------|
| Storage | Files mounted in-memory (`/run/secrets/`) | `.env` / shell exports |
| Visibility | Only to the target container | All child processes, `docker inspect` |
| Risk | Low — not embedded in image | High if committed or leaked |

**Choice:** Passwords (DB, FTP, WordPress) use Docker secrets; non-sensitive config (domain, usernames) uses `.env`.

#### Docker Network vs Host Network

| | Docker (bridge) | Host |
|--|-----------------|------|
| Isolation | Own network namespace | Shares host stack |
| Service discovery | By container name | By port only |
| Security | Controlled ingress/egress | Full host exposure |

**Choice:** Custom bridge networks (`external_net`, `wp_net`, `db_net`, `cache_net`) limit blast radius and enable clean DNS-based routing.

#### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|--|---------------|-------------|
| Managed by | Docker daemon | User (host path) |
| Portability | Platform-independent | Host-path dependent |
| Transparency | Opaque to host | Directly visible/editable |

**Choice:** Bind mounts are used for `db_data` and `wp_data` so data is directly accessible on the host for backup and debugging.

## Instructions

### Prerequisites
- Virtual Machine (recommended: VirtualBox or VMware)
- Docker Engine (20.10+)
- Docker Compose (v2.0+)
- Make
- Sufficient disk space (~2GB for images and volumes)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Configure your environment:
```bash
# create env file with default values
make env
vim srcs/.env     # change default values
```

3. Set up secrets (see DEV_DOC.md for details):
```bash
make secrets
```

4. Configure domain name:
```bash
# Add to /etc/hosts
sudo echo "127.0.0.1 ysbai-jo.42.fr" >> /etc/hosts
```

### Execution

Build and start all services:
```bash
make
```

Stop all services:
```bash
make down
```

Clean (containers, images, volumes):
```bash
make clean
```

Restart services:
```bash
make re
```

Clear everthing (docker volume) and rebuild
```bash
make clear
```

### Access
- **WordPress site**: https://ysbai-jo.42.fr
- **WordPress admin**: https://ysbai-jo.42.fr/wp-admin

## Project Architecture

### Design Choices

This project implements a three-tier web application architecture:

1. **Presentation Layer** (NGINX)
   - Acts as reverse proxy and TLS termination point
   - Only service exposed to external network (port 443)
   - Handles HTTPS connections and forwards to WordPress

2. **Application Layer** (WordPress + PHP-FPM)
   - Processes dynamic content
   - Communicates with database layer
   - Isolated from direct external access

3. **Data Layer** (MariaDB)
   - Persistent data storage
   - Accessible only from application layer
   - Data preserved using Docker volumes

### Key Comparisons

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|-----------------|-------------------|
| **Resource Usage** | Heavy - includes full OS | Lightweight - shares host kernel |
| **Boot Time** | Minutes | Seconds |
| **Isolation** | Complete hardware virtualization | Process-level isolation |
| **Portability** | Limited (large VM images) | High (small container images) |
| **Use Case** | Full OS simulation, strong isolation | Microservices, rapid deployment |

**Project Choice**: Docker provides sufficient isolation for this web stack while maintaining efficiency and rapid deployment capabilities.

#### Secrets vs Environment Variables

| Aspect | Secrets | Environment Variables |
|--------|---------|----------------------|
| **Security** | Encrypted, access-controlled | Plain text, visible in process list |
| **Storage** | Secure store (Docker secrets, files) | .env files, shell exports |
| **Visibility** | Limited to authorized containers | Available to all child processes |
| **Best For** | Passwords, API keys, certificates | Configuration, non-sensitive data |

**Project Implementation**: 
- Secrets for: database passwords, credentials
- Environment variables for: domain names, usernames, configuration options

#### Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|---------------|--------------|
| **Isolation** | Network namespace per container | Shares host network stack |
| **Port Mapping** | Required, flexible | Direct access to host ports |
| **Security** | Better isolation | Exposed to host network threats |
| **Performance** | Slight overhead | No network overhead |

**Project Choice**: Custom bridge network (`inception-network`) provides:
- Service discovery by container name
- Network isolation from host
- Controlled inter-container communication

#### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|---------------|-------------|
| **Management** | Managed by Docker | User manages host path |
| **Portability** | Platform-independent | Host-path dependent |
| **Performance** | Optimized by Docker | Direct filesystem access |
| **Backup** | Docker volume commands | Standard filesystem tools |

**Project Implementation**:
- **Volumes** for: WordPress files (`/home/ysbai-jo/data/wordpress`), MariaDB data (`/home/ysbai-jo/data/mariadb`)
- Ensures data persistence across container lifecycles
- Easy backup and migration

### Docker Sources and Components

The project consists of custom-built Docker images:

```
srcs/
├── docker-compose.yml          # Orchestration configuration
├── .env                         # Environment variables
└── requirements/
    ├── nginx/
    │   ├── Dockerfile          # Alpine/Debian + NGINX + SSL
    │   ├── conf/               # NGINX configuration
    │   └── tools/              # Setup scripts
    ├── wordpress/
    │   ├── Dockerfile          # Alpine/Debian + PHP-FPM + WordPress
    │   ├── conf/               # PHP configuration
    │   └── tools/              # WP-CLI setup scripts
    └── mariadb/
        ├── Dockerfile          # Alpine/Debian + MariaDB
        ├── conf/               # Database configuration
        └── tools/              # Init scripts
```

Each Dockerfile:
- Uses Alpine or Debian base (penultimate stable)
- Installs only necessary packages
- Runs as non-root where possible
- Uses PID 1 best practices (no infinite loops)
- Implements health checks

## Resources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Documentation](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

### Tutorials & Articles
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [SSL/TLS Configuration](https://ssl-config.mozilla.org/)
- [WP-CLI Documentation](https://wp-cli.org/)

### AI Usage in This Project

AI tools were utilized to enhance productivity and learning, while ensuring full understanding of all implemented solutions:

#### **Tasks Where AI Was Used:**

1. **Dockerfile Optimization**
   - Prompt refinement for multi-stage builds
   - Best practices for layer caching
   - Security vulnerability scanning suggestions

2. **Configuration File Generation**
   - NGINX SSL/TLS configuration templates
   - PHP-FPM pool configuration
   - MariaDB optimization parameters

3. **Shell Script Development**
   - WordPress automated setup scripts
   - Database initialization scripts
   - Health check implementations

4. **Documentation**
   - Markdown formatting and structure
   - Technical comparison tables
   - Command reference sections

#### **Validation Process:**

All AI-generated content was:
- ✅ Reviewed line-by-line for understanding
- ✅ Tested in isolated environments
- ✅ Discussed with peers during development
- ✅ Modified based on project-specific requirements
- ✅ Documented with comments explaining logic


## License

This project is part of the 42 School curriculum. Feel free to reference it for learning purposes.

## Author

**yassir sbai** - [GitHub Profile](https://github.com/VICTORxEVO)