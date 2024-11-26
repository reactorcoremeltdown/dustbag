nginx_packages:
	dpkg-query -s nginx > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y nginx

nginx_certificates:
	bash stages/services/includes/nginx/templates/cloudflare.sh
	test -L /etc/letsencrypt/live/rcmd.space/fullchain.pem || yes | certbot certonly --agree-tos --non-interactive --email azer.abdullaev.berlin@gmail.com --dns-cloudflare --dns-cloudflare-propagation-seconds 60 --dns-cloudflare-credentials /root/.cloudflare.ini -d rcmd.space,*.rcmd.space --preferred-challenges dns-01
	test -L /etc/letsencrypt/live/tiredsysadmin.cc/fullchain.pem || yes | certbot certonly --agree-tos --non-interactive --email azer.abdullaev.berlin@gmail.com --dns-cloudflare --dns-cloudflare-propagation-seconds 60 --dns-cloudflare-credentials /root/.cloudflare.ini -d tiredsysadmin.cc,*.tiredsysadmin.cc --preferred-challenges dns-01
	test -d /etc/nginx/ssl || mkdir -p /etc/nginx/ssl
	test -f /etc/nginx/ssl/ca.crt || openssl req  -nodes -newkey rsa:4096 -days 365 -x509 -keyout /etc/nginx/ssl/ca.key -out /etc/nginx/ssl/ca.crt -subj '/C=DE/ST=Berlin/L=Berlin/O=RCMD/OU=Funkhaus/CN=RCMD Server'
	test -d /etc/nginx/pki/pki || mkdir -p /etc/nginx/pki/pki
	test -f /etc/nginx/pki/pki/ca.crt || install -D -m 644 -v stages/services/includes/nginx/files/etc/nginx/pki/pki/ca.crt /etc/nginx/pki/pki
	install -D -m 644 -v stages/services/includes/nginx/files/etc/nginx/pki/pki/crl.pem /etc/nginx/pki/pki

nginx_proxies:
	bash stages/services/includes/nginx/templates/nginx/sites/proxies.sh

nginx_sites:
	bash stages/services/includes/nginx/templates/nginx/sites/bank.sh
	bash stages/services/includes/nginx/templates/nginx/sites/ci.sh
	bash stages/services/includes/nginx/templates/nginx/sites/dav.sh
	bash stages/services/includes/nginx/templates/nginx/sites/default.sh
	bash stages/services/includes/nginx/templates/nginx/sites/dm.sh
	bash stages/services/includes/nginx/templates/nginx/sites/git.sh
	bash stages/services/includes/nginx/templates/nginx/sites/netdata.sh
	bash stages/services/includes/nginx/templates/nginx/sites/podcasts.sh
	bash stages/services/includes/nginx/templates/nginx/sites/repo.sh
	bash stages/services/includes/nginx/templates/nginx/sites/sync.sh
	bash stages/services/includes/nginx/templates/nginx/sites/mood.sh

nginx_printer: nginx
	bash stages/services/includes/nginx/templates/nginx/sites/printer.sh

nginx_configs:
	install -D -m 644 -v stages/services/includes/nginx/files/etc/logrotate.d/nginx /etc/logrotate.d
	install -D -m 755 -v stages/services/includes/nginx/files/usr/local/bin/clicks_count /usr/local/bin
	install -D -m 644 -v stages/services/includes/nginx/files/etc/nginx/conf.d/log_format_json.conf /etc/nginx/conf.d
	install -D -m 644 -v stages/services/includes/nginx/files/etc/nginx/conf.d/traccar.conf /etc/nginx/conf.d
	install -D -m 644 -v stages/services/includes/nginx/files/etc/nginx/conf.d/limits.conf /etc/nginx/conf.d
	jq -cr '.secrets.nginx.htpasswd' /etc/secrets/secrets.json > /etc/nginx/htpasswd && chown root:www-data /etc/nginx/htpasswd && chmod 440 /etc/nginx/htpasswd
	jq -cr '.secrets.nginx.htpasswd_secondary' /etc/secrets/secrets.json > /etc/nginx/htpasswd_secondary && chown root:www-data /etc/nginx/htpasswd_secondary && chmod 440 /etc/nginx/htpasswd_secondary
	jq -cr '.secrets.nginx.htpasswd_tasksync' /etc/secrets/secrets.json > /etc/nginx/htpasswd_tasksync && chown root:www-data /etc/nginx/htpasswd_tasksync && chmod 440 /etc/nginx/htpasswd_tasksync
	
nginx_test: nginx_packages nginx_certificates nginx_configs
	/sbin/nginx -t

nginx_reload: nginx_test
	systemctl reload nginx.service

nginx: nginx_reload
	@echo "$(ccgreen)Setting up nginx completed$(ccend)"

