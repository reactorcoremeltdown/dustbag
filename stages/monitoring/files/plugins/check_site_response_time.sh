#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'
SPENT="0.0"


for entry in $(tail -n 20 ${1}); do
    REQTIME=$(echo "${entry}" | jq -r '.fields.request_time')
    SPENT=$(echo "${SPENT} + ${REQTIME}" | bc)
done

RESULT=$(echo "scale=2; ${SPENT} / 20" | bc | awk '{printf "%f", $0}')

if [[ $(echo "${RESULT} > ${CRITICAL_THRESHOLD}" | bc) -lt 1 ]]; then
    ok "site's response time is below ${CRITICAL_THRESHOLD} seconds"
else
    fail "site's response time went above ${CRITICAL_THRESHOLD} seconds: ${RESULT}"
fi
