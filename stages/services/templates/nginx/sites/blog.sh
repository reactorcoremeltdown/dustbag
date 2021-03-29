#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/blog.conf
server {
    listen 80;
    listen [::]:80;
    server_name blog.it-the-drote.tk;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 80;
    listen [::]:80;
    server_name tiredsysadmin.cc;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/tiredsysadmin.cc_access.log json;
    error_log /var/log/nginx/tiredsysadmin.cc_error.log;

    ### SSL cert files ###
    ssl_certificate ${blog_ssl_certificate};
    ssl_certificate_key ${blog_ssl_certificate_key};

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

    root /opt/apps/blog;

    server_name tiredsysadmin.cc;

    location / {
        try_files /index.html =404;
    }
    location /category {
        try_files \$uri \$uri/ =404;
    }
    location /media {
        expires 30d;
        try_files \$uri \$uri/ =404;
    }
    location /assets {
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

server {
    listen 80;
    listen [::]:80;
    server_name radio.tiredsysadmin.cc;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/radio.tiredsysadmin.cc_access.log json;
    error_log /var/log/nginx/radio.tiredsysadmin.cc_error.log;

    ### SSL cert files ###
    ssl_certificate ${blog_ssl_certificate};
    ssl_certificate_key ${blog_ssl_certificate_key};

    ### Add SSL specific settings here ###
    ssl_session_timeout 10m;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers ${ssl_ciphers};
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

    root /opt/apps/blog/radio;

    server_name radio.tiredsysadmin.cc;

    location / {
        try_files /index.html =404;
    }
    location /stats.json {
        try_files /stats.json =404;
    }
    location /play {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
    }
    location /media {
        root /opt/apps/blog;
        expires 30d;
        try_files \$uri \$uri/ =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/blog.conf /etc/nginx/sites-enabled/blog.conf
