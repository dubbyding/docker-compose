#!/bin/sh
set -e
P="--profile /profile"

# configure sync to Joplin Server (target 9 = Joplin Server)
joplin $P config sync.target 9
joplin $P config sync.9.path "$JOPLIN_SERVER_URL"
joplin $P config sync.9.username "$JOPLIN_USER"
joplin $P config sync.9.password "$JOPLIN_PASSWORD"

# preset clipper auth token so the browser extension can use a known token
if [ -n "$JOPLIN_CLIPPER_TOKEN" ]; then
  joplin $P config api.token "$JOPLIN_CLIPPER_TOKEN"
fi

# initial sync (non-fatal if creds not yet set)
joplin $P sync || echo "sync skipped/failed - check creds"

# run the Web Clipper service in foreground (default port 41184)
exec joplin $P server start
