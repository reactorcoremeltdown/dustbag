## MAIN host (runs by default)
ifeq ($(MAKECMDGOALS),)
CRONS := stages/services/files/crons/main

services: users packages motd sshd crons davfs2 laminar gitea nginx_sites nginx podsync hledger-web radicale tinc network_hacks misc prometheus podman fdroid deviceping_receiver
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Fermium, the little Pi Zero W
else ifeq ($(MAKECMDGOALS), fermium)
CRONS := stages/services/files/crons/fermium

services: users packages crons tinc_client mpd diskplayer motion bootconfig deviceping
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Fermium, the little Pi Zero W
else ifeq ($(MAKECMDGOALS), generic)

services: users packages motion deviceping
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Fermium, the little Pi Zero W
else ifeq ($(MAKECMDGOALS), seedbox)

services: users packages
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Printserver, the little Orange pi zero
else ifeq ($(MAKECMDGOALS), printserver)
CRONS := stages/services/files/crons/printserver

services: users packages crons cups nginx_printer nginx deviceping
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## All other hosts
else
services: users packages
	@echo "$(ccgreen)Setting up services completed$(ccend)"
endif

## Service targets
motd:
	install -D -v -m 644 stages/services/files/etc/motd \
		/etc/motd
	@echo "$(ccgreen)Setting up motd completed$(ccend)"

sshd_config:
	install -D -v -m 644 \
		stages/services/files/etc/ssh/sshd_config \
		/etc/ssh
	install -D -v -m 755 \
		stages/services/files/etc/ssh/login-notify.sh \
		/etc/ssh
	install -D -v -m 644 \
		stages/services/files/etc/pam.d/sshd \
		/etc/pam.d

sshd_restart:
	systemctl restart sshd.service

sshd: sshd_config sshd_restart
	@echo "$(ccgreen)Setting up sshd completed$(ccend)"

crons:
	bash stages/services/templates/crons.sh $(CRONS)
	@echo "$(ccgreen)Setting up crons completed$(ccend)"

laminar:
	install -d /etc/systemd/system/laminar.service.d
	install -D -v -m 644 \
		stages/services/files/etc/systemd/system/laminar.service.d/service.conf \
		/etc/systemd/system/laminar.service.d
	install -D -v -m 755 \
		stages/services/files/usr/local/bin/laminar.run \
		/usr/local/bin
	install -D -v -m 644 \
		stages/services/files/etc/laminar.conf /etc
	install -D -v -m 644 \
		stages/services/files/usr/local/src/rcmd-functions.mk /usr/local/src
	chown -R git:git /var/lib/laminar
	systemctl daemon-reload
	systemctl enable laminar.service
	@echo "$(ccgreen)Setting up laminar completed$(ccend)"

nginx_packages:
	dpkg-query -s nginx > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y nginx

nginx_certificates:
	bash stages/users/templates/cloudflare.sh
	test -L /etc/letsencrypt/live/rcmd.space/fullchain.pem || yes | certbot certonly --agree-tos --non-interactive --email azer.abdullaev.berlin@gmail.com --dns-cloudflare --dns-cloudflare-credentials /root/.cloudflare.ini -d rcmd.space,*.rcmd.space --preferred-challenges dns-01
	test -L /etc/letsencrypt/live/tiredsysadmin.cc/fullchain.pem || yes | certbot certonly --agree-tos --non-interactive --email azer.abdullaev.berlin@gmail.com --dns-cloudflare --dns-cloudflare-credentials /root/.cloudflare.ini -d tiredsysadmin.cc,*.tiredsysadmin.cc --preferred-challenges dns-01
	test -d /etc/nginx/ssl || mkdir -p /etc/nginx/ssl
	test -f /etc/nginx/ssl/ca.crt || openssl req  -nodes -newkey rsa:4096 -days 365 -x509 -keyout /etc/nginx/ssl/ca.key -out /etc/nginx/ssl/ca.crt -subj '/C=DE/ST=Berlin/L=Berlin/O=RCMD/OU=Funkhaus/CN=RCMD Server'

nginx_sites:
	bash stages/services/templates/nginx/sites/api.sh
	bash stages/services/templates/nginx/sites/bank.sh
	bash stages/services/templates/nginx/sites/ci.sh
	bash stages/services/templates/nginx/sites/dav.sh
	bash stages/services/templates/nginx/sites/default.sh
	bash stages/services/templates/nginx/sites/git.sh
	bash stages/services/templates/nginx/sites/graph.sh
	bash stages/services/templates/nginx/sites/netdata.sh
	bash stages/services/templates/nginx/sites/podcasts.sh
	bash stages/services/templates/nginx/sites/repo.sh
	bash stages/services/templates/nginx/sites/sync.sh
	bash stages/services/templates/nginx/sites/mood.sh

