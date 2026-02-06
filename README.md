# Inception

*This project has been created as part of the 42 curriculum by VICTORxEVO.*

## Description

Inception is a system administration project that focuses on containerization using Docker. The goal is to build a small-scale infrastructure composed of multiple services, each running in its own Docker container. This project emphasizes understanding Docker architecture, container orchestration with Docker Compose, and implementing security best practices.

The infrastructure consists of:
- **NGINX** web server with TLS encryption (TLSv1.2/1.3)
- **WordPress** CMS with PHP-FPM
- **MariaDB** database
- **Docker networking** for inter-container communication
- **Persistent volumes** for data storage

All services are containerized from scratch using custom Dockerfiles based on Alpine or Debian, without relying on pre-built images from DockerHub.

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
# Copy and edit the environment file
cp srcs/.env.example srcs/.env
nano srcs/.env
```

3. Set up secrets (see DEV_DOC.md for details):
```bash
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
```

4. Configure domain name:
```bash
# Add to /etc/hosts
sudo echo "127.0.0.1 VICTORxEVO.42.fr" >> /etc/hosts
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

Clean everything (containers, images, volumes):
```bash
make fclean
```

Restart services:
```bash
make re
```

### Access
- **WordPress site**: https://ysbai-jo.42.fr
- **WordPress admin**: https://ysbai-jo.42.fr/wp-login

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
- **Volumes** for: WordPress files (`/home/VICTORxEVO/data/wordpress`), MariaDB data (`/home/VICTORxEVO/data/mariadb`)
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
- [Understanding PID 1 in Docker](https://cloud.google.com/architecture/best-practices-for-building-containers)
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

#### **Parts Built Without AI:**

- Docker Compose orchestration logic (manual design)
- Network architecture decisions (based on requirements analysis)
- Volume and data persistence strategy (custom implementation)
- Security implementation (manual certificate generation, secrets management)

**Key Takeaway**: AI served as a productivity tool for repetitive tasks and initial templates, but all final implementations were fully understood, validated, and adapted to meet Inception's specific requirements.

## License

This project is part of the 42 School curriculum. Feel free to reference it for learning purposes.

## Author

**VICTORxEVO** - [GitHub Profile](https://github.com/VICTORxEVO)