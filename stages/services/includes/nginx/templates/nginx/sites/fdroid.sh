#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

SITE='fdroid'
SERVER='tiredsysadmin.cc'

cat <<EOF > /etc/nginx/sites-available/${SITE}.conf
server {
  listen 80;
  listen [::]:80;
  server_name ${SITE}.${SERVER};

  return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/${SITE}.${SERVER}_access.log json;
    error_log /var/log/nginx/${SITE}.${SERVER}_error.log;

    ### SSL cert files ###
    ssl_certificate ${blog_ssl_certificate};
    ssl_certificate_key ${blog_ssl_certificate_key};

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

    server_name ${SITE}.${SERVER};

    root /var/lib/fdroid;

    location / {
        try_files \$uri \$uri/ =404;
    }
}

EOF

ln -sf /etc/nginx/sites-available/${SITE}.conf /etc/nginx/sites-enabled/${SITE}.conf
