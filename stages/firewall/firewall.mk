firewall: early rules
	@echo "Setting up firewall"

rules:
	bash stages/firewall/templates/input.sh stages/firewall/variables/firewall.json
