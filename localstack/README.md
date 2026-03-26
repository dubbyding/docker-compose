## LocalStack (S3) (Docker Compose)

Runs LocalStack with S3 enabled and an init script that creates buckets and configures them for public static website hosting.

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Endpoints / ports

- **Gateway**: `http://localhost:4566`

### Configuration (env vars)

The compose file supports:

- `SERVICES` (default `s3`)
- `AWS_DEFAULT_REGION` (default `us-east-1`)
- `BUCKETS` (default `local-public-bucket,local-site-bucket`)
- `UPLOAD_SAMPLE` (default `1`)

Example:

```bash
BUCKETS="my-bucket-1,my-bucket-2" UPLOAD_SAMPLE=0 docker compose up -d
```

### Using AWS CLI

If you have AWS CLI installed locally:

```bash
aws --endpoint-url http://localhost:4566 s3 ls
aws --endpoint-url http://localhost:4566 s3 ls s3://local-public-bucket
```

### What’s in this folder

- `docker-compose.yml`: LocalStack container + healthcheck
- `init-s3.sh`: runs in-container on readiness; creates/configures buckets and (optionally) uploads sample `index.html`
