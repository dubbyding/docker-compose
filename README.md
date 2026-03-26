## Docker service stack (local)

This repo is a collection of **local Docker Compose stacks** for common infrastructure services (Redis, Postgres, MongoDB, Kafka, LocalStack).

### Prerequisites

- Docker Desktop (or Docker Engine) with `docker compose` available
- macOS/Linux shell

### Quick start

Run a stack from its folder:

```bash
cd redis
docker compose up -d
```

Stop it:

```bash
docker compose down
```

### Repo layout

- `redis/`: Redis with AOF persistence and password
- `postgres/`: Postgres + pgAdmin
- `mongodb/`: MongoDB with root user
- `kafka/`: Single-node Kafka (KRaft) compose + helper commands
- `localstack/`: LocalStack (S3 enabled) with init script to create public buckets

### Notes (security / defaults)

- **Credentials are hard-coded for local use** in several compose files (e.g. MongoDB, Postgres, Redis). Treat these as non-production defaults.
- Prefer running stacks individually to avoid port conflicts (Redis 6379, Postgres 5432, MongoDB 27017, Kafka 9092, pgAdmin 5050, LocalStack 4566).
