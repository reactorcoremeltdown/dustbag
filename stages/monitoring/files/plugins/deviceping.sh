#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

API_TOKEN=`jq -cr '.secrets.monitoring.token' /etc/secrets/secrets.json`

GET_BATCH_TOKEN=`curl -XPOST --data--urlencode "token=${API_TOKEN}" https://api.rcmd.space/v5/token/get`

BATCH=`curl -XPOST --data-urlencode "token=${GET_BATCH_TOKEN}" --data-urlencode="queue=deviceping" https://api.rcmd.space/v5/queue/get-batch`


