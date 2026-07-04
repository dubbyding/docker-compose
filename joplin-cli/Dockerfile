FROM node:20-bookworm-slim

# build deps for keytar + rsync for joplin sync
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 build-essential libsecret-1-dev libsecret-1-0 rsync ca-certificates \
    && npm install -g joplin --unsafe-perm \
    && apt-get purge -y python3 build-essential libsecret-1-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 41184
ENTRYPOINT ["/entrypoint.sh"]
