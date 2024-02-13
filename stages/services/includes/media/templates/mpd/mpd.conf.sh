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

audio_output {
    type        "httpd"
    name        "HTTP output"
    encoder     "opus"      # optional
    port        "8000"
#   quality     "5.0"           # do not define if bitrate is defined
    bitrate     "192000"            # do not define if quality is defined
    format      "44100:16:1"
    always_on       "yes"           # prevent MPD from disconnecting all listeners when playback is stopped.
    tags            "yes"           # httpd supports sending tags to listening streams.
}

filesystem_charset              "UTF-8"
EOF

chmod 640 /etc/mpd.conf
chown mpd:audio /etc/mpd.conf
