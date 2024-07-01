#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

lpstat -r | grep -oq "scheduler is running"
ret_code=$?

if [[ $ret_code = 0 ]]; then
    ok "CUPS server is online" "$DESCRIPTION"
else
    fail "CUPS server is DOWN" "$DESCRIPTION"
fi