nginx_printer:
	bash stages/services/templates/nginx/sites/printer.sh

nginx_configs:
	install -D -m 644 -v stages/services/files/etc/logrotate.d/nginx /etc/logrotate.d
	install -D -m 755 -v stages/services/files/usr/local/bin/clicks_count /usr/local/bin
	install -D -m 644 -v stages/services/files/etc/nginx/conf.d/log_format_json.conf /etc/nginx/conf.d
	install -D -m 644 -v stages/services/files/etc/nginx/conf.d/traccar.conf /etc/nginx/conf.d
	install -D -m 644 -v stages/services/files/etc/nginx/conf.d/limits.conf /etc/nginx/conf.d
	jq -cr '.secrets.nginx.htpasswd' /etc/secrets/secrets.json > /etc/nginx/htpasswd && chown root:www-data /etc/nginx/htpasswd && chmod 440 /etc/nginx/htpasswd
	jq -cr '.secrets.nginx.htpasswd_secondary' /etc/secrets/secrets.json > /etc/nginx/htpasswd_secondary && chown root:www-data /etc/nginx/htpasswd_secondary && chmod 440 /etc/nginx/htpasswd_secondary
	
nginx_test: nginx_packages nginx_certificates nginx_configs
	/sbin/nginx -t

nginx_reload: nginx_test
	systemctl reload nginx.service

nginx: nginx_reload
	@echo "$(ccgreen)Setting up nginx completed$(ccend)"

gitea_directory:
	install -d -m 770 --owner git --group git /etc/gitea

gitea_config: /etc/secrets/secrets.json
	bash stages/services/templates/gitea/config.sh
	install -D -m 644 -v stages/services/files/etc/systemd/system/gitea.service /etc/systemd/system
	systemctl enable gitea.service
	systemctl daemon-reload

gitea_restart:
	systemctl restart gitea.service

gitea: gitea_directory gitea_config gitea_restart
	@echo "$(ccgreen)Setting up gitea completed$(ccend)"

