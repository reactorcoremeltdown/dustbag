#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'

TIMESTAMP=`curl --fail --connect-timeout 1 http://localhost:7379/GET/${1} | jq -r .GET`
CURRENT=`date '+%s'`
DELTA=`echo "${CURRENT} - ${TIMESTAMP}" | bc`

if [[ ${DELTA} -gt ${CRITICAL_THRESHOLD} ]]; then
    fail "Check ${1} has not reported for ${DELTA} seconds"
else
    ok "Check ${1} is operational"
fi
