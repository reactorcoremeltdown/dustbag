#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'

TIMESTAMP=`jq .timestamp /var/spool/api/deviceping/${OPTION}`
CURRENT=`date '+%s'`
DELTA=`echo "${CURRENT} - ${TIMESTAMP}" | bc`

if [[ ${DELTA} -lt 1800 ]]; then
    ok "Device ${OPTION} online"
else
    fail "Device ${OPTION} offline, delta is ${DELTA}"
fi
