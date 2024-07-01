#!/usr/bin/env bash

API_URL="https://api.rcmd.space/v6"
UA="User-Agent: monitoring/toggles-0.1"

source ${PLUGINSDIR}/okfail.sh

API_TOKEN=`jq -cr '.secrets.monitoring.token' /etc/secrets/secrets.json`

ONETIME_TOKEN=`curl -XPOST -H "${UA}" --data--urlencode "token=${API_TOKEN}" https://api.rcmd.space/v5/token/get`
JOB_ID=`curl -XPOST -H "${UA}" \
    --data-urlencode "token=${ONETIME_TOKEN}" \
    --data-urlencode="queue=ft_${1}" \
    https://api.rcmd.space/v5/queue/get-job`

ONETIME_TOKEN=`curl -XPOST -H "${UA}" --data--urlencode "token=${API_TOKEN}" https://api.rcmd.space/v5/token/get`
STATUS=`curl -XPOST -H "${UA}" \
    --data-urlencode "job=${JOB_ID}" \
    --data-urlencode "token=${ONETIME_TOKEN}" \
    --data-urlencode="queue=ft_${1}" \
    https://api.rcmd.space/v5/queue/get-job-payload`

if [[ ${STATUS} = "1" ]]; then
    ok "Feature ${1} is enabled"
else
    fail "Feature ${1} is disabled"
fi
