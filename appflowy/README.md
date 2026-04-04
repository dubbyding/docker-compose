## AppFlowy (Docker Compose)

Open-source workspace with AI-integrated document and database tools.

### Prerequisites

AppFlowy requires:
- **PostgreSQL 15+** - Run from `../postgres/`
- **Redis 7+** - Run from `../redis/`

### Start Services

Run the required services first (from separate directories):

```bash
# Terminal 1 - Start PostgreSQL
cd ../postgres
docker compose up -d

# Terminal 2 - Start Redis
cd ../redis
docker compose up -d

# Terminal 3 - Start AppFlowy
cd ../appflowy
docker compose up -d
```

### Stop Services

```bash
# Stop AppFlowy
docker compose down

# Stop Redis (from ../redis)
cd ../redis && docker compose down

# Stop PostgreSQL (from ../postgres)
cd ../postgres && docker compose down
```

### Access

- **Web UI**: http://localhost:5000

### Configuration

#### AppFlowy Environment Variables
Edit the `docker-compose.yml` to customize:
- `RUST_LOG`: Logging level (`info`, `debug`, `warn`, `error`)
- `DATABASE_URL`: PostgreSQL connection string
  - Default: `postgres://appflowy:appflowy@localhost:5432/appflowy`
  - Change `localhost` if PostgreSQL runs on different host
- `REDIS_URL`: Redis connection string
  - Default: `redis://localhost:6379`
  - Change `localhost` if Redis runs on different host
- `ENVIRONMENT`: Deployment environment (`production`, `development`)

#### PostgreSQL Setup

Ensure PostgreSQL has the `appflowy` database and user created:

```bash
# Connect to PostgreSQL from postgres container
docker exec -it postgres psql -U postgres

# Inside psql:
CREATE DATABASE appflowy;
CREATE USER appflowy WITH PASSWORD 'appflowy';
GRANT ALL PRIVILEGES ON DATABASE appflowy TO appflowy;
\q
```

Or add initialization script to PostgreSQL (see `../postgres/README.md`).

#### Redis Setup

Redis from `../redis/` requires no additional configuration for AppFlowy.

### Connection Info

- **AppFlowy Web**: http://localhost:5000
- **PostgreSQL**: `localhost:5432` (default credentials in `../postgres/.env`)
- **Redis**: `localhost:6379` (default connection in `../redis/`)

### First-time Setup

1. Ensure PostgreSQL and Redis are running
2. Start AppFlowy: `docker compose up -d`
3. Open http://localhost:5000
4. Create account or sign in
5. Create your first workspace
6. Start building documents, databases, and automations

### Volumes

- `./data/`: AppFlowy application data and cache

### Networking

AppFlowy connects to PostgreSQL and Redis via `localhost` (host network mode).

### Multi-host Setup

If PostgreSQL or Redis run on different servers:

Update `docker-compose.yml` environment variables:

```yaml
environment:
  DATABASE_URL: postgres://appflowy:appflowy@192.168.1.100:5432/appflowy
  REDIS_URL: redis://192.168.1.101:6379
```

### Customization

#### Change port
Edit docker-compose.yml:
```yaml
ports:
  - "8080:5000"  # Access at http://localhost:8080
```

#### Enable debug logging
```yaml
environment:
  RUST_LOG: debug
```

#### Custom PostgreSQL credentials
Update DATABASE_URL to match your setup:
```yaml
DATABASE_URL: postgres://custom_user:custom_pass@localhost:5432/appflowy_db
```

### Troubleshooting

#### Connection refused to PostgreSQL
- Verify PostgreSQL is running: `docker ps | grep postgres`
- Check PostgreSQL logs: `cd ../postgres && docker compose logs`
- Verify database and user exist in PostgreSQL
- Test connection: `docker exec postgres psql -U appflowy -d appflowy -h localhost`

#### Connection refused to Redis
- Verify Redis is running: `docker ps | grep redis`
- Check Redis logs: `cd ../redis && docker compose logs`
- Test connection: `docker exec redis redis-cli ping`

#### AppFlowy won't start
- Check logs: `docker compose logs -f appflowy`
- Verify DATABASE_URL and REDIS_URL are correct
- Ensure PostgreSQL database exists
- Check network connectivity to dependent services

#### Shared database already has data
- You can share the same PostgreSQL instance across multiple AppFlowy instances
- Just ensure each has a unique database name (change `appflowy` in DATABASE_URL)

### Cleanup

```bash
# Remove AppFlowy container and volume
docker compose down -v

# Keep data, just stop container
docker compose down
```

### What's in this folder

- `docker-compose.yml`: AppFlowy service only
- `README.md`: This documentation
- `data/`: AppFlowy application data (persisted after container stops)

### See Also

- [PostgreSQL Setup](../postgres/README.md)
- [Redis Setup](../redis/README.md)
- [Docker Service Stack](../README.md)
