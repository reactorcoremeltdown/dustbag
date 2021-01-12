#!/usr/bin/env bash

source /etc/monit/plugins/okfail.sh

current_running=`uname -v | awk '{print $4}'`

if dpkg -l | grep linux-image | awk '{print $3}' | grep -q $current_running; then
    ok "Linux kernel is up to date." "$DESCRIPTION" "$ENVIRONMENT"
else
    warning "Linux kernel $current_running is OUTDATED, server restart is scheduled" "$DESCRIPTION" "$ENVIRONMENT"
    echo "0 21 * * 6 /sbin/shutdown -r now" > /var/spool/cron/crontabs/root
    echo "0 22 * * 6 /usr/bin/crontab -r" >> /var/spool/cron/crontabs/root 
fi
