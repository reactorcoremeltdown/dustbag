#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/git.conf
server {
  listen 80;
  listen [::]:80;
  server_name git.rcmd.space;

  return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/git.rcmd.space_access.log json;
    error_log /var/log/nginx/git.rcmd.space_error.log;

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

    server_name git.rcmd.space;

    # Enabling authentication, just to be sure
    auth_basic "Protected area";
    auth_basic_user_file /etc/datasources/htpasswd;

    location / {
        proxy_pass http://127.0.0.1:25010;
    }
}
EOF

ln -sf /etc/nginx/sites-available/git.conf /etc/nginx/sites-enabled/git.conf
