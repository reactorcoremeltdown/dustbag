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
    ssl_client_certificate /etc/nginx/pki/pki/ca.crt;
    ssl_crl /etc/nginx/pki/pki/crl.pem;
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

    server_name git.rcmd.space;

    # Enabling authentication, just to be sure

    location / {
        if (\$ssl_client_verify != SUCCESS) {
            return 403;
        }
        proxy_pass http://127.0.0.1:25010;
    }
    location /rcmd/dummy/raw/branch/master/README.md {
        proxy_pass http://127.0.0.1:25010;
    }
    location /rcmd/vanilla-plus.git {
        proxy_pass http://127.0.0.1:25010;
    }
    location /login {
        proxy_pass http://127.0.0.1:25010;
    }
    location /api {
        proxy_pass http://127.0.0.1:25010;
    }
    location /avatars {
        proxy_pass http://127.0.0.1:25010;
    }
    location /media {
        if (\$ssl_client_verify != SUCCESS) {
            return 403;
        }
        root /var/storage/wastebox/tiredsysadmin.cc/wiki;
        expires 30d;
        try_files \$uri \$uri/ =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/git.conf /etc/nginx/sites-enabled/git.conf
