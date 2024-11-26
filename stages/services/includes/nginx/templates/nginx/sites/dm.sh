#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/dm.conf
server {
    listen 80;
    listen [::]:80;
    server_name dm.tiredsysadmin.cc;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/dm.tiredsysadmin.cc_access.log json;
    error_log /var/log/nginx/dm.tiredsysadmin.cc_error.log;

    ### SSL cert files ###
    ssl_certificate ${blog_ssl_certificate};
    ssl_certificate_key ${blog_ssl_certificate_key};

    ### Add SSL specific settings here ###
    ssl_session_timeout 10m;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers '${ssl_ciphers}';
    ssl_prefer_server_ciphers on;

    server_name dm.tiredsysadmin.cc;

    location / { 
        proxy_pass http://10.8.0.102:16800; 
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    } 
}
EOF

ln -sf /etc/nginx/sites-available/dm.conf /etc/nginx/sites-enabled/dm.conf
