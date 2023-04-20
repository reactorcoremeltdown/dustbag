#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

current_running=`uname -v | awk '{print $4}'`

if dpkg -l linux-image-amd64 | tail -n 1 | awk '{print $3}' | grep -q $current_running; then
    ok "Linux kernel is up to date." "$DESCRIPTION" "$ENVIRONMENT"
else
    warning "Linux kernel $current_running is OUTDATED, server restart needed" "$DESCRIPTION" "$ENVIRONMENT"
fi
