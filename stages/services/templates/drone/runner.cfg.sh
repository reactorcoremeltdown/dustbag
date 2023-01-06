#!/usr/bin/env bash

set -e
IFS=$'\n'

RPC_SECRET=$(jq -r '.secrets.drone."rpc-secret"' /etc/secrets/secrets.json)

cat <<EOF > /home/git/.drone-runner-exec/config
ClIENT_DRONE_RPC_PROTO=https
ClIENT_DRONE_RPC_HOST=ci-beta.rcmd.space
DRONE_RPC_SECRET=${RPC_SECRET}
EOF

chmod 600 /home/git/.drone-runner-exec/config
chown git:git /home/git/.drone-runner-exec/config
