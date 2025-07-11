#!/usr/bin/env bash

UPTIME=$(cat /proc/uptime | cut -f 1 -d '.')

if [ "${UPTIME}" -gt 10800 ]; then
    vault-request-unlock

    KANBOARD_API=$(vault-request-key 'api' 'kanboard')
    TASKS_FSMQ_TOKEN=$(vault-request-key 'fsmq_token' 'tasks')

    read -r -d '' YAML <<-EOF
---
system:
  debug: false
network:
  host: "127.0.0.1"
  port: 8080
  webdis: "10.88.0.1:7379"
services:
  fsmq:
    url: "https://api.rcmd.space/v6/"
    queue: "tasksync"
    token: "${TASKS_FSMQ_TOKEN}"
  caldav:
    lists:
      chores: "56933b98-3e43-9bf4-2c9d-389d1952cedf"
      goals: "6a9b53f1-256f-b40c-92d4-51af019f4753"
      work: "37ee1009-a7e0-fadd-11e8-6d6839bdd86a"
  kanboard:
    api:
      url: "https://board.rcmd.space/jsonrpc.php"
      token: "${KANBOARD_API}"
      user: "jsonrpc"
    projects:
      sprint: 17
      chores: 1
      work: 13
EOF
    systemctl stop task-transformer.service
    podman secret rm task-transformer || true
    echo "${YAML}" | podman secret create task-transformer -
    systemctl start task-transformer.service

    kubectl get namespace apps || kubectl create namespace apps
    kubectl delete secret --namespace=apps task-transformer || true
    echo "${YAML}" | kubectl create secret generic --namespace=apps task-transformer --from-file=config.yaml=/dev/stdin
fi
