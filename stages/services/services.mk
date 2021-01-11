services: users packages crons nginx
	@echo "Setting up services"

crons:
	bash stages/services/templates/crons.sh stages/services/files/crons/

nginx_sites:
	bash stages/services/templates/nginx/sites/api.sh
	bash stages/services/templates/nginx/sites/bank.sh
	bash stages/services/templates/nginx/sites/blog.sh
	bash stages/services/templates/nginx/sites/dav.sh
	bash stages/services/templates/nginx/sites/default.sh
	bash stages/services/templates/nginx/sites/git.sh
	bash stages/services/templates/nginx/sites/podcasts.sh
	bash stages/services/templates/nginx/sites/site.sh
	bash stages/services/templates/nginx/sites/sync.sh
	bash stages/services/templates/nginx/sites/transmission.sh

nginx_test: nginx_sites
	/sbin/nginx -t

nginx_reload: nginx_test
	systemctl reload nginx.service

nginx: nginx_reload
