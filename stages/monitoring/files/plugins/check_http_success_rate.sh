#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

test -d /var/lib/httpsuccessrate/ || mkdir -p /var/lib/httpsuccessrate

TIMEFRAME=$(date --date "now -3 hours" '+%s')

TOTAL_COUNT=$(sqlite3 /var/lib/httpsuccessrate/timeseries.db <<EOF
.timeout 3000
select count(*) from ${PLUGIN_NAME};
EOF
)

if [[ ${TOTAL_COUNT} -gt 1000 ]]; then
    sqlite3 /var/lib/httpsuccessrate/timeseries.db <<EOF
    .timeout 3000
    delete from ${PLUGIN_NAME} where time < strftime('%s', 'now', '-2 days');
EOF
fi

sqlite3 /var/lib/httpsuccessrate/timeseries.db <<EOF
.timeout 3000
CREATE TABLE IF NOT EXISTS ${PLUGIN_NAME} (time timestamp default (strftime('%s', 'now')), status text);
EOF

status=`curl -A "monit-ping-check" -s -o /dev/null -w "%{http_code}" --connect-timeout 20 --max-time 20 $1`

sqlite3 /var/lib/httpsuccessrate/timeseries.db <<EOF
.timeout 3000
insert into ${PLUGIN_NAME} (status) values (${status});
EOF

PERCENTAGE="0"

PERCENTAGE_DEC=$(sqlite3 /var/lib/httpsuccessrate/timeseries.db <<EOF
.timeout 3000
select round(100.0 * count(*) / (select count(*) from ${PLUGIN_NAME} where time > ${TIMEFRAME})) as percentage from ${PLUGIN_NAME} where status = '200' and time > ${TIMEFRAME};
EOF
)

PERCENTAGE=`echo "${PERCENTAGE_DEC}" | cut -f 1 -d '.'`

if [[ $PERCENTAGE -lt ${CRITICAL_THRESHOLD} ]]; then
    fail "The success rate of ${1} is ${PERCENTAGE}%! Check the site health"
elif [[ ${PERCENTAGE} -lt ${WARNING_THRESHOLD} ]]; then
    warning "The success rate of ${1} is ${PERCENTAGE}%"
else
    ok "The success rate of ${1} is ${PERCENTAGE}%"
fi
