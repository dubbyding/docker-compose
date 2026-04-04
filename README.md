## Docker Service Stack (Local)

Comprehensive collection of **local Docker Compose stacks** for common infrastructure and application services. Each service is independent with separate docker-compose files for databases and caches, allowing shared instances across multiple services.

### Prerequisites

- Docker Desktop (or Docker Engine) with `docker compose` available
- macOS/Linux shell
- Sufficient disk space for persistent volumes

### Architecture

**Each service has its own docker-compose.yml containing only that service.** Shared dependencies (databases, caches) are in separate docker-compose files that can be reused:

```
Services:
├── Databases (run once, shared)
│   ├── postgres/
│   ├── mongodb/
│   ├── redis/
│   └── mariadb/
├── Infrastructure
│   ├── kafka/
│   ├── localstack/
│   └── ...
└── Applications (depend on shared DBs)
    ├── appflowy/ (needs postgres + redis)
    ├── nextcloud/ (needs mariadb + redis)
    ├── jellyfin/
    ├── navidrome/
    ├── torrserver/
    ├── adguard/
    └── ...
```

### Quick Start

**Single service** (no dependencies):

```bash
cd jellyfin
docker compose up -d
```

**Service with dependencies** (e.g., AppFlowy):

```bash
# Terminal 1 - Start shared database
cd postgres
docker compose up -d

# Terminal 2 - Start shared cache
cd redis
docker compose up -d

# Terminal 3 - Start application
cd appflowy
docker compose up -d
```

Stop all:

```bash
docker compose down
```

### Services Overview

#### Shared Databases & Caches (run once for multiple services)

| Service | Purpose | Port | Status | For Services |
|---------|---------|------|--------|--------------|
| **PostgreSQL** | Relational DB | 5432 | ✅ | AppFlowy |
| **MongoDB** | NoSQL DB | 27017 | ✅ | Custom apps |
| **MariaDB** | MySQL-compatible DB | 3306 | ✅ | NextCloud, others |
| **Redis** | Cache & sessions | 6379 | ✅ | AppFlowy, NextCloud, others |

#### Applications

| Service | Purpose | Port | Dependencies |
|---------|---------|------|--------------|
| **AdGuard Home** | DNS ad blocker | 53, 3000, 3001 | None |
| **Jellyfin** | Media server | 8096 | None |
| **Navidrome** | Music streaming | 4533 | None |
| **TorrServer** | Torrent streaming | 5665 | None |
| **NextCloud** | File sync & collab | 8080 | MariaDB + Redis |
| **AppFlowy** | Workspace & DB | 5000 | PostgreSQL + Redis |

#### Infrastructure

| Service | Purpose | Port | Status |
|---------|---------|------|--------|
| **Kafka** | Event streaming | 9092 | ✅ |
| **LocalStack** | AWS emulation | 4566 | ✅ |

### Service Details

#### 📦 Standalone Services (no dependencies)
- [**AdGuard Home**](./adguard/README.md) - DNS ad blocker for network-wide blocking
- [**Jellyfin**](./jellyfin/README.md) - Self-hosted media server for movies, TV, music
- [**Navidrome**](./navidrome/README.md) - Lightweight music streaming server
- [**TorrServer**](./torrserver/README.md) - Stream torrents directly without full download

#### 🗄️ Databases (shared across services)
- [**PostgreSQL**](./postgres/README.md) - Relational database with pgAdmin
- [**MongoDB**](./mongodb/README.md) - NoSQL document database
- [**MariaDB**](./mariadb/README.md) - MySQL-compatible relational database
- [**Redis**](./redis/README.md) - In-memory cache with persistence

#### 🚀 Applications (require databases)
- [**AppFlowy**](./appflowy/README.md) - Workspace tool (needs PostgreSQL + Redis)
- [**NextCloud**](./nextcloud/README.md) - File sync & collaboration (needs MariaDB + Redis)

#### 🔧 Infrastructure
- [**Kafka**](./kafka/README.md) - Event streaming with KRaft mode
- [**LocalStack**](./localstack/README.md) - Local AWS services emulation

### Dependency Matrix

Which services need what:

```
AppFlowy
├── PostgreSQL 15+  (../postgres)
└── Redis 7+        (../redis)

NextCloud
├── MariaDB 11+     (../mariadb or existing MySQL)
└── Redis 7+        (../redis)

Jellyfin, Navidrome, TorrServer, AdGuard
└── No dependencies (run standalone)

Kafka, LocalStack
└── No dependencies (run standalone)
```

### Shared Database Pattern

**Home Server Setup Example:**

One database instance serves multiple services:

```bash
# Start shared services (once)
cd postgres && docker compose up -d
cd redis && docker compose up -d
cd mariadb && docker compose up -d

# Start applications (they all use shared instances)
cd appflowy && docker compose up -d
cd nextcloud && docker compose up -d
cd other-app && docker compose up -d
```

**Benefits:**
- Lower memory/storage overhead
- Single backup point for multiple services
- Easier maintenance
- No port conflicts from multiple DB instances

### Port Reference

| Port(s) | Service |
|---------|---------|
| 53 | AdGuard Home (DNS) |
| 80, 443 | NextCloud (if exposed) |
| 3000, 3001 | AdGuard Home (UI) |
| 3306 | MariaDB |
| 4533 | Navidrome |
| 4566 | LocalStack |
| 5000 | AppFlowy |
| 5050 | pgAdmin (PostgreSQL) |
| 5432 | PostgreSQL |
| 5665 | TorrServer |
| 6379 | Redis |
| 8080 | NextCloud |
| 8096 | Jellyfin |
| 9092 | Kafka |
| 27017 | MongoDB |

### Directory Structure

