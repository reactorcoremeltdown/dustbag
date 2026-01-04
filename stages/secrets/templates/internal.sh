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
  rbwProxyAddress: "https://rbw.rcmd.space"
services:
  fsmq:
    url: "https://api.rcmd.space/v6/"
    queue: "tasksync"
    token: "${TASKS_FSMQ_TOKEN}"
  telegram:
    defaultChat: ${TELEGRAM_CHAT}
    botToken: "${TELEGRAM_BOT}"
  xmpp:
    unixSocketPath: "/var/lib/pizdabol/jabber.socket"
  kanboard:
    api:
      url: "https://board.rcmd.space/jsonrpc.php"
      token: "${KANBOARD_API}"
      user: "jsonrpc"
    webhook:
      token: "${KANBOARD_WEBHOOK}"
    projects:
    - name: "sprint"
      id: 18
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
    - name: "work"
      id: 13
      color: "yellow"
users:
${USERS}
EOF

    systemctl stop rcmd-api-internal.service
    podman secret rm rcmd-api-internal rcmd-api-internal-ssh-private rcmd-api-internal-ssh-public || true
    echo "${YAML}" | podman secret create rcmd-api-internal -
    rbw-request-key 'internal_api' 'auth/ssh/private' | cat - <(echo) | podman secret create rcmd-api-internal-ssh-private -
    rbw-request-key 'internal_api' 'auth/ssh/public' | podman secret create rcmd-api-internal-ssh-public -
    systemctl start rcmd-api-internal.service

    kubectl get namespace api || kubectl create namespace api
    kubectl delete secret --namespace=api rcmd-api-internal rcmd-api-internal-ssh-private rcmd-api-internal-ssh-public || true
    echo "${YAML}" | kubectl create secret generic --namespace=api rcmd-api-internal --from-file=config.yaml=/dev/stdin
    rbw-request-key 'internal_api' 'auth/ssh/private' | cat - <(echo) | kubectl create secret generic --namespace=api rcmd-api-internal-ssh-private --from-file=id_rsa=/dev/stdin
    rbw-request-key 'internal_api' 'auth/ssh/public' | kubectl create secret generic --namespace=api rcmd-api-internal-ssh-public --from-file=id_rsa.pub=/dev/stdin
fi
