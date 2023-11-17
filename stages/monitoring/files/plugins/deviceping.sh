#!/usr/bin/env bash

API_URL="https://api.rcmd.space/v6"
UA="User-Agent: monitoring/deviceping-0.2"

source ${PLUGINSDIR}/okfail.sh

API_TOKEN=`jq -cr '.secrets.monitoring.token' /etc/secrets/secrets.json`

GET_BATCH_TOKEN=`curl -XPOST -H "${UA}" --data--urlencode "token=${API_TOKEN}" https://api.rcmd.space/v5/token/get`

BATCH=`curl -XPOST -H "${UA}" --data-urlencode "token=${GET_BATCH_TOKEN}" --data-urlencode="queue=deviceping" https://api.rcmd.space/v5/queue/get-batch`
