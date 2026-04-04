## AdGuard Home (Docker Compose)

DNS ad blocker and privacy protection tool running in a Docker container.

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Access

- **Initial setup UI**: http://localhost:3000
- **Dashboard (after setup)**: http://localhost:3001

### Configuration

#### DNS Settings
- **DNS Port**: 53 (TCP/UDP)
- Configure your router or device to use `localhost` as the DNS server

#### Volumes
- `./adguard/conf/`: Configuration files (persisted)
- `./adguard/work/`: Working data, logs, and cache

### Connection info

- **Host**: `localhost`
- **DNS Port**: `53`
- **Admin UI Port**: `3001`

### First-time setup

1. Open http://localhost:3000
2. Follow the setup wizard
3. Set admin credentials
4. Configure filtering rules and blocklists
5. Access dashboard at http://localhost:3001

### What's in this folder

- `docker-compose.yaml`: AdGuard Home service with DNS and admin ports
