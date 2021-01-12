#!/usr/bin/env bash

source /etc/monit/plugins/okfail.sh

log_json_line=`grep --no-filename ${1} /var/log/nginx/traccar_access.log.1 /var/log/nginx/traccar_access.log | tail -n 1`

device_id=`echo "${log_json_line}" | jq -r .device`
timestamp=`echo "${log_json_line}" | jq -r .timestamp`
latitude=`echo "${log_json_line}" | jq -r .latitude`
longitude=`echo "${log_json_line}" | jq -r .longitude`

current_timestamp=`date +%s`

let delta="current_timestamp - timestamp"

if test $delta -gt 86400; then
    warning "The owner of this channel has not reported location data for longer than one day."
elif test $delta -gt 259200; then
    fail "The owner of this channel has not reported location data for longer than three days. Last seen at https://maps.google.com/maps?q=${latitude},${longitude}"
else
    ok "The owner is found and tracked."
fi