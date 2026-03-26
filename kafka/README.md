## Kafka (single-node, KRaft) (Docker Compose)

Runs a single Kafka broker/controller using the `apache/kafka:latest` image and KRaft mode.

### Start

This folder uses a non-default compose filename:

```bash
docker compose -f kafka-docker-compose.yml up -d
```

### Stop

```bash
docker compose -f kafka-docker-compose.yml down
```

### Connection info

- **From your host**: `localhost:9092`
- **From other containers on the same compose network**: `broker:29092`

### Common commands

Open a shell in the broker container (Kafka scripts live under `/opt/kafka/bin`):

```bash
docker exec -it -w /opt/kafka/bin broker sh
```

Inside the container:

```bash
./kafka-topics.sh --create --topic <TOPIC> --bootstrap-server broker:29092
./kafka-topics.sh --list --bootstrap-server broker:29092
./kafka-console-producer.sh --topic <TOPIC> --bootstrap-server broker:29092
./kafka-console-consumer.sh --topic <TOPIC> --from-beginning --bootstrap-server broker:29092
```

### What’s in this folder

- `kafka-docker-compose.yml`: broker/controller service (KRaft)
- `kafka-commands`: command snippets for topic/admin operations
