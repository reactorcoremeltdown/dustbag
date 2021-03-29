#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/site.conf
server {
    listen 80;
    listen [::]:80;
    server_name rcmd.space;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 80;
    listen [::]:80;
    server_name beta.rcmd.space;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/rcmd.space_access.log json;
    error_log /var/log/nginx/rcmd.space_error.log;

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

    root /opt/apps/site/site/live;

    server_name rcmd.space;

    location / {
        try_files /index.html =404;
    }
    location /media {
        root /opt/apps/site;
        expires 30d;
        try_files \$uri \$uri/ =404;
    }
    location /assets {
        root /opt/apps/site;
        expires 3d;
        try_files \$uri \$uri/ =404;
    }
    location /pages {
        try_files \$uri \$uri/ =404;
    }
    location /rss.xml {
        charset UTF-8;
        try_files \$uri \$uri/ =404;
    }

    #include /opt/apps/site/configs/nginx/redirects.conf;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/beta.rcmd.space_access.log json;
    error_log /var/log/nginx/beta.rcmd.space_error.log;

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

    root /opt/apps/site/site/beta;

    server_name beta.rcmd.space;

    auth_basic "Protected area";
    auth_basic_user_file /etc/datasources/htpasswd;

    location / {
        try_files /index.html =404;
    }
    location /media {
        root /opt/apps/site;
        expires 30d;
        try_files \$uri \$uri/ =404;
    }
    location /assets {
        root /opt/apps/site;
        expires 3d;
        try_files \$uri \$uri/ =404;
    }
    location /pages {
        try_files \$uri \$uri/ =404;
    }
    location /rss.xml {
        charset UTF-8;
        try_files \$uri \$uri/ =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf
