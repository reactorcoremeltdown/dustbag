#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

usage=`df ${OPTION} | tail -n 1 | awk '{print $5}' | sed 's|%||'`

if [[ $usage -gt ${CRITICAL_THRESHOLD} ]]; then
    fail "The amount of used disk space on ${OPTION} is $usage%"
elif [[ $usage -gt ${WARNING_THRESHOLD} ]]; then
    warning "The amount of used disk space on ${OPTION} is $usage%"
else
    ok "${usage}% of ${OPTION} is currently used"
fi
