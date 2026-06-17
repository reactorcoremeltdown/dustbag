#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

SITE='mood'

cat <<EOF > /etc/nginx/sites-available/${SITE}.conf
### Deployed by https://git.rcmd.space/rcmd/dustbag

server {
  listen 80;
  listen [::]:80;
  server_name ${SITE}.rcmd.space;

  include /etc/nginx/common_ratelimit.conf;

  return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;

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

    include /etc/nginx/common_ratelimit.conf;

    auth_request /validate;
    location = /validate {
        proxy_pass http://127.0.0.1:30021/validate;
        proxy_set_header Host \$http_host;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        auth_request_set \$auth_resp_x_vouch_user \$upstream_http_x_vouch_user;
        auth_request_set \$auth_resp_jwt \$upstream_http_x_vouch_jwt;
        auth_request_set \$auth_resp_err \$upstream_http_x_vouch_err;
        auth_request_set \$auth_resp_failcount \$upstream_http_x_vouch_failcount;
    }
    error_page 401 = @error401;
    location @error401 {
        return 302 https://auth.rcmd.space/login?url=\$scheme://\$http_host\$request_uri&vouch-failcount=\$auth_resp_failcount&X-Vouch-Token=\$auth_resp_jwt&error=\$auth_resp_err;
    }
    location / {
        auth_request /validate;
        proxy_set_header X-Vouch-User \$auth_resp_x_vouch_user;
        proxy_pass http://10.200.1.3:32400;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_http_version 1.1;
        proxy_redirect     off;

        # disable buffering uploads to prevent OOM on reverse proxy server and make uploads twice as fast (no pause)
        proxy_request_buffering off;

        # set timeout
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout       600s;
        proxy_set_header   Upgrade    \$http_upgrade;
        proxy_set_header   Connection "upgrade";
    }
    location /media {
        proxy_set_header X-Vouch-User \$auth_resp_x_vouch_user;
        root /var/storage/wastebox/tiredsysadmin.cc/wiki;
        add_header Access-Control-Allow-Origin *;
        expires 3d;
        try_files \$uri \$uri/ =404;
    }
    location /pictures {
        proxy_set_header X-Vouch-User \$auth_resp_x_vouch_user;
        root /var/storage/wastebox/tiredsysadmin.cc/wiki;
        add_header Access-Control-Allow-Origin *;
        expires 3d;
        try_files \$uri \$uri/ =404;
    }
}

EOF

ln -sf /etc/nginx/sites-available/${SITE}.conf /etc/nginx/sites-enabled/${SITE}.conf
