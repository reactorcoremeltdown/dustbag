#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

SITE='pics'

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

    server_name ${SITE}.rcmd.space;

    auth_basic "Protected area";
    auth_basic_user_file /etc/htpasswd/htpasswd;

    location / {
        proxy_pass http://127.0.0.1:27005;
        proxy_http_version 1.1;

        # Ensuring it can use websockets
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection "upgrade";
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto http;
        proxy_redirect     http:// \$scheme://;

        proxy_set_header   Host \$http_host;

        # These sets the timeout so that the websocket can stay alive
        proxy_connect_timeout   7m;
        proxy_send_timeout      7m;
        proxy_read_timeout      7m;
    }
}

EOF

ln -sf /etc/nginx/sites-available/${SITE}.conf /etc/nginx/sites-enabled/${SITE}.conf
