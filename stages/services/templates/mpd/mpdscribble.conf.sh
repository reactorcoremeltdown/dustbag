#!/usr/bin/env bash

set -e

USERNAME=$(jq -r '.secrets.lastfm.username' /etc/secrets/secrets.json)
PASSWORD=$(jq -r '.secrets.lastfm.password' /etc/secrets/secrets.json)
APIKEY=$(jq -r '.secrets.lastfm.apikey' /etc/secrets/secrets.json)
APISECRET=$(jq -r '.secrets.lastfm.apisecret' /etc/secrets/secrets.json)

cat <<EOF | tee /etc/mpdscribble.conf > /etc/radioscrobbler.conf
log = syslog
verbose = 1

[last.fm]
url = https://post.audioscrobbler.com/
username = ${USERNAME}
password = ${PASSWORD}
journal = /var/cache/mpdscribble/lastfm.journal
EOF

cat <<EOF >> /etc/radioscrobbler.conf
[api]
key = ${APIKEY}
secret = ${APISECRET}
EOF

chmod 640 /etc/mpdscribble.conf /etc/radioscrobbler.conf
chown root:mpdscribble /etc/mpdscribble.conf /etc/radioscrobbler.conf
