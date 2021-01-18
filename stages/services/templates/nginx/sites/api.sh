#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/api.conf
server {
    listen 80;
    listen [::]:80;
    server_name api.rcmd.space;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/api.rcmd.space_access.log json;
    error_log /var/log/nginx/api.rcmd.space_error.log;

    ### SSL cert files ###
    ssl_certificate ${new_ssl_certificate};
    ssl_certificate_key ${new_ssl_certificate_key};

    ### Add SSL specific settings here ###
    ssl_session_timeout 10m;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers '${ssl_ciphers}';
    ssl_prefer_server_ciphers on;

    server_name api.rcmd.space;

    location / {
        return 301 https://\$server_name/v4/version;
    }
    location /hooks {
        limit_req zone=api;

        proxy_pass http://127.0.0.1:25001;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
    }
    location /v4 {
        limit_req zone=api;

        proxy_pass http://127.0.0.1:25004;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
    }
    location /v4/healthcheck {
        proxy_pass http://127.0.0.1:25004;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
    }
    location /v5 {
        limit_req zone=api;

        proxy_pass http://127.0.0.1:25005;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
    }
    location /v5/healthcheck {
        proxy_pass http://127.0.0.1:25005;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
    }
    location /internal {
        limit_req zone=api;

        proxy_pass http://127.0.0.1:26005;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
    }
    location /internal/healthcheck {
        proxy_pass http://127.0.0.1:26005;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
    }
    location /hooks/healthcheck {
        return 301 https://\$server_name/v5/healthcheck;
    }
}
EOF

ln -sf /etc/nginx/sites-available/api.conf /etc/nginx/sites-enabled/api.conf
