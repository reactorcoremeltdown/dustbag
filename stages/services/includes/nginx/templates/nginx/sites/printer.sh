#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

SITE='printer'

cat <<EOF > /etc/nginx/sites-available/${SITE}.conf
server {
  listen 80;
  listen [::]:80;
  server_name ${SITE}.tiredsysadmin.cc;

  return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    access_log /var/log/nginx/${SITE}.tiredsysadmin.cc_access.log json;
    error_log /var/log/nginx/${SITE}.tiredsysadmin.cc_error.log;

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

    server_name ${SITE}.tiredsysadmin.cc;

    location / {
        return 302 https://\$server_name/cups/\$request_uri;
    }

    location ~ /cups/(.*) {
        proxy_pass https://127.0.0.1:631/\$1;

        proxy_http_version 1.1;
        proxy_set_header Accept-Encoding "";
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host '127.0.0.1';
        proxy_cache_bypass \$http_upgrade;

        proxy_set_header X-Real-IP \$remote_addr;

        sub_filter ' href="/' ' href="/cups/';
        sub_filter ' action="/' ' action="/cups/';
        sub_filter ' src="/' ' src="/cups/';
        sub_filter_types *;
        sub_filter_once off;
    }
}

EOF

ln -sf /etc/nginx/sites-available/${SITE}.conf /etc/nginx/sites-enabled/${SITE}.conf
