#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

usage=`ssh -p 23 ${OPTION}@${OPTION}.your-storagebox.de df -h | tail -n 1 | awk '{print $5}' | sed 's|%||'`

if [[ $usage -gt ${CRITICAL_THRESHOLD} ]]; then
    fail "The amount of used disk space on $1 is $usage%"
elif [[ $usage -gt ${WARNING_THRESHOLD} ]]; then
    warning "The amount of used disk space on $1 is $usage%"
else
    ok "${usage}% of ${OPTION} is currently used"
fi
