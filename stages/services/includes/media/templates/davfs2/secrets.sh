#!/usr/bin/env bash

set -e

IFS=$'\n'

ACCOUNTS=$(vault-request-key accounts system/davfs2)

echo "## Davfs2 Secrets, managed by dustbag" > /etc/davfs2/secrets
for i in $(echo "${ACCOUNTS}" | yq -o=json -I=0 -r '.[]'); do
    source <(echo "${i}" | jq -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    echo "${mountpoint} ${username} ${password}" >> /etc/davfs2/secrets
done

chmod 600 /etc/davfs2/secrets
