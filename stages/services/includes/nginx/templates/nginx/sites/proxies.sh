#!/usr/bin/env bash


cat <<EOF > /etc/nginx/sites-available/proxies.conf
### Deployed by https://git.rcmd.space/rcmd/dustbag


server {
    listen 80;
    server_name mezha-proxy.reader.tiredsysadmin.cc;

    access_log /var/log/nginx/proxies.rcmd.space_access.log json;
    error_log /var/log/nginx/proxies.rcmd.space_error.log;

    location / {
        proxy_ssl_server_name on;
        proxy_pass https://mezha.media:443;
        proxy_set_header Host mezha.media;
        proxy_set_header User-Agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36";
    }
}
server {
    listen 80;
    server_name reddit-proxy.reader.tiredsysadmin.cc;

    access_log /var/log/nginx/proxies.rcmd.space_access.log json;
    error_log /var/log/nginx/proxies.rcmd.space_error.log;

    location / {
        proxy_ssl_server_name on;
        proxy_pass https://www.reddit.com:443;
        proxy_set_header Host www.reddit.com;
        proxy_set_header User-Agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36";
    }
}

server {
    listen 80;
    server_name podcasts.rcmd.space;

    access_log /var/log/nginx/podcasts.rcmd.space_access.log json;
    error_log /var/log/nginx/podcasts.rcmd.space_error.log;

    location / {
        root /var/lib/podsync;

        charset UTF-8;
        try_files \$uri \$uri/ =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/proxies.conf /etc/nginx/sites-enabled/proxies.conf
