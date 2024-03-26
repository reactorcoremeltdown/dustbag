#!/usr/bin/env bash

set -e
IFS=$'\n'

YOUTUBE_API_KEY=$(vault-request-key youtube_api_key podsync)
FEEDS=$(vault-request-key feeds podsync)

cat <<EOF > /etc/podsync/podsync.toml
[server]
port = 26000
hostname = "https://podcasts.rcmd.space"
data_dir = "/var/storage/wastebox/tiredsysadmin.cc/podcasts"

[tokens]
youtube = "${YOUTUBE_API_KEY}"
[feeds]
  [feeds.mds]
  url = "https://www.youtube.com/channel/UCNJCyZJK0e-0YWzxs7BY00A"
  page_size = 100
  update_period = "1h"
  quality = "high"
  format = "audio"
EOF

for feed in $(echo "${FEEDS}" | yq -cr '.[]'); do
    source <(echo "${feed}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    echo "  [feeds.${name}]" >> /etc/podsync/podsync.toml
    echo "  url = \"${url}\"" >>  /etc/podsync/podsync.toml
    echo "  page_size = 10" >> /etc/podsync/podsync.toml
    echo "  update_period = \"1h\"" >> /etc/podsync/podsync.toml
    echo "  quality = \"high\"" >> /etc/podsync/podsync.toml
    echo "  format = \"audio\"" >> /etc/podsync/podsync.toml
    if [[ ${format} = 'audio' ]]; then
        echo '  youtube_dl_args = [ "--audio-quality", "192K" ]' >> /etc/podsync/podsync.toml
    fi
    if [[ ${filters} != "" ]]; then
        echo "  filters = ${filters}" >> /etc/podsync/podsync.toml
        filters=""
    fi
done

cat <<EOF >>  /etc/podsync/podsync.toml

[database]
  badger = { truncate = true, file_io = true }

[downloader]
self_update = true
timeout = 45

[log]
filename = "/var/log/podsync/podsync.log"
max_size = 50 # MB
max_age = 30 # days
max_backups = 7
compress = true
EOF

chmod 640 /etc/podsync/podsync.toml
chown syncthing:syncthing /etc/podsync/podsync.toml
