services: users packages crons laminar nginx
	@echo "Setting up services"

crons:
	bash stages/services/templates/crons.sh stages/services/files/crons/

laminar:
	install -d /etc/systemd/system/laminar.service.d/
	install -D -v -m 644 \
		stages/services/files/etc/systemd/system/laminar.service.d/service.conf \
		/etc/systemd/system/laminar.service.d
	systemctl daemon-reload

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
