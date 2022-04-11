#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

usage=`df $1 | tail -n 1 | awk '{print $5}' | sed 's|%||'`

rrdtool update /var/storage/wastebox/operations/disk_space.rrd N:${usage}

if [[ $usage -lt 95 ]]; then
    ok "${usage}% of free disk space"
else
    fail "The amount of used disk space on $1 is $usage%"
fi
