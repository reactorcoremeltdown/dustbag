#!/usr/bin/env bash

set -e
IFS=$'\n'

YOUTUBE_API_KEY=$(jq -r '.secrets.podsync.youtube_api_key' /etc/secrets/secrets.json)

cat <<EOF > /etc/podsync/podsync.toml
[server]
port = 26000
hostname = "https://podcasts.rcmd.space"
data_dir = "/var/storage/wastebox/tiredsysadmin.cc/podcasts"

[tokens]
youtube = "${YOUTUBE_API_KEY}"
[feeds]
EOF

for feed in $(jq -cr '.services.podsync.feeds[]' ${1}); do
    source <(echo "${feed}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    echo "  [feeds.${name}]" >> /etc/podsync/podsync.toml
    echo "  url = \"${url}\"" >>  /etc/podsync/podsync.toml
    echo "  page_size = 50" >> /etc/podsync/podsync.toml
    echo "  update_period = \"12h\"" >> /etc/podsync/podsync.toml
    echo "  quality = \"${quality}\"" >> /etc/podsync/podsync.toml
    echo "  format = \"${format}\"" >> /etc/podsync/podsync.toml
done

cat <<EOF >>  /etc/podsync/podsync.toml

[database]
  badger = { truncate = true, file_io = true }

[downloader]
timeout = 15

[log]
filename = "/var/log/podsync/podsync.log"
max_size = 50 # MB
max_age = 30 # days
max_backups = 7
compress = true
EOF

chmod 640 /etc/podsync/podsync.toml
chown syncthing:syncthing /etc/podsync/podsync.toml