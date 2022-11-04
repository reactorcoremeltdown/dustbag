#!/usr/bin/env bash

set -e

cat <<EOF > /etc/mpd.conf
music_directory         "/home/syncthing/Music/Library"
playlist_directory              "/home/syncthing/Music/Library"
db_file                 "/var/lib/mpd/tag_cache"
log_file                        "/var/log/mpd/mpd.log"
pid_file                        "/run/mpd/pid"
state_file                      "/var/lib/mpd/state"
sticker_file                   "/var/lib/mpd/sticker.sql"

user                            "mpd"
bind_to_address         "localhost"

input {
        plugin "curl"
}

input {
        enabled    "no"
        plugin     "qobuz"
}

input {
        enabled      "no"
        plugin       "tidal"
}


decoder {
        plugin                  "hybrid_dsd"
        enabled                 "no"
}


audio_output {
        type            "alsa"
        name            "Default"
        device          "hw:CARD=CODEC,DEV=0"   # optional
        mixer_type      "hardware"      # optional
        mixer_device    "hw:CARD=CODEC"       # optional
        mixer_control   "PCM"           # optional
        mixer_index     "0"             # optional
}

filesystem_charset              "UTF-8"
EOF

chmod 640 /etc/mpd.conf
chown mpd:audio /etc/mpd.conf