```
.
├── postgres/          # PostgreSQL (shared DB)
│   ├── docker-compose.yaml
│   └── README.md
├── mongodb/           # MongoDB (shared DB)
│   ├── docker-compose.yml
│   └── README.md
├── mariadb/           # MariaDB (shared DB)
│   ├── docker-compose.yml
│   └── README.md
├── redis/             # Redis (shared cache)
│   ├── docker-compose.yml
│   └── README.md
├── appflowy/          # Workspace (uses postgres + redis)
│   ├── docker-compose.yml
│   └── README.md
├── nextcloud/         # File sync (uses mariadb + redis)
│   ├── docker-compose.yml
│   └── README.md
├── jellyfin/          # Media server (standalone)
│   ├── docker-compose.yml
│   └── README.md
├── navidrome/         # Music server (standalone)
│   ├── docker-compose.yaml
│   └── README.md
├── torrserver/        # Torrent streaming (standalone)
│   ├── docker-compose.yaml
│   └── README.md
├── adguard/           # DNS blocker (standalone)
│   ├── docker-compose.yaml
│   └── README.md
├── kafka/             # Event streaming
│   ├── kafka-docker-compose.yml
│   └── README.md
├── localstack/        # AWS emulation
│   ├── docker-compose.yml
│   └── README.md
└── README.md          # This file
```

### Usage Patterns

#### Pattern 1: Start Single Standalone Service

```bash
cd jellyfin
docker compose up -d
# Accessible at http://localhost:8096
```

#### Pattern 2: Start Application with Shared Database

```bash
# Check if shared services are running
docker ps | grep postgres
docker ps | grep redis

# If not running, start them (once per home server)
cd postgres && docker compose up -d
cd redis && docker compose up -d

# Start application (uses existing postgres + redis)
cd appflowy && docker compose up -d
```

#### Pattern 3: Multiple Applications Sharing Same Database

```bash
# Start shared services (once)
cd mariadb && docker compose up -d
cd redis && docker compose up -d

# Start multiple applications using same DB+cache
cd nextcloud && docker compose up -d
cd myapp1 && docker compose up -d
cd myapp2 && docker compose up -d

# All three apps share one MariaDB and one Redis instance
```

### Persistence & Backups

#### Volume Locations

Each service persists data in its own directory:
- `postgres/`: PostgreSQL data
- `mongodb/`: MongoDB data
- `mariadb/`: MariaDB data
- `redis/`: Redis persistence
- `jellyfin/`: Media server config + cache
- `appflowy/`: Application data
- `nextcloud/`: Cloud files + config

#### Backup Important Databases

```bash
# PostgreSQL
docker exec postgres pg_dump -U postgres postgres > backup.sql

# MariaDB
docker exec mariadb mysqldump -u root -proot > backup.sql

# MongoDB
docker exec mongodb mongodump --out /backup
```

### Troubleshooting

#### Service won't connect to database

**Check 1:** Verify database is running
```bash
docker ps | grep <database-name>
```

**Check 2:** Verify hostname in connection string
- Localhost: `localhost:5432` (for services on host)
- Docker network: `postgres:5432` (for containers on same network)

**Check 3:** Check logs
```bash
cd <database> && docker compose logs -f
```

#### Port conflict

```bash
# Find what's using the port
lsof -i :<port>

# Change port in docker-compose.yml or stop conflicting service
```

#### Volume issues

```bash
# List volumes
docker volume ls

# Check disk space
docker system df

# Inspect specific volume
docker volume inspect <volume-name>
```

#### Network connectivity between services

Services on the same Docker network can connect using service name:
```yaml
environment:
  DATABASE_URL: postgres://user:pass@postgres:5432/db
```

Services accessing from host use localhost:
```yaml
environment:
  DATABASE_URL: postgres://user:pass@localhost:5432/db
```

### Security & Defaults

⚠️ **Important**:

- **Credentials are hard-coded** for local development only
- Services bind to `localhost` or `127.0.0.1` for safety
- Never expose these stacks to the internet without proper security
- Change default credentials for production use
- Use environment variables or `.env` files for sensitive data
- Each service's README includes security notes

### Tips & Best Practices

1. **Start shared services once** - PostgreSQL, Redis, MariaDB don't need to restart
2. **Check running services** - `docker ps` to see what's already running
3. **Use `.env` files** - Keep credentials out of docker-compose.yml
4. **Separate compose files** - Each service is independent, easy to manage
5. **Monitor resources** - `docker stats` to check memory/CPU usage
6. **Regular backups** - Backup important databases regularly
7. **Keep images updated** - `docker pull` and `docker compose pull`
8. **Use bind mounts** - Easier to access and backup data

### Next Steps

1. **For home server setup:**
   - Start shared services: PostgreSQL, Redis, MariaDB
   - Then start applications that need them
   - Other standalone services can run anytime

2. **For single service:**
   - Navigate to service folder
   - Check README for setup
   - Run `docker compose up -d`

3. **For new services:**
   - Read the service's `README.md` first
   - Check if it needs a database
   - Start database first if needed
   - Then start the service

### Contributing

To add a new service:
1. Create directory: `mkdir my-service`
2. Add `docker-compose.yml` with ONE service
3. If it needs a DB, document which one and how to connect
4. Create comprehensive `README.md`
5. Update this main `README.md`

### Environment Configuration

Most services support `.env` files for easy configuration:

```bash
# Create .env in service directory
cd nextcloud
cat > .env << EOF
MYSQL_ROOT_PASSWORD=secure_password
MYSQL_USER=nextcloud
MYSQL_PASSWORD=nextcloud_pass
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=admin_pass
NEXTCLOUD_DOMAIN=localhost
TZ=UTC
EOF

docker compose up -d
```

---

**Last updated**: April 2026 | **Architecture**: Single-service compose files + shared dependencies
