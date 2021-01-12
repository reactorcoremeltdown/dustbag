#!/usr/bin/env bash

source /etc/monit/plugins/okfail.sh

backup_date=`duplicity collection-status ${1} | grep 'Last full backup date' | cut -f 2- -d ':'`
timestamp=`date --date="${backup_date}" +%s`
current_timestamp=`date +%s`

let delta="current_timestamp - timestamp"

if test $delta -gt 612000; then
    warning "Last full backup of ${1} was performed a week ago"
elif test $delta -gt 1209600; then
    fail "Last full backup of ${1} was performed two weeks ago!"
else
    ok "Last full backup of ${1} was performed within a week"
fi