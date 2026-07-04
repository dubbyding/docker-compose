#!/usr/bin/env bash
# driver.sh — drive the home-server docker-compose fleet over SSH.
#
# The deployment is REMOTE: every command runs on the home server via
# `ssh personal-laptop`. Nothing here needs Docker on the local machine.
# Health probes curl from *inside* the server, so they work whether or
# not the local WireGuard tunnel is up.
#
# Usage:
#   ./driver.sh status            # containers + compose projects + git drift
#   ./driver.sh health            # per-service health table (container + HTTP)
#   ./driver.sh net               # inspect the shared 'db' network
#   ./driver.sh logs <svc> [n]    # tail n (default 50) lines for a service
#   ./driver.sh up <svc>          # deploy: cd <svc> && ./run.sh (or up -d)
#   ./driver.sh restart <svc>
#   ./driver.sh down <svc>
#   ./driver.sh pull <svc>        # manual image update: pull && up -d
#   ./driver.sh drift             # fetch origin + show ahead/behind + dirty
#   ./driver.sh ssh -- <cmd...>   # run an arbitrary command on the server
set -uo pipefail

REMOTE="${REMOTE:-personal-laptop}"
ROOT="${ROOT:-docker-compose}"        # ~/docker-compose on the server
WG="${WG:-10.0.0.2}"                  # WireGuard wg0 address services bind to

# Stable service list + health probe per service (bash 3.2 safe — no assoc arrays).
# Probe forms returned by probe_for():
#   url:<URL>:<expected_code>   curl on the server, OK if code matches (any 2xx/3xx also OK)
#   pg:<container>              pg_isready
#   run:<container>            OK if the container is running (for things with no HTTP)
SERVICES="postgres_db redis homepage dozzle vaultwarden uptime-kuma pgadmin joplin watchtower"
probe_for() {
  case "$1" in
    homepage)    echo "url:http://$WG:3001/:200" ;;
    dozzle)      echo "url:http://$WG:8080/:200" ;;
    vaultwarden) echo "url:http://$WG:8000/:200" ;;
    uptime-kuma) echo "url:http://127.0.0.1:3002/:302" ;;
    pgadmin)     echo "url:http://127.0.0.1:5050/:302" ;;
    joplin)      echo "run:joplin" ;;          # /api/ping is Origin-gated; running == up
    postgres_db) echo "pg:postgres_db" ;;
    redis)       echo "run:redis" ;;           # NOAUTH on ping == up
    watchtower)  echo "run:watchtower" ;;
  esac
}

rsh() { ssh "$REMOTE" "$@"; }
die() { echo "ERR: $*" >&2; exit 1; }

cmd_status() {
  rsh 'bash -s' <<'EOS'
echo "=== containers ==="
docker ps -a --format "{{.Names}}\t{{.Status}}\t{{.Ports}}"
echo
echo "=== compose projects ==="
docker compose ls
echo
echo "=== git ($PWD) ==="
cd ~/docker-compose && git fetch -q origin 2>/dev/null
git status -sb | head -1
echo "uncommitted: $(git status --porcelain | wc -l | tr -d ' ') file(s)"
EOS
}

cmd_health() {
  printf "%-14s %-10s %s\n" SERVICE STATE DETAIL
  printf "%-14s %-10s %s\n" "------" "-----" "------"
  for svc in $SERVICES; do
    spec="$(probe_for "$svc")"; [ -z "$spec" ] && continue
    kind="${spec%%:*}"; rest="${spec#*:}"
    case "$kind" in
      url)
        exp="${rest##*:}"; url="${rest%:*}"
        code=$(rsh "curl -s -o /dev/null -m 6 -w '%{http_code}' '$url' 2>/dev/null" || echo 000)
        if [ "$code" = "000" ]; then st=DOWN
        elif [ "$code" = "$exp" ] || [[ "$code" =~ ^[23] ]]; then st=UP
        else st=WARN; fi
        printf "%-14s %-10s %s\n" "$svc" "$st" "HTTP $code ($url)" ;;
      pg)
        c="${rest}"
        out=$(rsh "docker exec $c pg_isready -U admin 2>/dev/null" || true)
        [[ "$out" == *"accepting connections"* ]] && st=UP || st=DOWN
        printf "%-14s %-10s %s\n" "$svc" "$st" "${out:-no response}" ;;
      run)
        c="${rest}"
        run=$(rsh "docker inspect -f '{{.State.Running}}' $c 2>/dev/null" || echo false)
        [ "$run" = "true" ] && st=UP || st=DOWN
        printf "%-14s %-10s %s\n" "$svc" "$st" "running=$run" ;;
    esac
  done
}

cmd_net()      { rsh "docker network inspect db --format 'db net members: {{range .Containers}}{{.Name}} {{end}}'"; }
cmd_logs()     { local s="${1:?service}"; local n="${2:-50}"; rsh "cd ~/$ROOT/$s && docker compose logs --no-color --tail=$n"; }
cmd_up()       { local s="${1:?service}"; rsh "cd ~/$ROOT/$s && { [ -x ./run.sh ] && ./run.sh || docker compose up -d; }"; }
cmd_restart()  { local s="${1:?service}"; rsh "cd ~/$ROOT/$s && docker compose restart"; }
cmd_down()     { local s="${1:?service}"; rsh "cd ~/$ROOT/$s && docker compose down"; }
cmd_pull()     { local s="${1:?service}"; rsh "cd ~/$ROOT/$s && docker compose pull && docker compose up -d"; }
cmd_drift() {
  rsh 'bash -s' <<'EOS'
cd ~/docker-compose && git fetch -q origin
echo "branch: $(git status -sb | head -1)"
echo "ahead/behind vs origin/main: $(git rev-list --left-right --count origin/main...HEAD 2>/dev/null) (behind ahead)"
echo "--- uncommitted ---"; git status --porcelain
EOS
}
cmd_ssh()      { [ "${1:-}" = "--" ] && shift; rsh "$@"; }

sub="${1:-}"; shift || true
case "$sub" in
  status)  cmd_status "$@" ;;
  health)  cmd_health "$@" ;;
  net)     cmd_net "$@" ;;
  logs)    cmd_logs "$@" ;;
  up)      cmd_up "$@" ;;
  restart) cmd_restart "$@" ;;
  down)    cmd_down "$@" ;;
  pull)    cmd_pull "$@" ;;
  drift)   cmd_drift "$@" ;;
  ssh)     cmd_ssh "$@" ;;
  ""|-h|--help|help)
    grep -E '^#( |$)' "$0" | sed 's/^# \{0,1\}//' ;;
  *) die "unknown command: $sub (try: status health net logs up restart down pull drift ssh)" ;;
esac
