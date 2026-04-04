## NextCloud (Docker Compose)

Self-hosted file sync, calendar, contacts, and collaboration platform.

### Prerequisites

NextCloud requires:
- **MariaDB 11** or **MySQL 8+** - Create a dedicated MariaDB setup or use existing database
- **Redis 7+** - Run from `../redis/`

### Start Services

Run the required services first (in separate directories):

```bash
# Terminal 1 - Start MariaDB (if not already running)
# Option A: Create a dedicated MariaDB instance
mkdir -p ../mariadb/data
cd ../mariadb
docker compose up -d

# Option B: Use existing PostgreSQL and create database
# (if sharing a database server)

# Terminal 2 - Start Redis
cd ../redis
docker compose up -d

# Terminal 3 - Start NextCloud
cd ../nextcloud
docker compose up -d
```

### Stop Services

```bash
# Stop NextCloud
docker compose down

# Stop Redis (from ../redis)
cd ../redis && docker compose down

# Stop MariaDB (from ../mariadb or wherever you run it)
cd ../mariadb && docker compose down
```

### Access

- **Web UI**: http://localhost:8080

### Configuration

#### Environment Variables (create `.env` file)

```env
# MariaDB connection
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=secure_password_here
MYSQL_ROOT_PASSWORD=secure_root_password

# NextCloud admin
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=secure_admin_password

# Domain/host configuration
NEXTCLOUD_DOMAIN=localhost
TZ=UTC
```

#### Database Setup

**Option 1: Dedicated MariaDB Instance**

Create `../mariadb/docker-compose.yml`:
```yaml
services:
  mariadb:
    image: mariadb:11
    container_name: mariadb
    restart: unless-stopped
    ports:
      - "3306:3306"
    volumes:
      - ./data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
```

**Option 2: Shared Database**

If you have an existing MariaDB/MySQL instance:
- Update `docker-compose.yml` with correct `MYSQL_HOST`
- Ensure NextCloud database and user exist:
  ```bash
  mysql -u root -p -h <db-host>
  CREATE DATABASE nextcloud;
  CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'password';
  GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';
  FLUSH PRIVILEGES;
  ```

#### Redis Setup

Redis from `../redis/` requires no additional configuration.

### Connection Info

- **NextCloud Web**: http://localhost:8080
- **MySQL/MariaDB**: `localhost:3306` (default from `.env`)
- **Redis**: `localhost:6379` (default connection)

### First-time Setup

1. Ensure MariaDB and Redis are running
2. Create `.env` file with database credentials
3. Start NextCloud: `docker compose up -d`
4. Open http://localhost:8080
5. Enter admin credentials from `.env`
6. NextCloud will initialize the database automatically

### Volumes

- `./data/`: NextCloud files, config, and user data

### Networking

NextCloud connects to MariaDB and Redis via `localhost` (host network mode).

### Multi-host Setup

If MariaDB or Redis run on different servers, update `docker-compose.yml`:

```yaml
environment:
  MYSQL_HOST: 192.168.1.100
  REDIS_HOST: 192.168.1.101
```

### Features

- **File Sync**: Sync files across devices
- **Calendar**: CalDAV-compatible calendar
- **Contacts**: CardDAV-compatible contacts
- **Sharing**: Share files and folders with permissions
- **Versions**: File versioning and recovery
- **Apps**: Extend with optional apps
- **Mobile Apps**: iOS and Android clients
- **Encryption**: End-to-end encryption support

### User Management

#### Create users (in admin panel)
1. Go to Settings → Users
2. Click "New user"
3. Set username and password
4. Assign groups and quotas

#### Set user quotas
- Storage limits per user
- Monitor usage from admin panel

### Performance Optimization

- Redis caching enabled for:
  - Session data
  - Database queries
  - File locking
  - Real-time collaboration
- Configure cache size in admin settings

### Security

**Important for production**:
- Use HTTPS via reverse proxy (nginx, traefik)
- Change default credentials immediately
- Enable two-factor authentication
- Configure firewall rules
- Regular backups recommended
- Use strong database password

### Maintenance

#### Update NextCloud
```bash
docker compose pull
docker compose up -d
```

#### Backup

```bash
# Backup NextCloud data
docker run --rm -v nextcloud_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/nextcloud-backup.tar.gz -C /data .

# Backup MariaDB database
docker exec mariadb mysqldump -u root \
  -p<MYSQL_ROOT_PASSWORD> <MYSQL_DATABASE> > nextcloud-db-backup.sql
```

#### Database maintenance
```bash
docker exec mariadb mysql -u root \
  -p<MYSQL_ROOT_PASSWORD> nextcloud \
  -e "OPTIMIZE TABLE oc_*;"
```

### Shared Database Benefits

When sharing MariaDB across multiple services:
- Single database instance for multiple apps
- Reduced memory and storage overhead
- Easier backups and maintenance
- Better resource utilization on home server

Example with multiple services:
```
MariaDB (single instance)
├── nextcloud (database: nextcloud)
├── other_app (database: other_app)
└── another_app (database: another_app)

Redis (single instance)
├── nextcloud
└── other_app
```

### Troubleshooting

#### Database connection error
- Verify `.env` variables match docker-compose.yml
- Test connection: `docker exec mariadb mysql -u root -p -h localhost`
- Check MariaDB is running: `docker ps | grep mariadb`
- Review logs: `docker compose logs nextcloud`

#### File permissions
- Check data folder ownership
- NextCloud runs as www-data user

#### Slow performance
- Verify Redis is running and connected
- Check database: `docker compose logs`
- Monitor resources: `docker stats`

#### Trust domain issues
- Update `NEXTCLOUD_DOMAIN` in `.env`
- Restart: `docker compose restart nextcloud`
- Check admin settings for trusted domains

### Advanced Configuration

#### SMTP Email
- Admin Settings → Basic Settings → Email server
- Configure mail server for notifications

#### LDAP/AD Integration
- Install LDAP app from app store
- Configure directory server connection
- Sync users from directory

#### S3 Object Storage
- Install External Storage app
- Configure S3 backend (LocalStack or AWS S3)
- Move data to object storage

### What's in this folder

- `docker-compose.yml`: NextCloud service only
- `README.md`: This documentation
- `.env`: Configuration (create with your values)
- `data/`: NextCloud files and configuration (persisted)

### See Also

- [Redis Setup](../redis/README.md)
- [MariaDB Setup](../mariadb/README.md) (create if needed)
- [Docker Service Stack](../README.md)
