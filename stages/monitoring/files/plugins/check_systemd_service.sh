#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

service_status=`systemctl is-active ${OPTION}`

if [[ $service_status = 'active' ]]; then
    ok "Unit ${OPTION} is UP" "$DESCRIPTION" "$ENVIRONMENT"
else
    fail "Unit ${OPTION} is DOWN" "$DESCRIPTION" "$ENVIRONMENT"
fi
