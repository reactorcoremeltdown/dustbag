#!/usr/bin/env bash

set -e
IFS=$'\n'

RPC_SECRET=$(jq -r '.secrets.drone."rpc-secret"' /etc/secrets/secrets.json)

cat <<EOF > /home/git/.drone-runner-exec/config
DRONE_RUNNER_NAME=${HOSTNAME}
DRONE_RUNNER_LABELS=machine:${HOSTNAME}
DRONE_RPC_PROTO=https
DRONE_RPC_HOST=ci.rcmd.space
DRONE_RPC_SECRET=${RPC_SECRET}
EOF

chmod 600 /home/git/.drone-runner-exec/config
chown git:git /home/git/.drone-runner-exec/config
