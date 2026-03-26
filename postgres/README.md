## Postgres + pgAdmin (Docker Compose)

Runs Postgres 16 plus pgAdmin for browser-based administration.

### Start

```bash
docker compose -f docker-compose.yaml up -d
```

### Stop

```bash
docker compose -f docker-compose.yaml down
```

### Connection info

Postgres:

- **Host**: `localhost`
- **Port**: `5432`
- **User**: `admin`
- **Password**: `admin`
- **Database**: `postgres`

Example:

```bash
psql "postgresql://admin:admin@localhost:5432/postgres"
```

pgAdmin:

- **URL**: `http://localhost:5050`
- **Email**: `admin@admin.com`
- **Password**: `admin123`

When adding a server inside pgAdmin, use:

- **Host name/address**: `postgres` (the compose service name, from within the pgAdmin container)
- **Port**: `5432`
- **Username**: `admin`
- **Password**: `admin`

### Data persistence

Uses the named volume `pgdata` mounted at `/var/lib/postgresql/data`.

### What’s in this folder

- `docker-compose.yaml`: Postgres + pgAdmin
- `pbcopy`: helper file (present in repo)
