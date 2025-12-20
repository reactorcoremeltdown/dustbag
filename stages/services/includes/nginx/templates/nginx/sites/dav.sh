#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/dav.conf
### Deployed by https://git.rcmd.space/rcmd/dustbag

server {
    listen 80;
    listen [::]:80;
    server_name dav.rcmd.space;

    include /etc/nginx/common_ratelimit.conf;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/dav.rcmd.space_access.log json;
    error_log /var/log/nginx/dav.rcmd.space_error.log;

    ### SSL cert files ###
    ssl_certificate ${new_ssl_certificate};
    ssl_certificate_key ${new_ssl_certificate_key};

    ### Add SSL specific settings here ###
    ssl_session_timeout 10m;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers '${ssl_ciphers}';
    ssl_prefer_server_ciphers on;

    server_name dav.rcmd.space;

    include /etc/nginx/common_ratelimit.conf;

    location / {
        return 200 "It works!";
    }

    location /radicale/ {
        mirror /ingest;
        proxy_read_timeout 300;
        proxy_pass        http://127.0.0.1:5232/; # The / is important!
        proxy_set_header  X-Script-Name /radicale;
        proxy_set_header  X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass_header Authorization;
    }
    location /ingest {
        internal;
        proxy_read_timeout 300;
        proxy_pass        http://127.0.0.1:30071/ingest\$request_uri; # The / is important!
        proxy_set_header  X-Script-Name /radicale;
        proxy_set_header  X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass_header Authorization;
    }
}
server {
    listen 80;
    listen [::]:80;
    server_name webdav.rcmd.space;

    include /etc/nginx/common_ratelimit.conf;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    access_log /var/log/nginx/webdav.rcmd.space_access.log json;
    error_log /var/log/nginx/webdav.rcmd.space_error.log;

    ### SSL cert files ###
    ssl_certificate ${new_ssl_certificate};
    ssl_certificate_key ${new_ssl_certificate_key};

    ### Add SSL specific settings here ###
    ssl_session_timeout 10m;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers '${ssl_ciphers}';
    ssl_prefer_server_ciphers on;

    server_name webdav.rcmd.space;

    include /etc/nginx/common_ratelimit.conf;

    location / {
        auth_basic "Protected area";
        auth_basic_user_file /etc/nginx/htpasswd;
        client_max_body_size 0;
        proxy_pass http://10.200.200.5:38000; 
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    } 
}
EOF

ln -sf /etc/nginx/sites-available/dav.conf /etc/nginx/sites-enabled/dav.conf
