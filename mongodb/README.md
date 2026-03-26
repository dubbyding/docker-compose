## MongoDB (Docker Compose)

Runs a single MongoDB container with an initialized root user.

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
- **Port**: `27017`
- **Root user**: `admin`
- **Root password**: `secret123`

Connect with `mongosh`:

```bash
mongosh "mongodb://admin:secret123@localhost:27017/admin"
```

### Data persistence

Uses the named volume `mongo_data` mounted at `/data/db`.

### What’s in this folder

- `docker-compose.yml`: MongoDB container + named volume
