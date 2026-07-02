---
name: run-docker-compose
description: Run, deploy, restart, check status/health, tail logs, screenshot, or update the self-hosted home-server docker-compose fleet (postgres, redis, vaultwarden, homepage, dozzle, joplin, uptime-kuma, watchtower). Use for "run the home server", "deploy <service>", "is <service> up", "restart vaultwarden", "check home server health", "screenshot the dashboard".
---

# run-docker-compose

The deployment is **remote**: a fleet of single-service docker-compose stacks living in `~/docker-compose` on the home server (`ssh personal-laptop`, host `dubbyding`, Ubuntu 24.04). There is no app to launch locally — you drive the live fleet over SSH.

The driver is **`.claude/skills/run-docker-compose/driver.sh`** (paths below are relative to this `docker-compose/` dir). Every subcommand runs on the server via `ssh personal-laptop`; health probes `curl` from *inside* the server, so they work whether or not your local WireGuard tunnel is up. Override the SSH host with `REMOTE=<host>`.

## Prerequisites

- SSH access: `ssh personal-laptop` must succeed (key-based; configured in `~/.ssh/config`).
- `bash` (script is bash-3.2 safe, runs on stock macOS), plus `ssh`. No local Docker needed.
- For the optional dashboard screenshot only: Google Chrome + an **up** WireGuard tunnel (local peer `10.0.0.3`, so `10.0.0.2` is reachable). Not required for any `driver.sh` command.

## Run (agent path) — driver.sh

```bash
cd .claude/skills/run-docker-compose
chmod +x driver.sh   # first time

./driver.sh health        # per-service health table (container state + HTTP probe)
./driver.sh status        # all containers + compose projects + git drift summary
./driver.sh net           # members of the shared external 'db' network
./driver.sh drift         # git fetch + ahead/behind vs origin/main + uncommitted files
./driver.sh logs <svc> [n]   # tail n (default 50) lines, e.g. ./driver.sh logs vaultwarden 100
./driver.sh up <svc>      # deploy: cd ~/docker-compose/<svc> && ./run.sh (or compose up -d)
./driver.sh restart <svc>
./driver.sh down <svc>
./driver.sh pull <svc>    # MANUAL image update: docker compose pull && up -d
./driver.sh ssh -- <cmd>  # arbitrary command on the server
```

Verified `./driver.sh health` output (all nine services UP):

```
SERVICE        STATE      DETAIL
------         -----      ------
postgres_db    UP         /var/run/postgresql:5432 - accepting connections
redis          UP         running=true
homepage       UP         HTTP 200 (http://10.0.0.2:3001/)
dozzle         UP         HTTP 200 (http://10.0.0.2:8080/)
vaultwarden    UP         HTTP 200 (http://10.0.0.2:8000/)
uptime-kuma    UP         HTTP 302 (http://127.0.0.1:3002/)
pgadmin        UP         HTTP 302 (http://127.0.0.1:5050/)
joplin         UP         running=true
watchtower     UP         running=true
```

Health rules: `STATE=UP` when the HTTP probe returns its expected code (or any 2xx/3xx), `WARN` for an unexpected non-error code, `DOWN` when the connection fails (`000`). Postgres uses `pg_isready`; redis/joplin/watchtower have no usable HTTP probe and report container running-state.

## Run (human path)

There is no local human path. To touch a service by hand: `ssh personal-laptop`, then `cd ~/docker-compose/<svc> && ./run.sh` (or `docker compose up -d`). `run.sh` exists to create the shared external `db` bridge network before bringing DB-dependent services up.

## Optional: screenshot a web UI

The dashboards bind to the WireGuard address `10.0.0.2`. With the tunnel up:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --hide-scrollbars --window-size=1366,900 \
  --screenshot=screenshots/homepage.png "http://10.0.0.2:3001/"
```

Captured to `.claude/skills/run-docker-compose/screenshots/homepage.png`. NOTE: hitting `homepage` by raw IP renders an **"Error — Host validation failed"** page (see Gotchas) — that is the real response, not a failure of the screenshot. dozzle (`:8080`) and vaultwarden (`:8000`) screenshot cleanly by IP.

## Deploy / update workflow

1. Edit `~/docker-compose/<svc>/docker-compose.yml` (and `.env`) **on the server** — it is the source of truth.
2. `./driver.sh up <svc>` to apply, `./driver.sh logs <svc>` to verify.
3. Commit + push *from the server* (`ssh personal-laptop`, `cd ~/docker-compose`, `git add/commit/push`). The local clone at `docker-compose/` is usually stale.

## Gotchas (battle scars from this container)

- **macOS bash is 3.2 — no associative arrays.** First driver draft used `declare -A` and died with `homepage: unbound variable`. The committed driver is bash-3.2 safe (no assoc arrays); don't reintroduce them.
- **homepage rejects raw-IP access.** `http://10.0.0.2:3001/` returns HTTP 200 but renders `Host validation failed. See logs for more details.` — gethomepage validates the Host header. It works via its real domain through the VPS Traefik proxy; set `HOMEPAGE_ALLOWED_HOSTS` to reach it by IP. Health probe still passes (it only checks the status code).
- **Services bind to `10.0.0.2` (WireGuard `wg0`), not `0.0.0.0`.** Probing those URLs only works from the server or a WG peer — that's why `driver.sh` curls from inside the server over SSH rather than from your machine.
- **joplin `/api/ping` is Origin-gated** — returns `404 Invalid origin` to a bare curl, so health falls back to container running-state. redis `PING` returns `NOAUTH Authentication required` (password set) — same fallback.
- **watchtower is monitor-only.** Effective env has `WATCHTOWER_MONITOR_ONLY=true`; logs say `Updated=N` but containers are **not** recreated (it only emails that newer images exist). Apply updates yourself with `./driver.sh pull <svc>`.
- **The server git tree is ahead of `origin/main` and dirty** (e.g. `ahead 6, behind 1`, ~13 uncommitted files + untracked data dirs). Do not `git reset`/`pull --force` blindly — commit/push from the server first. Data dirs (`vw-data/`, `data/`, `CONFIG/`, etc.) are gitignored bind mounts, intentionally untracked.
- **`my-portfolio` is not part of this fleet.** It runs from `~/Documents/my-portfolio`, not `~/docker-compose`, so `up`/`pull <svc>` won't find it; manage it separately. (Its watchtower update also 401s — image isn't on a registry.)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `ssh: Could not resolve hostname personal-laptop` | Add the host to `~/.ssh/config`, or run with `REMOTE=<user@host> ./driver.sh ...`. |
| `health` shows a service DOWN but `status` shows it Up | The HTTP probe binds to `10.0.0.2`; confirm you're probing via the server (the driver does) and that `wg0` is up on the server. |
| `up <svc>` fails with `network db not found` | The service's `run.sh` creates it; if you ran bare `docker compose up`, run `./driver.sh ssh -- docker network create db` once. |
| Screenshot blank / connection refused | WireGuard tunnel down locally — bring it up (peer `10.0.0.3`) or screenshot from the server. |
