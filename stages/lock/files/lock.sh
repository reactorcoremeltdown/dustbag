#!/usr/bin/env bash

while true; do
    if test -f /var/lock/drone.lock; then
        echo "Another instance of a pipeline is running on this machine, pausing execution for 1 minute"
    else
        echo "Pipeline unlocked!"
        break;
    fi
    sleep 60
done

touch /var/lock/drone.lock
