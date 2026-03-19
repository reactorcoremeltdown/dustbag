firewall: firewall_end
	
	@echo "$(ccgreen)Firewall setup completed$(ccend)"

firewall_begin:
	iac begin firewall

firewall_production: firewall_begin
	iac stages/firewall/configs/firewall_base.yaml
	iac stages/firewall/configs/firewall_rules_production.yaml

firewall_end: firewall_production
	iac end firewall
