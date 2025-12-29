#!/usr/bin/env bash

API_URL="https://api.rcmd.space/v6"
UA="User-Agent: monitoring/toggles-0.1"

source ${PLUGINSDIR}/okfail.sh

API_TOKEN=`jq -cr '.secrets.monitoring.token' /etc/secrets/secrets.json`

ONETIME_TOKEN=`curl -s -XPOST -H "${UA}" --data-urlencode "token=${API_TOKEN}" https://api.rcmd.space/v6/token/get`
JOB_ID=`curl -s -XPOST -H "${UA}" \
    --data-urlencode "token=${ONETIME_TOKEN}" \
    --data-urlencode "queue=ft_${OPTION}" \
    https://api.rcmd.space/v6/queue/get-job`

ONETIME_TOKEN=`curl -s -XPOST -H "${UA}" --data-urlencode "token=${API_TOKEN}" https://api.rcmd.space/v6/token/get`
STATUS=`curl -s -XPOST -H "${UA}" \
    --data-urlencode "job=${JOB_ID}" \
    --data-urlencode "token=${ONETIME_TOKEN}" \
    --data-urlencode "queue=ft_${OPTION}" \
    https://api.rcmd.space/v6/queue/get-job-payload`

if [[ ${STATUS} = "1" ]]; then
    ok "Feature ${OPTION} is enabled"
else
    fail "Feature ${OPTION} is disabled"
fi