davfs2:
	bash stages/services/templates/davfs2/secrets.sh
	install -D -m 644 stages/services/files/etc/systemd/system/davfs2-mounts/* /etc/systemd/system
	systemctl daemon-reload
	systemctl enable var-storage-wastebox.automount
	systemctl start var-storage-wastebox.mount
	@echo "$(ccgreen)Setting up davfs2 mounts completed$(ccend)"

podsync:
	install -d -m 750 --owner=syncthing --group=syncthing /etc/podsync
	install -d -m 750 --owner=syncthing --group=syncthing /var/log/podsync
	install -D -m 644 -v stages/services/files/etc/systemd/system/podsync.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable podsync.service
	bash stages/services/templates/podsync/podsync.toml.sh stages/services/variables/services.json
	systemctl restart podsync.service
	@echo "$(ccgreen)Setting up podsync completed$(ccend)"

gollum:
	install -D -m 644 -v stages/services/files/etc/systemd/system/gollum-wiki.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable gollum-wiki.service
	systemctl stop gollum-wiki.service
	systemctl restart gollum-wiki.service

radicale:
	jq -cr '.secrets.radicale.users' /etc/secrets/secrets.json | base64 -d > /etc/radicale/users
	chown radicale:radicale /etc/radicale/users && chmod 640 /etc/radicale/users
	install -D -m 644 -v stages/services/files/etc/radicale/config /etc/radicale
	install -D -m 644 -v stages/services/files/etc/radicale/logging /etc/radicale
	install -D -m 644 -v stages/services/files/etc/radicale/rights /etc/radicale
	install -D -m 644 -v stages/services/files/etc/systemd/system/radicale.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable radicale
	systemctl restart radicale
	@echo "$(ccgreen)Setting up radicale completed$(ccend)"

hledger-web:
	install -D -m 644 -v stages/services/files/etc/systemd/system/hledger-web.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable hledger-web
	systemctl restart hledger-web
	@echo "$(ccgreen)Setting up hledger-web completed$(ccend)"

icecast:
	bash stages/services/templates/icecast/icecast.xml.sh
	systemctl enable icecast2.service
	systemctl restart icecast2.service
	@echo "$(ccgreen)Setting up icecast completed$(ccend)"

mpd:
	dpkg-query -s mpd mpc mpdscribble > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y mpd mpc
	bash stages/services/templates/mpd/mpd.conf.sh
	bash stages/services/templates/mpd/mpdscribble.conf.sh
	systemctl enable mpd.service mpdscribble.service
	mpc status | grep -oq playing || systemctl restart mpd.service mpdscribble.service
	@echo "$(ccgreen)Setting up mpd completed$(ccend)"

tinc:
	bash stages/services/templates/tinc/configs.sh
	@echo "$(ccgreen)Setting up tinc completed$(ccend)"

tinc_client:
	bash stages/services/templates/tinc/configs_client.sh
	@echo "$(ccgreen)Setting up tinc completed$(ccend)"
	systemctl restart tinc@clusternet

registry:
	install -D -m 644 stages/services/files/etc/containers/registries.conf /etc/containers
	install -D -m 644 stages/services/files/etc/containers/containers.conf /etc/containers
	install -D -m 644 stages/services/files/etc/docker/registry/config.yml /etc/docker/registry
	systemctl restart docker-registry
	@echo "$(ccgreen)Setting up docker registry completed$(ccend)"

phockup:
	test -d /opt/phockup || mkdir -p /opt/phockup
	rsync -av stages/services/files/opt/phockup/ /opt/phockup
	ln -sf /opt/phockup/phockup.py /usr/local/bin/phockup

network_hacks:
	install -D -m 644 stages/services/files/etc/systemd/system/nat-flush.service /etc/systemd/system
	install -D -m 644 stages/services/files/etc/systemd/system/containers.target /etc/systemd/system
	systemctl daemon-reload
	systemctl enable nat-flush.service
	systemctl enable containers.target
	@echo "$(ccgreen)Setting up network hacks completed$(ccend)"

diskplayer: mpd
	install -D -m 644 stages/services/files/etc/udev/rules.d/100-floppy-change.rules /etc/udev/rules.d
	install -D -m 755 stages/services/files/usr/local/bin/media_mount /usr/local/bin
	systemctl restart udev.service
	@echo "$(ccgreen)Setting up diskplayer completed$(ccend)"

motion:
	dpkg-query -s motion > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y motion
	install -D -m 644 stages/services/files/etc/motion/motion.conf /etc/motion
	install -D -m 755 stages/services/files/usr/local/bin/webcam.sh /usr/local/bin
	systemctl $(MOTION_SERVICE_STATE) motion.service
	@echo "$(ccgreen)Setting up motion completed$(ccend)"

misc:
	install -D -m 755 stages/services/files/usr/local/bin/rcmd-space-stats /usr/local/bin
	install -D -m 755 stages/services/files/usr/local/bin/kanboard-stats /usr/local/bin
	@echo "$(ccgreen)Setting up misc scripts completed$(ccend)"

prometheus:
	bash stages/services/templates/prometheus/prometheus.yml.sh
	install -D -m 644 stages/services/files/etc/default/prometheus /etc/default
	systemctl restart prometheus.service
	@echo "$(ccgreen)Setting up prometheus completed$(ccend)"

podman:
	bash stages/services/templates/podman/podman-login.service.sh
	systemctl enable podman-login.service
	@echo "$(ccgreen)Setting up prometheus completed$(ccend)"

cups:
	apt-get -o Acquire::ForceIPv4=true install -y cups
	@echo "$(ccgreen)Setting up cups completed$(ccend)"

fdroid:
	test -d /var/lib/fdroid || mkdir /var/lib/fdroid
	bash stages/services/templates/nginx/sites/fdroid.sh
	nginx -t
	systemctl reload nginx.service
	@echo "$(ccgreen)Setting up fdroid completed$(ccend)"

deviceping:
	install -D -m 755 stages/services/files/usr/local/bin/deviceping /usr/local/bin
	@echo "$(ccgreen)Setting up deviceping completed$(ccend)"

deviceping_receiver:
	install -D -m 755 stages/services/files/usr/local/bin/deviceping-receiver /usr/local/bin
	test -d /var/spool/api/deviceping || mkdir -p /var/spool/api/deviceping
	@echo "$(ccgreen)Setting up deviceping completed$(ccend)"

bootconfig:
	install -D -m 755 stages/services/files/boot/config.txt /boot
	@echo "$(ccgreen)Setting up bootconfig completed$(ccend)"
