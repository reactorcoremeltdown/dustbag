#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'
SPENT="0.0"


for entry in $(tail -n 100 ${1}); do
    REQTIME=$(echo "${entry}" | jq -r '.fields.request_time')
    SPENT=$(echo "${SPENT} + ${REQTIME}" | bc)
done

RESULT=$(echo "scale=2; ${SPENT} / 100" | bc | awk '{printf "%f", $0}')

if [[ $(echo "${RESULT} > 2" | bc) -lt 1 ]]; then
    ok "site's response time is below 2 seconds"
else
    fail "site's response time went above 2 seconds: ${RESULT}"
fi
