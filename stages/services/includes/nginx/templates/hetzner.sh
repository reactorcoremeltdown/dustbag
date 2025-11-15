#!/usr/bin/env bash

IFS=$'\n'

dns_hetzner_cloud_api_token=$(jq -cr '.secrets.hetzner.api_token' /etc/secrets/secrets.json)

cat << EOF > /root/.hetzner.ini
dns_hetzner_cloud_api_token = "${dns_hetzner_cloud_api_token}"
EOF

chmod 600 /root/.hetzner.ini
