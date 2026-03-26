## Redis (Docker Compose)

Runs Redis with AOF persistence and a required password.

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Connection info

- **Host**: `localhost`
- **Port**: `6379`
- **Password**: `redis_password` (set via compose `--requirepass`)

Example:

```bash
redis-cli -h localhost -p 6379 -a redis_password PING
```

### What’s in this folder

- `docker-compose.yml`: Redis container + named volume `redis-data`
