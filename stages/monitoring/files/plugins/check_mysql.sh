#!/usr/bin/env bash

source /etc/monit/plugins/okfail.sh

eval mysqladmin -u ping -h localhost --password=ping ping > /dev/null 2>&1
ret_code=$?

if [[ $ret_code == 0 ]]; then
    ok "MySQL server is UP" "$DESCRIPTION" "$ENVIRONMENT"
else
    fail "MySQL server is DOWN" "$DESCRIPTION" "$ENVIRONMENT"
fi
