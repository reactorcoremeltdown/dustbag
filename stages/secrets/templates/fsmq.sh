#!/usr/bin/env bash

UPTIME=$(cat /proc/uptime | cut -f 1 -d '.')

if [ "${UPTIME}" -gt 10800 ]; then
    rbw-request-unlock

    WEBHOOK_PASSWORD=$(rbw-request-key 'tasksync' 'auth/basic/plain')
    AUTH=$(echo -n "tasksync:${WEBHOOK_PASSWORD}" | base64 -w 0)

    USERS="$(rbw-request-key 'users' 'api/main')"

    read -r -d '' YAML <<-EOF
---
network:
  port: 80
  route_prefix: "/v6"
pool:
  token: "/var/spool/api/tokens"
  queue: "/var/spool/api/queues"
webhook:
- name: "Tasksync"
  queue: "tasksync"
  url: "https://api.rcmd.space/task-transformer/v1/tasksync"
  headers:
  - key: "Content-Type"
    value: "application/json"
  - key: "Authorization"
    value: "Basic ${AUTH}"
  data: "{}"
- name: "New Sprint"
  queue: "sprint"
  url: "https://api.rcmd.space/task-transformer/v1/tasksync"
  headers:
  - key: "Content-Type"
    value: "application/json"
  - key: "Authorization"
    value: "Basic ${AUTH}"
  data: "{}"
- name: "Watch Later"
  queue: "watchlater"
  url: "https://api.rcmd.space/task-transformer/v1/watchlater"
  headers:
  - key: "Content-Type"
    value: "application/json"
  - key: "Authorization"
    value: "Basic ${AUTH}"
  data: "{}"
acl:
${USERS}
EOF
    systemctl stop rcmd-api-v6.service
    podman secret rm rcmd-api-v6 || true
    echo "${YAML}" | podman secret create rcmd-api-v6 -
    systemctl start rcmd-api-v6.service

    kubect get namespace api || kubectl create namespace api
    kubectl delete secret --namespace=api rcmd-api-v6 || true
    echo "${YAML}" | kubectl create secret generic rcmd-api-v6 --from-file=fsmq.yaml=/dev/stdin
fi
