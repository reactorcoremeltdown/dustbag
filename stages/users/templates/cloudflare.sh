#!/usr/bin/env bash

IFS=$'\n'

dns_cloudflare_email=$(jq -cr '.secrets.cloudflare.dns_cloudflare_email' /etc/secrets/secrets.json)
dns_cloudflare_api_key=$(jq -cr '.secrets.cloudflare.dns_cloudflare_api_key' /etc/secrets/secrets.json)

cat << EOF > /root/.cloudflare.ini
dns_cloudflare_email = "${dns_cloudflare_email}"
dns_cloudflare_api_key = "${dns_cloudflare_api_key}"
EOF

chmod 600 /root/.cloudflare.ini
