services: users packages crons
	@echo "Setting up services"

crons:
	bash stages/services/templates/crons.sh stages/services/files/crons/
