services: users packages crons
	@echo "Setting up services"

crons:
	bash stages/services/templates/crons.sh stages/services/files/crons/

nginx_sites:
	bash stages/services/templates/nginx/sites/
	bash stages/services/templates/nginx/sites/
	bash stages/services/templates/nginx/sites/
	bash stages/services/templates/nginx/sites/
	bash stages/services/templates/nginx/sites/
	bash stages/services/templates/nginx/sites/

