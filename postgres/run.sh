#!/bin/bash
if ! docker network ls --format '{{.Name}}' | grep -q '^db$'; then
  echo "Creating 'db' network..."
  docker network create db
fi
docker compose up -d
