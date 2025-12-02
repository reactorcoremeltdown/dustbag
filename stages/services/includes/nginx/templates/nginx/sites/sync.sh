#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/sync.conf
### Deployed by https://git.rcmd.space/rcmd/dustbag

server {
    listen 80;
    listen [::]:80;
    server_name sync.rcmd.space;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/sync.rcmd.space_access.log json;
    error_log /var/log/nginx/sync.rcmd.space_error.log;

    ### SSL cert files ###
    ssl_certificate ${new_ssl_certificate};
    ssl_certificate_key ${new_ssl_certificate_key};

    ### Add SSL specific settings here ###
    ssl_session_timeout 10m;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers '${ssl_ciphers}';
    ssl_prefer_server_ciphers on;

    server_name sync.rcmd.space;

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
        proxy_pass http://127.0.0.1:8384; 
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    } 
}
EOF

ln -sf /etc/nginx/sites-available/sync.conf /etc/nginx/sites-enabled/sync.conf
