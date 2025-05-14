#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'

VALUE=`curl --fail -s --max-time 1 http://localhost:7379/GET/${1} | jq -r '.GET'`

if [[ ${VALUE} -gt ${CRITICAL_THRESHOLD} ]]; then
    fail "The check ${1} has failed more than ${CRITICAL_THRESHOLD} times in a row (${VALUE})."
else
    ok "The number of sequential failures of ${1} is below threshold (${VALUE})."
fi
