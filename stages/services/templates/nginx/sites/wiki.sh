#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

SITE='wiki'

cat <<EOF > /etc/nginx/sites-available/${SITE}.conf
server {
  listen 80;
  listen [::]:80;
  server_name ${SITE}.rcmd.space;

  return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/${SITE}.rcmd.space_access.log json;
    error_log /var/log/nginx/${SITE}.rcmd.space_error.log;

    ### SSL cert files ###
    ssl_certificate ${new_ssl_certificate};
    ssl_certificate_key ${new_ssl_certificate_key};
    ssl_client_certificate /etc/nginx/ssl/ca.crt;
    ssl_verify_client optional;
    ssl_verify_depth 2;

    ### Add SSL specific settings here ###
    ssl_session_timeout 10m;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers '${ssl_ciphers}';
    ssl_prefer_server_ciphers on;

    ### Compression
    gzip on;
    gzip_comp_level    5;
    gzip_min_length    256;
    gzip_proxied       any;
    gzip_vary          on;
    gzip_types
    application/rss+xml
    text/css;

    root /opt/apps/wiki;

    server_name ${SITE}.rcmd.space;

    # auth_basic "Protected area";
    # auth_basic_user_file /etc/nginx/htpasswd;

    error_page 404 /404.html;
    location / {
        if (\$ssl_client_verify != SUCCESS) {
            return 403;
        }
        add_header Access-Control-Allow-Origin *;
        try_files /index.html =404;
    }
    location /404.html {
        if (\$ssl_client_verify != SUCCESS) {
            return 403;
        }
        add_header Access-Control-Allow-Origin *;
        try_files /404.html =404;
    }
    location /assets {
        if (\$ssl_client_verify != SUCCESS) {
            return 403;
        }
        add_header Access-Control-Allow-Origin *;
        expires 3d;
        try_files \$uri \$uri/ =404;
    }
    location /media {
        if (\$ssl_client_verify != SUCCESS) {
            return 403;
        }
        add_header Access-Control-Allow-Origin *;
        expires 3d;
        try_files \$uri \$uri/ =404;
    }
    location /pictures {
        if (\$ssl_client_verify != SUCCESS) {
            return 403;
        }
        root /var/storage/wastebox/tiredsysadmin.cc/wiki/pictures;
        add_header Access-Control-Allow-Origin *;
        expires 3d;
        try_files \$uri \$uri/ =404;
    }
    location /zettelkasten {
        if (\$ssl_client_verify != SUCCESS) {
            return 403;
        }
        add_header Access-Control-Allow-Origin *;
        try_files \$uri \$uri/ =404;
    }
    location /records {
        if (\$ssl_client_verify != SUCCESS) {
            return 403;
        }
        if (\$request_method = OPTIONS ) {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods "GET, OPTIONS";
            add_header Access-Control-Allow-Headers "origin, authorization, accept, X-Progress-ID, URI";
            add_header Access-Control-Allow-Credentials "true";
            add_header Content-Length 0;
            add_header Content-Type text/plain;
            return 204;
        }
        add_header Access-Control-Allow-Origin *;
        try_files \$uri \$uri/ =404;
    }
}

EOF

ln -sf /etc/nginx/sites-available/${SITE}.conf /etc/nginx/sites-enabled/${SITE}.conf
