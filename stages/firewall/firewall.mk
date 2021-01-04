firewall: early apply_rules
	@echo "Setting up firewall"

template_rules:
	bash stages/firewall/templates/input.sh stages/firewall/variables/firewall.json

apply_rules: template_rules
	iptables --flush INPUT
	cat /etc/firewall/iptables-input | bash
	iptables-save > /etc/iptables/rules.v4
	ip6tables --flush INPUT
	cat /etc/firewall/ip6tables-input | bash
	iptables-save > /etc/iptables/rules.v6
