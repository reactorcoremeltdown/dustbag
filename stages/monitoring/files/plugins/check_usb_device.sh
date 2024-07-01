#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

DEVICE=$(lsusb -d ${1})
ret_code=$?

if [[ $ret_code = 0 ]]; then
    ok "USB device online: ${DEVICE}" "$DESCRIPTION"
else
    fail "USB device offline" "$DESCRIPTION"
fi
