#!/usr/bin/env bash

source /etc/monit/plugins/okfail.sh

usage=`df $1 | tail -n 1 | awk '{print $5}' | sed 's|%||'`

rrdtool update /var/storage/wastebox/operations/disk_space.rrd N:${usage}

if [[ $usage -lt 95 ]]; then
    ok "enough free space on disk"
else
    fail "The amount of used disk space on $1 is $usage%"
fi
