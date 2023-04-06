#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

mpc | grep -oq "volume"
ret_code=$?

if [[ $ret_code == 0 ]]; then
    ok "MPD server is online" "$DESCRIPTION"
else
    fail "MPD server is DOWN" "$DESCRIPTION"
fi
