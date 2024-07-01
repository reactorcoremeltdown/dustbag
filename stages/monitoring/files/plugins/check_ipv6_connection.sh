#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

status=`curl --head -A "monit-ping-check" -6 -s -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 10 $1`

if [[ $status = "200" ]]; then
    ok "IPv6 is reachable"
else
    fail "IPv6 link is DOWN"
fi
