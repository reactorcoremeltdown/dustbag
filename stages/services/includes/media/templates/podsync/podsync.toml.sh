#!/usr/bin/env bash

set -e
IFS=$'\n'

YOUTUBE_API_KEY=$(vault-request-key youtube_api_key podsync)
FEEDS=$(vault-request-key feeds podsync)
SERVER_HOSTNAME=$(vault-request-key server_hostname podsync)

cat <<EOF > /etc/podsync/podsync.toml
[server]
port = 26000
hostname = "https://${SERVER_HOSTNAME}"
data_dir = "/var/lib/podsync"

[tokens]
youtube = "${YOUTUBE_API_KEY}"
[feeds]
EOF

for feed in $(echo "${FEEDS}" | yq -cr '.[]'); do
    name=$(echo "${feed}" | jq -cr '.name')
    url=$(echo "${feed}" | jq -cr '.url')
    filters=$(echo "${feed}" | jq -cr '.filters')
    keep_last=$(echo "${feed}" | jq -cr '.keep_last')
    cron_schedule=$(echo "${feed}" | jq -cr '.cron_schedule')
    playlist_sort=$(echo "${feed}" | jq -cr '.playlist_sort')
    youtube_dl_args=$(echo "${feed}" | jq -cr '.youtube_dl_args')
    post_download_hook=$(echo "${feed}" | jq -cr '.post_download_hook')
    echo "  [feeds.${name}]" >> /etc/podsync/podsync.toml
    echo "  url = \"${url}\"" >>  /etc/podsync/podsync.toml
    echo "  page_size = 3" >> /etc/podsync/podsync.toml
    echo "  quality = \"high\"" >> /etc/podsync/podsync.toml
    echo "  format = \"audio\"" >> /etc/podsync/podsync.toml
    echo "  private_feed = true" >> /etc/podsync/podsync.toml
    if [[ ${youtube_dl_args} != "null" ]]; then
        echo "  youtube_dl_args = ${youtube_dl_args}" >> /etc/podsync/podsync.toml
    else
        echo '  youtube_dl_args = [ "--match-filter", "!is_live", "--embed-thumbnail", "--add-metadata" ]' >> /etc/podsync/podsync.toml
    fi
    if [[ ${filters} != "null" ]]; then
        echo "  filters = ${filters}" >> /etc/podsync/podsync.toml
    fi
    if [[ ${post_download_hook} != "null" ]]; then
        echo "  post_download_hook = ${post_download_hook}" >> /etc/podsync/podsync.toml
    fi
    if [[ ${keep_last} != "null" ]]; then
        echo "  clean = { keep_last = ${keep_last} }" >> /etc/podsync/podsync.toml
    else
        echo "  clean = { keep_last = 10 }" >> /etc/podsync/podsync.toml
    fi
    if [[ ${playlist_sort} != "null" ]]; then
        echo "  playlist_sort = ${playlist_sort}" >> /etc/podsync/podsync.toml
    fi
    if [[ ${cron_schedule} != "null" ]]; then
        echo "  cron_schedule = \"${cron_schedule}\"" >> /etc/podsync/podsync.toml
    else
        echo "  update_period = \"1h\"" >> /etc/podsync/podsync.toml
    fi
done

cat <<EOF >>  /etc/podsync/podsync.toml

[database]
  badger = { truncate = true, file_io = true }

[downloader]
self_update = true
timeout = 45
debug_hook = "/usr/local/bin/youtube_debug_logger.sh"

[log]
filename = "/var/log/podsync/podsync.log"
max_size = 50 # MB
max_age = 30 # days
max_backups = 7
compress = true
EOF

chmod 640 /etc/podsync/podsync.toml
chown syncthing:syncthing /etc/podsync/podsync.toml
