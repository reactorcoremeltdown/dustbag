#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'

TIMESTAMP=`jq .timestamp /var/spool/api/deviceping/traccar`
LATITUDE=`jq .appendix.latitude /var/spool/api/deviceping/traccar`
LONGITUDE=`jq .appendix.longitude /var/spool/api/deviceping/traccar`
CURRENT=`date '+%s'`
DELTA=`echo "${CURRENT} - ${TIMESTAMP}" | bc`

if [[ ${DELTA} -lt ${CRITICAL_THRESHOLD} ]]; then
    ok "Passed a test"
else
    fail "Failed a test"
fi
