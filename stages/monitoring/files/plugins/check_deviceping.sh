#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'

TIMESTAMP=`cat /var/spool/api/deviceping/${1}`
CURRENT=`date '+%s'`
DELTA=`echo "${CURRENT} - ${TIMESTAMP}" | bc`

if [[ ${DELTA} -lt 1800 ]]; then
    ok "Device ${1} online"
else
    fail "Device ${1} offline, delta is ${DELTA}"
fi
