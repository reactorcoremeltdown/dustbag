#!/usr/bin/env bash

source /etc/monit/plugins/okfail.sh

service_status=`docker inspect $1 | jq -r '.[0].State.Status'`

if [[ $service_status == 'running' ]]; then
    ok "Container $1 is UP" "$DESCRIPTION" "$ENVIRONMENT"
else
    fail "Container $1 is DOWN" "$DESCRIPTION" "$ENVIRONMENT"
fi
