firewall: early apply_rules
	@echo "$(ccgreen)Firewall setup completed$(ccend)"

template_rules:
	install -d -m 755 /etc/firewall
	install -d -m 755 /etc/iptables
	bash stages/firewall/templates/input.sh stages/firewall/variables/firewall.yaml

apply_rules: template_rules
	iptables --flush INPUT
	cat /etc/firewall/iptables-input | bash
	iptables-save > /etc/iptables/rules.v4
	ip6tables --flush INPUT
	cat /etc/firewall/ip6tables-input | bash
	ip6tables-save > /etc/iptables/rules.v6
