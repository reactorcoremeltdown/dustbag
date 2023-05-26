#!/usr/bin/env bash

set -e

USERNAME=$(jq -r '.secrets.lastfm.username' /etc/secrets/secrets.json)
PASSWORD=$(jq -r '.secrets.lastfm.password' /etc/secrets/secrets.json)
APIKEY=$(jq -r '.secrets.lastfm.apikey' /etc/secrets/secrets.json)
APISECRET=$(jq -r '.secrets.lastfm.apisecret' /etc/secrets/secrets.json)

cat <<EOF > /etc/mpdscribble.conf
log = syslog
verbose = 1

[last.fm]
url = https://post.audioscrobbler.com/
username = ${USERNAME}
password = ${PASSWORD}
journal = /var/cache/mpdscribble/lastfm.journal

[api]
key = ${APIKEY}
secret = ${APISECRET}
EOF

chmod 640 /etc/mpdscribble.conf
chown root:mpdscribble /etc/mpdscribble.conf
