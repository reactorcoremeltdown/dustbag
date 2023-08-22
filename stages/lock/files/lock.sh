#!/usr/bin/env bash

while true; do
    if test -f /var/lock/drone.lock; then
        echo "Another instance of a pipeline is running on this machine"
    else
        break;
    fi
    sleep 5
done

touch /var/lock/drone.lock
