#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/dav.conf
server {
    listen 80;
    listen [::]:80;
    server_name dav.rcmd.space;

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

    location / {
        return 200 "It works!";
    }

    location /radicale/ {
        proxy_pass        http://localhost:5232/; # The / is important!
        proxy_set_header  X-Script-Name /radicale;
        proxy_set_header  X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass_header Authorization;
    }
}
server {
    listen 80;
    listen [::]:80;
    server_name webdav.rcmd.space;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443;
    listen [::]:443;
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

    root /var/storage/wastebox;
    index index.html index.htm index.nginx-debian.html;
    server_name webdav.rcmd.space;

    location / {
        dav_methods PUT DELETE MKCOL COPY MOVE;
        dav_ext_methods PROPFIND OPTIONS LOCK UNLOCK;
        dav_access user:rw group:rw all:rw;

        if (\$request_method = MKCOL) {
            rewrite ^(.*[^/])$ \$1/ break;
        }

        if (-d \$request_filename) {
            rewrite ^(.*[^/])$ \$1/ break;
        }

        set \$destination \$http_destination;
        set \$parse "";
        if (\$request_method = MOVE) {
            set \$parse "\${parse}M";
        }

        if (\$request_method = COPY) {
            set \$parse "\${parse}M";
        }

        if (-d \$request_filename) {
            rewrite ^(.*[^/])$ \$1/ break;
            set \$parse "\${parse}D";
        }

        if (\$destination ~ ^https://webdav.rcmd.space/(.*)$) {
            set \$ob \$1;
            set \$parse "\${parse}R\${ob}";
        }

        if (\$parse ~ ^MDR(.*[^/])$) {
            set \$mvpath \$1;
            set \$destination "https://webdav.rcmd.space/\${mvpath}/";
            more_set_input_headers "Destination: \$destination";
        }

        client_max_body_size 0;
        create_full_put_path on;
        client_body_temp_path /tmp/;
        auth_basic "Protected area";
        auth_basic_user_file /etc/nginx/htpasswd;
    }
}
EOF

ln -sf /etc/nginx/sites-available/dav.conf /etc/nginx/sites-enabled/dav.conf
