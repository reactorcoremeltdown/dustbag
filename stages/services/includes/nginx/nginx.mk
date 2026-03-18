nginx_proxies:
	bash stages/services/includes/nginx/templates/nginx/sites/proxies.sh

nginx_sites:
	iac stages/services/includes/nginx/configs/nginx_sites.yaml
	bash stages/services/includes/nginx/templates/nginx/sites/bank.sh
	bash stages/services/includes/nginx/templates/nginx/sites/dav.sh
	bash stages/services/includes/nginx/templates/nginx/sites/default.sh
	bash stages/services/includes/nginx/templates/nginx/sites/dm.sh
	bash stages/services/includes/nginx/templates/nginx/sites/git.sh
	bash stages/services/includes/nginx/templates/nginx/sites/podcasts.sh
	bash stages/services/includes/nginx/templates/nginx/sites/repo.sh
	bash stages/services/includes/nginx/templates/nginx/sites/sync.sh
	bash stages/services/includes/nginx/templates/nginx/sites/mood.sh
	iac stages/services/includes/nginx/configs/nginx_amnezia.yaml

nginx_printer: nginx
	bash stages/services/includes/nginx/templates/nginx/sites/printer.sh

nginx:
	iac stages/services/includes/nginx/configs/nginx_base.yaml
	@echo "$(ccgreen)Setting up nginx completed$(ccend)"
