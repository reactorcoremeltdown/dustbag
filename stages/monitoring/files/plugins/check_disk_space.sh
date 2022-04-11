#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

usage=`df $1 | tail -n 1 | awk '{print $5}' | sed 's|%||'`

if [[ $usage -lt 95 ]]; then
    ok "${usage}% of ${1} is currently used"
else
    fail "The amount of used disk space on $1 is $usage%"
fi
