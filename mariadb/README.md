## MariaDB (Docker Compose)

Relational database server for multiple applications. Can be shared across NextCloud, WordPress, and other services.

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Access

```bash
# Connect from host
mysql -u root -p -h localhost

# Connect from another container
docker exec -it mariadb mysql -u root -p
```

### Configuration

#### Environment Variables (create `.env` file)

```env
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=secure_password
```

Or use defaults in docker-compose.yml (not recommended for production).

### Connection Info

- **Host**: `localhost` (from host machine)
- **Port**: `3306`
- **Root user**: From `MYSQL_ROOT_PASSWORD`
- **Default database**: From `MYSQL_DATABASE`
- **Default user**: From `MYSQL_USER`

### Data Persistence

- Volume: `./data/` contains all database files
- Persists after container stops
- Backup-friendly location

### First-time Setup

1. Start container: `docker compose up -d`
2. Wait for initialization
3. Connect and verify:
   ```bash
   docker exec -it mariadb mysql -u root -p
   ```

### Creating Databases for Multiple Services

Connect to MariaDB and create separate databases for different services:

```bash
docker exec -it mariadb mysql -u root -p

# Inside MariaDB prompt:
CREATE DATABASE nextcloud;
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'nextcloud_password';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';

CREATE DATABASE wordpress;
CREATE USER 'wordpress'@'%' IDENTIFIED BY 'wordpress_password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';

CREATE DATABASE appname;
CREATE USER 'appuser'@'%' IDENTIFIED BY 'apppassword';
GRANT ALL PRIVILEGES ON appname.* TO 'appuser'@'%';

FLUSH PRIVILEGES;
```

### Using with Other Services

#### NextCloud
In NextCloud's `.env`:
```env
MYSQL_HOST=localhost
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=nextcloud_password
```

#### Multiple Services
Each service points to the same MariaDB instance with different database names:
- Service 1: Database `app1`
- Service 2: Database `app2`
- Service 3: Database `app3`

### Backup and Restore

#### Backup a database
```bash
docker exec mariadb mysqldump -u root -p<password> \
  database_name > backup.sql
```

#### Backup all databases
```bash
docker exec mariadb mysqldump -u root -p<password> \
  --all-databases > full_backup.sql
```

#### Restore a database
```bash
docker exec -i mariadb mysql -u root -p<password> \
  database_name < backup.sql
```

### Performance Tuning

MariaDB 11 includes optimizations for:
- InnoDB storage engine
- Query caching
- Connection pooling

For home servers, defaults are suitable. Monitor resource usage with:
```bash
docker stats mariadb
```

### Common Tasks

#### List all databases
```bash
docker exec -it mariadb mysql -u root -p -e "SHOW DATABASES;"
```

#### List all users
```bash
docker exec -it mariadb mysql -u root -p -e "SELECT User, Host FROM mysql.user;"
```

#### Change user password
```bash
docker exec -it mariadb mysql -u root -p
ALTER USER 'username'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

#### Drop database
```bash
docker exec -it mariadb mysql -u root -p
DROP DATABASE database_name;
```

### Troubleshooting

#### Connection refused
- Verify container is running: `docker ps | grep mariadb`
- Check port binding: `docker port mariadb`
- Review logs: `docker compose logs -f mariadb`

#### Out of disk space
- Check volume: `docker volume ls | grep mariadb`
- Inspect usage: `docker exec mariadb du -sh /var/lib/mysql`

#### Slow queries
- Enable slow query log in MariaDB
- Check table indexes
- Monitor with: `docker stats mariadb`

#### Permission denied
- Verify MYSQL_USER has correct permissions
- Use `GRANT` command to add permissions
- Restart container if needed

### Security Notes

- Root password should be strong and secure
- Create separate users for each service
- Use `@'%'` for access from other containers (same Docker network)
- For production, consider using secrets management

### Cleanup

```bash
# Stop and remove container
docker compose down

# Remove volume (WARNING: deletes all data)
docker compose down -v

# Just stop (keep data)
docker compose stop
```

### What's in this folder

- `docker-compose.yml`: MariaDB service
- `.env`: Configuration file (create with your credentials)
- `README.md`: This documentation
- `data/`: Database files (persisted after shutdown)

### See Also

- [NextCloud Setup](../nextcloud/README.md) - Uses MariaDB
- [Docker Service Stack](../README.md)
