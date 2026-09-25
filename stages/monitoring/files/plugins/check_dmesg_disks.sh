#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

COUNT=$(dmesg | grep -o 'critical target error, dev sd.' | sort -u | wc -l)

if [[ ${COUNT} -gt 0 ]]; then
    fail "${COUNT} disks failed, check their health!"
else
    ok "No failed disks reported"
fi
