#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/default.conf
server {
    listen 80;
    listen [::]:80;

    ### SSL cert files ###
    server_name it-the-drote.tk;

    return 301 https://tiredsysadmin.cc;
}
EOF

ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
