#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/default.conf
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl;
    listen [::]:443 ssl;

    ### SSL cert files ###
    ssl_certificate ${ssl_certificate};
    ssl_certificate_key ${ssl_certificate_key};

    ### Add SSL specific settings here ###
    ssl_session_timeout 10m;

    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
    ssl_prefer_server_ciphers on;

    server_name it-the-drote.tk;

    return 301 https://tiredsysadmin.cc;
}
EOF

ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
