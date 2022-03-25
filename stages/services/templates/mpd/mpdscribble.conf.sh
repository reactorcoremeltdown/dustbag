#!/usr/bin/env bash

set -x

USERNAME=$(jq -r '.secrets.lastfm.username' /etc/secrets/secrets.json)
PASSWORD=$(jq -r '.secrets.lastfm.password' /etc/secrets/secrets.json)

cat <<EOF > /etc/mpdscribble.conf
log = syslog
verbose = 1

[last.fm]
url = https://post.audioscrobbler.com/
username = ${USERNAME}
password = ${PASSWORD}
journal = /var/cache/mpdscribble/lastfm.journal
EOF

chmod 640 /etc/mpdscribble.conf
chown root:mpdscribble /etc/mpdscribble.conf
