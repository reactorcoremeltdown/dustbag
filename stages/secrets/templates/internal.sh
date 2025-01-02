#!/usr/bin/env bash

UPTIME=$(cat /proc/uptime | cut -f 1 -d '.')

if [ "${UPTIME}" -gt 10800 ]; then
    rbw-request-unlock

    TELEGRAM_CHAT=$(rbw-request-key 'alerts' 'telegram/chats')
    TELEGRAM_BOT=$(rbw-request-key 'pisun' 'telegram/bots')

    KANBOARD_API=$(rbw-request-key 'api' 'kanboard')
    KANBOARD_WEBHOOK=$(rbw-request-key 'webhook' 'kanboard')
    DEBUG=$(rbw-request-key 'debug' 'api/internal')
    TASKS_FSMQ_TOKEN=$(vault-request-key 'fsmq_token' 'tasks')

    USERS="$(rbw-request-key 'users' 'api/internal')"

    read -r -d '' YAML <<-EOF
---
system:
  debug: ${DEBUG}
  tokenPoolPath: "/var/spool/api/tokens"
  queuePoolPath: "/var/spool/api/queues"
network:
  port: 80
  routePrefix: "/internal"
  rbwProxyAddress: "http://10.88.0.1:26105"
services:
  fsmq:
    url: "https://api.rcmd.space/v6/"
    queue: "tasksync"
    token: "${TASKS_FSMQ_TOKEN}"
  telegram:
    defaultChat: ${TELEGRAM_CHAT}
    botToken: "${TELEGRAM_BOT}"
  kanboard:
    api:
      url: "https://board.rcmd.space/jsonrpc.php"
      token: "${KANBOARD_API}"
      user: "jsonrpc"
    webhook:
      token: "${KANBOARD_WEBHOOK}"
    projects:
    - name: "sprint"
      id: 16
      color: "amber"
    - name: "chores"
      id: 1
      color: "red"
    - name: "wishlist"
      id: 3
      color: "light_green"
    - name: "watchlater"
      id: 11
      color: "dark_grey"
    - name: "music"
      id: 2
      color: "purple"
    - name: "hackspace"
      id: 9
      color: "lime"
    - name: "skills"
      id: 7
      color: "pink"
    - name: "objectives"
      id: 10
      color: "orange"
users:
${USERS}
EOF

    systemctl stop rcmd-api-internal.service
    podman secret rm rcmd-api-internal rcmd-api-internal-ssh-private rcmd-api-internal-ssh-public || true
    echo "${YAML}" | podman secret create rcmd-api-internal -
    rbw-request-key 'internal_api' 'auth/ssh/private' | cat - <(echo) | podman secret create rcmd-api-internal-ssh-private -
    rbw-request-key 'internal_api' 'auth/ssh/public' | podman secret create rcmd-api-internal-ssh-public -
    systemctl start rcmd-api-internal.service
fi
