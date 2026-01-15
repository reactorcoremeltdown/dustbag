#!/usr/bin/env bash

set -e
IFS=$'\n'

RPC_SECRET=$(jq -r '.secrets.drone."rpc-secret"' /etc/secrets/secrets.json)
CLIENT_ID=$(jq -r '.secrets.drone."client-id"' /etc/secrets/secrets.json)
CLIENT_SECRET=$(jq -r '.secrets.drone."client-secret"' /etc/secrets/secrets.json)

cat <<EOF > /etc/woodpecker/server.cfg
WOODPECKER_GITEA=true
WOODPECKER_GITEA_URL=https://git.rcmd.space
WOODPECKER_GITEA_CLIENT=${CLIENT_ID}
WOODPECKER_GITEA_SECRET=${CLIENT_SECRET}
WOODPECKER_OPEN=false
WOODPECKER_HOST=https://ci-ng.rcmd.space
EOF

# DRONE_RPC_SECRET=${RPC_SECRET}
# DRONE_SERVER_HOST=ci-ng.rcmd.space
# DRONE_SERVER_PROTO=https
