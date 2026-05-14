#!/bin/sh
set -eu

mkdir -p /app/rawdata /app/rawdata/geosite /app/lists

# Keep the generated admin config on the persistent Railway volume.
# The Go app reads ./config.json, so this symlink makes it resolve to /app/rawdata/config.json.
if [ ! -e /app/config.json ] && [ ! -L /app/config.json ]; then
    ln -s /app/rawdata/config.json /app/config.json
fi

# Railway Volumes may be mounted with root ownership. Fix writable runtime paths before dropping privileges.
chown -R ssauser:ssagroup /app/rawdata /app/lists 2>/dev/null || true

exec su-exec ssauser:ssagroup "$@"
