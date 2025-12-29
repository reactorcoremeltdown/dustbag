#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'

TIMESTAMP=`curl --fail -s --max-time 1 http://localhost:7379/GET/${OPTION} | jq -r .GET`
CURRENT=`date '+%s'`
DELTA=`echo "${CURRENT} - ${TIMESTAMP}" | bc`

if [[ ${DELTA} -gt ${CRITICAL_THRESHOLD} ]]; then
    fail "Check ${OPTION} has not reported for ${DELTA} seconds"
else
    ok "Check ${OPTION} is operational"
fi
