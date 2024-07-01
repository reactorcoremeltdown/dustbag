#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

status=`curl -A "monit-ping-check" -s -o /dev/null -w "%{http_code}" --connect-timeout 20 --max-time 20 $1`

if [[ $status = "200" ]]; then
    ok "Web interface is UP"
else
    fail "Web interface is DOWN"
fi
