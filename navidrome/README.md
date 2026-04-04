## Navidrome (Docker Compose)

Lightweight music streaming server with music library management and transcoding.

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Access

- **Web UI**: http://localhost:4533

### Configuration

#### Environment Variables
- `ND_SCANSCHEDULE`: Music library scan interval (default: `1h`)
- `ND_LOGLEVEL`: Log level - `info`, `debug`, `warn`, `error` (default: `info`)
- `ND_SESSIONTIMEOUT`: Session timeout duration (default: `24h`)
- `ND_BASEURL`: Base URL for reverse proxy setup (default: empty)

#### Volumes
- `./data/`: Database and user data
- `/path/to/your/music`: Your music library (mounted as read-only)

### Connection info

- **Host**: `localhost`
- **Web Port**: `4533`
- **User**: `1000:1000` (non-root)

### First-time setup

1. Open http://localhost:4533
2. Create admin account
3. Configure music library path in settings
4. Adjust scan schedule and other preferences

### Adding music

1. Mount your music folder in the docker-compose.yml:
   ```yaml
   volumes:
     - ./data:/data
     - /path/to/your/music:/music:ro
   ```

2. Configure the music folder in Navidrome settings
3. Trigger a library scan or wait for scheduled scan

### Music Format Support

- MP3, FLAC, OGG, M4A, WAV, and more
- Automatic transcoding for bandwidth optimization

### What's in this folder

- `docker-compose.yaml`: Navidrome service with volume mounts
