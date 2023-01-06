#!/usr/bin/env bash

CURRENT_CHECKSUM=$(md5sum /etc/drone/server.cfg)
OLD_CHECKSUM=$(cat /etc/drone/checksum.txt)

if [ "${CURRENT_CHECKSUM}" != "${OLD_CHECKSUM}" ]; then
    echo "sleep 10 && systemctl restart drone-server.service" | at now
else
    echo "CI server restart is not scheduled"
fi
