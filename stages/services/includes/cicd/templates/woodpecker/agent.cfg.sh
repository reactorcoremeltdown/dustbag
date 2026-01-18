#!/usr/bin/env bash

set -e
IFS=$'\n'

ROLE="${1}"

if [[ ${ROLE} != "builder" ]]; then
    vault-request-unlock
    RPC_SECRET=$(vault-request-key rpc-secret drone)
else
    RPC_SECRET=$(jq -cr '.secrets.drone."rpc-secret"' /etc/secrets/secrets.json)
fi

cat <<EOF > /home/git/.drone-runner-exec/config
DRONE_RUNNER_NAME=${HOSTNAME}
DRONE_RUNNER_LABELS=role:${1}
DRONE_RPC_PROTO=https
DRONE_RPC_HOST=ci.rcmd.space
DRONE_RPC_SECRET=${RPC_SECRET}
EOF

chmod 600 /home/git/.drone-runner-exec/config
chown git:git /home/git/.drone-runner-exec/config
