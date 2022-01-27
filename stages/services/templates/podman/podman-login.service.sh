#!/usr/bin/env bash

USERNAME=$(jq '.secrets.containers.username' /etc/secrets/secrets.json)
PASSWORD=$(jq '.secrets.containers.password' /etc/secrets/secrets.json)
REPOSITORY=$(jq '.secrets.containers.hostname' /etc/secrets/secrets.json)

cat <<EOF > /etc/systemd/system/podman-login.service.sh
[Unit]
Description=Login into container repo at login
Before=containers.target

[Service]
Type=oneshot
ExecStart=/usr/bin/podman login -u ${USERNAME} -p ${PASSWORD} ${REPOSITORY}

[Install]
WantedBy=multi-user.target
EOF
