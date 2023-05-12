#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

test -d /var/lib/httpsuccessrate/ || mkdir -p /var/lib/httpsuccessrate

YESTERDAY=$(date --date "now -24 hours" '+%s')

sqlite3 /var/lib/httpsuccessrate/timeseries.db "CREATE TABLE IF NOT EXISTS ${PLUGIN_NAME} (time timestamp default (strftime('%s', 'now')), status text)"

status=`curl -A "monit-ping-check" -s -o /dev/null -w "%{http_code}" --connect-timeout 20 --max-time 20 $1`

sqlite3 /var/lib/httpsuccessrate/timeseries.db "insert into ${PLUGIN_NAME} (status) values (${status})"

PERCENTAGE=`sqlite3 /var/lib/httpsuccessrate/timeseries.db "select round(100.0 * count(*) / (select count(*) from ${PLUGIN_NAME} where time > ${YESTERDAY})) as percentage from ${PLUGIN_NAME} where status = '200' and time > ${YESTERDAY}"`

if [[ $PERCENTAGE -lt ${WARNING_THRESHOLD} ]]; then
    warning "The success rate of ${1} is ${PERCENTAGE}%"
elif [[ ${PERCENTAGE} -lt ${CRITICAL_THRESHOLD} ]]; then
    fail "The success rate of ${1} is ${PERCENTAGE}%! Check the site health"
else
    ok "The success rate of ${1} is ${PERCENTAGE}%"
fi
