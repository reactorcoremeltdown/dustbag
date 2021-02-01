services: users packages crons laminar gitea nginx
	@echo "Setting up services"

crons:
	bash stages/services/templates/crons.sh stages/services/files/crons/

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
	chown -R git:git /var/lib/laminar
	systemctl daemon-reload
	systemctl restart laminar.service

nginx_sites:
	bash stages/services/templates/nginx/sites/api.sh
	bash stages/services/templates/nginx/sites/bank.sh
	bash stages/services/templates/nginx/sites/blog.sh
	bash stages/services/templates/nginx/sites/ci.sh
	bash stages/services/templates/nginx/sites/dav.sh
	bash stages/services/templates/nginx/sites/default.sh
	bash stages/services/templates/nginx/sites/git.sh
	bash stages/services/templates/nginx/sites/netdata.sh
	bash stages/services/templates/nginx/sites/notifications.sh
	bash stages/services/templates/nginx/sites/podcasts.sh
	bash stages/services/templates/nginx/sites/site.sh
	bash stages/services/templates/nginx/sites/sync.sh
	bash stages/services/templates/nginx/sites/transmission.sh

nginx_test: nginx_sites
	/sbin/nginx -t

nginx_reload: nginx_test
	systemctl reload nginx.service

nginx: nginx_reload

gitea_directory:
	install -d -m 770 --owner git --group git /etc/gitea

gitea_config: /etc/secrets/secrets.json
	bash stages/services/templates/gitea/config.sh

gitea_restart:
	systemctl restart gitea.service

gitea: gitea_directory gitea_config gitea_restart
