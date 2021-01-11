#!/usr/bin/env bash

source <(jq -r '.nginx.variables | to_entries[] | [.key,(.value|@sh)] | join("=")' variables/main.json)

cat <<EOF > /etc/nginx/sites-available/transmission.conf
server {
  listen 80;
  listen [::]:80;
  server_name    transmission.tiredsysadmin.cc;
  return 301 https://\$server_name\$request_uri;
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  server_name transmission.tiredsysadmin.cc;
  root /var/www;

  access_log /var/log/nginx/transmission.tiredsysadmin.cc_access.log json;
  error_log /var/log/nginx/transmission.tiredsysadmin.cc_error.log;

  ### SSL cert files ###
  ssl_certificate ${blog_ssl_certificate};
  ssl_certificate_key ${blog_ssl_certificate_key};

  ### Add SSL specific settings here ###
  ssl_session_timeout 10m;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers '${ssl_ciphers}';
  ssl_prefer_server_ciphers on;

  location / {
       proxy_read_timeout 300;
       proxy_pass_header  X-Transmission-Session-Id;
       proxy_set_header   X-Forwarded-Host \$host;
       proxy_set_header   X-Forwarded-Server \$host;
       proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;

       # if you changed the port number for transmission daemon, then adjust the
       # folllowing line
       proxy_pass         http://127.0.0.1:9091/transmission/web/;
   }

    # Also Transmission specific
   location /rpc {
       proxy_pass         http://127.0.0.1:9091/transmission/rpc;
   }

   location /upload {
       proxy_pass         http://127.0.0.1:9091/transmission/upload;
   }
}
EOF

ln -sf /etc/nginx/sites-available/api.conf /etc/nginx/sites-enabled/api.conf
