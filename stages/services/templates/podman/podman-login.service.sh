#!/usr/bin/env bash



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
