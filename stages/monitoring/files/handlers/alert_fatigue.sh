#!/usr/bin/env bash

API_URL="https://api.rcmd.space/v6"
UA="User-Agent: monitoring/fatigue-0.1"

API_TOKEN=`jq -cr '.secrets.ledger.token' /etc/secrets/secrets.json`

ONETIME_TOKEN=`curl -s -XPOST -H "${UA}" --data-urlencode "token=${API_TOKEN}" ${API_URL}/token/get`

case ${STATUS} in
  "1" | "2" )
    curl -s -H "${UA}" --data-urlencode "token=${ONETIME_TOKEN}" \
        --data-urlencode "queue=alert-fatigue" \
        --data-urlencode "payload=${NAME}" \
        ${API_URL}/queue/put-job
    ;;
esac
