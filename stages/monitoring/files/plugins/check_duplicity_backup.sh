#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

backup_date=`duplicity collection-status ${1} | grep 'Last full backup date' | cut -f 2- -d ':'`
timestamp=`date --date="${backup_date}" +%s`
current_timestamp=`date +%s`

delta=`echo "(${current_timestamp} - ${timestamp})/86400"`

if [ "${delta}" -gt 6 ]; then
    warning "Last full backup of ${1} was performed ${delta} days ago"
elif test $delta -gt 3; then
    fail "Last full backup of ${1} was performed ${days} ago!"
else
    ok "Last full backup of ${1} was performed ${days} ago"
fi
