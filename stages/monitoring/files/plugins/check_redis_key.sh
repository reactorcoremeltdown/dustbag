#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

IFS=$'\n'

VALUE=`curl http://localhost:7379/GET/${1} | jq -r '.GET'`

if [[ ${VALUE} -gt ${CRITICAL_THRESHOLD} ]]; then
    fail "The check ${1} has failed more than ${CRITICAL_THRESHOLD} times in a row."
else
    ok "The number of sequential failures of ${1} is below threshold."
fi