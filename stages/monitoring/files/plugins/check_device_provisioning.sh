#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'

TIMESTAMP=`cat /etc/default/earlystageconfigs`
CURRENT=`date '+%s'`
DELTA=`echo "${CURRENT} - ${TIMESTAMP}" | bc`

if [[ ${DELTA} -lt 7776000 ]]; then
    ok "Device ${HOSTNAME} has been provisioned within last 90 days"
else
    warning "Device ${HOSTNAME} outdated, please run dustbag"
fi
