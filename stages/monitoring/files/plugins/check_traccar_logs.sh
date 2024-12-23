#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'

TIMESTAMP=`jq -r .timestamp /var/spool/api/deviceping/traccar`
LATITUDE=`jq -r .appendix.latitude /var/spool/api/deviceping/traccar`
LONGITUDE=`jq -r .appendix.longitude /var/spool/api/deviceping/traccar`
CURRENT=`date '+%s'`
DELTA=`echo "${CURRENT} - ${TIMESTAMP}" | bc`

if [[ ${DELTA} -lt ${CRITICAL_THRESHOLD} ]]; then
    ok "Passed a test"
else
    fail "last known location https://maps.google.com/maps?q=${LATITUDE},${LONGITUDE}"
fi
