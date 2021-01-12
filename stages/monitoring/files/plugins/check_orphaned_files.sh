#!/usr/bin/env bash

source /etc/monit/plugins/okfail.sh

count=`lsof +L1 | egrep -vc '/tmp/|/log/|COMMAND'`

if [[ $count -lt "4" ]]; then
    ok "No orphaned files found"
else
    warning "There are $count orphaned files on server"
fi
