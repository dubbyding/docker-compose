## TorrServer (Docker Compose)

Torrent streaming server that allows playing torrent content directly without full download.

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Access

- **Web UI**: http://localhost:5665

### Configuration

#### Environment Variables
- `TS_PORT`: Server port (default: `5665`)
- `TS_DONTKILL`: Keep torrents alive after playback (default: `1`)
- `TS_HTTPAUTH`: HTTP authentication (default: `0` - disabled)
- `TS_CONF_PATH`: Configuration directory (default: `/opt/ts/config`)
- `TS_TORR_DIR`: Torrent cache directory (default: `/opt/ts/torrents`)

#### Volumes
- `./CACHE/`: Torrent cache and download directory
- `./CONFIG/`: Application configuration and database

### Connection info

- **Host**: `localhost`
- **Web Port**: `5665`

### First-time setup

1. Open http://localhost:5665
2. Configure preferred settings (bitrate, cache size, etc.)
3. Add torrent magnet links or torrent files
4. Stream content directly or download for later playback

### Usage

- **Stream torrents**: Add magnet link or torrent file URL
- **Choose content**: Select specific files or episodes to stream
- **Play**: Use web player or compatible media player

### Cache Management

- Cached torrents stored in `./CACHE/`
- Clear cache manually if needed to free disk space
- Configure cache size limit in settings

### What's in this folder

- `docker-compose.yaml`: TorrServer service with volumes
