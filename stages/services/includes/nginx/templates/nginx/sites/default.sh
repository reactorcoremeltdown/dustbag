#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/default.conf
### Deployed by https://git.rcmd.space/rcmd/dustbag

server {
    listen 80;
    listen [::]:80;

    ### SSL cert files ###
    server_name it-the-drote.tk;

    include /etc/nginx/common_ratelimit.conf;

    return 301 https://tiredsysadmin.cc;
}
EOF

ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
