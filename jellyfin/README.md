## Jellyfin (Docker Compose)

Free and open-source media server for streaming movies, TV shows, music, and photos.

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Access

- **Web UI**: http://localhost:8096

### Configuration

#### Environment Variables (set in `.env`)
- `PUID`: User ID (default: 1000)
- `PGID`: Group ID (default: 1000)
- `TZ`: Timezone (e.g., `America/New_York`)
- `JELLYFIN_URL`: Published server URL for remote access

#### Volumes
- `./config/`: Configuration and metadata
- `./cache/`: Cache files
- `./media/`: Media library (movies, shows, music, photos)

### Connection info

- **Host**: `localhost`
- **Web Port**: `8096`
- **Bind Address**: `127.0.0.1` (local only)

### First-time setup

1. Open http://localhost:8096
2. Follow the setup wizard
3. Add media libraries pointing to `./media` folder
4. Configure playback and streaming settings

### Adding media

Place your media files in `./media/` directory:
```
./media/
├── Movies/
├── TV Shows/
├── Music/
└── Photos/
```

### What's in this folder

- `docker-compose.yml`: Jellyfin service with volume mounts
- `.env`: Environment configuration (user ID, timezone, URL)
