#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/podcasts.conf
### Deployed by https://git.rcmd.space/rcmd/dustbag

server {
    listen 80;
    listen [::]:80;
    server_name podcasts.rcmd.space;

    include /etc/nginx/common_ratelimit.conf;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;

    access_log /var/log/nginx/podcasts.rcmd.space_access.log json;
    error_log /var/log/nginx/podcasts.rcmd.space_error.log;

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


    server_name podcasts.rcmd.space;

    include /etc/nginx/common_ratelimit.conf;

    location / {
        proxy_pass http://10.200.200.5:80;
        proxy_http_version 1.1;
        client_max_body_size 0;

        proxy_set_header   Host \$http_host;
    }

    location /mds.xml {
        root /var/storage/wastebox/tiredsysadmin.cc/podcasts;
        charset UTF-8;
        try_files \$uri \$uri/ =404;
    }

    location /mds {
        root /var/storage/wastebox/tiredsysadmin.cc/podcasts;
        charset UTF-8;
        try_files \$uri \$uri/ =404;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name podcasts.tiredsysadmin.cc;

    include /etc/nginx/common_ratelimit.conf;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    access_log /var/log/nginx/podcasts.tiredsysadmin.cc_access.log json;
    error_log /var/log/nginx/podcasts.tiredsysadmin.cc_error.log;

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


    server_name podcasts.tiredsysadmin.cc;

    include /etc/nginx/common_ratelimit.conf;

    location / {
        proxy_pass http://10.8.0.102:80;
        proxy_http_version 1.1;
        client_max_body_size 0;

        proxy_set_header   Host \$http_host;
    }

    location /mds.xml {
        root /var/storage/wastebox/tiredsysadmin.cc/podcasts;
        charset UTF-8;
        try_files \$uri \$uri/ =404;
    }

    location /mds {
        root /var/storage/wastebox/tiredsysadmin.cc/podcasts;
        charset UTF-8;
        try_files \$uri \$uri/ =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/podcasts.conf /etc/nginx/sites-enabled/podcasts.conf
