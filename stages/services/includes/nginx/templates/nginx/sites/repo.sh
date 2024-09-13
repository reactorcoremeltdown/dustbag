#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

SITE='repo'

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

    location / {
        if (\$http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {
            return 404;
        }
        auth_basic "Protected area";
        auth_basic_user_file /etc/nginx/htpasswd;
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        client_max_body_size 0;

        # Ensuring it can use websockets
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection "upgrade";
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_redirect     http:// \$scheme://;

        proxy_set_header   Host \$http_host;

        # These sets the timeout so that the websocket can stay alive
        proxy_connect_timeout   7m;
        proxy_send_timeout      7m;
        proxy_read_timeout      7m;
    }
    location /binaries/dafuq {
        root /opt/apps;

        autoindex on;
    }
    location /helm {
        root /opt/apps;

        autoindex on;
    }
    location /graphs {
        root /opt/apps;
    }
}

EOF

ln -sf /etc/nginx/sites-available/${SITE}.conf /etc/nginx/sites-enabled/${SITE}.conf

SITE='deb'

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

    root /opt/debian/repo;

    server_name ${SITE}.rcmd.space;

    location ~ /(db|conf) {
        deny all;
        return  404;
    }

}
EOF

ln -sf /etc/nginx/sites-available/${SITE}.conf /etc/nginx/sites-enabled/${SITE}.conf
