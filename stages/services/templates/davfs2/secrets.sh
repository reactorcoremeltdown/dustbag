#!/usr/bin/env bash

IFS=$'\n'

echo "## Davfs2 Secrets, managed by dustbag" > /etc/davfs2/secrets
for i in $(jq -cr '.secrets.davfs2.accounts[]' /etc/secrets/secrets.json); do
    source <(echo "${i}" | jq '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    echo ${mountpoint}
    echo "${mountpoint} ${username} ${password}" >> /etc/davfs2/secrets
done

chmod 600 /etc/davfs2/secrets
