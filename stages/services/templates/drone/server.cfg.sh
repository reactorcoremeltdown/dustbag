#!/usr/bin/env bash

set -e
IFS=$'\n'

RPC_SECRET=$(jq -r .secrets.drone.rpc-secret /etc/secrets/secrets.json)
CLIENT_ID=$(jq -r .secrets.drone.client-id /etc/secrets/secrets.json)
CLIENT_SECRET=$(jq -r .secrets.drone.client-secret /etc/secrets/secrets.json)

cat <<EOF > /etc/drone/server.cfg
DRONE_GITEA_SERVER=https://git.rcmd.space
DRONE_GITEA_CLIENT_ID=${CLIENT_ID}
DRONE_GITEA_CLIENT_SECRET=${CLIENT_SECRET}
DRONE_RPC_SECRET=${RPC_SECRET}
DRONE_SERVER_HOST=ci-beta.rcmd.space
DRONE_SERVER_PROTO=https
EOF
