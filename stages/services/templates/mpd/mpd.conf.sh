#!/usr/bin/env bash

set -e

SOURCE_PASSWORD=$(jq -r '.secrets.icecast["source-password"]' /etc/secrets/secrets.json)

cat <<EOF > /etc/mpd.conf
music_directory         "/var/storage/wastebox/tiredsysadmin.cc/radio"
playlist_directory              "/var/lib/mpd/playlists"
db_file                 "/var/lib/mpd/tag_cache"
log_file                        "/var/log/mpd/mpd.log"
pid_file                        "/run/mpd/pid"
state_file                      "/var/lib/mpd/state"
sticker_file                   "/var/lib/mpd/sticker.sql"

user                            "mpd"
bind_to_address           "127.0.0.1"

decoder {
        plugin                  "hybrid_dsd"
        enabled                 "no"
}

audio_output {
        type            "shout"
        encoder         "lame"          # optional
        name            "Radio. For everyone."
        host            "localhost"
        port            "8000"
        mount           "/play"
        password        "${SOURCE_PASSWORD}"
        bitrate         "128"
        format          "44100:16:2"
        protocol        "icecast2"              # optional
        user            "source"                # optional
        description     "A small single-format internet radio station. No talks. Music for workspaces." # optional
        url         "https://radio.tiredsysadmin.cc"    # optional
        genre           "dark ambient"                  # optional
        public          "no"                    # optional
        timeout         "2"                     # optional
        mixer_type      "software"              # optional
}

filesystem_charset              "UTF-8"
EOF

chmod 640 /etc/mpd.conf
chown mpd:audio /etc/mpd.conf
