monitoring: monit checks
	@echo "Not implemented yet"

monit_files:
	apt-get install -y monit
	install -D -v -m 700 \
		stages/monitoring/files/configs/monitrc /etc/monit
	install -d /etc/monit/plugins && \
		install -D -v -m 755 \
		stages/monitoring/files/plugins/* /etc/monit/plugins
	install -d /etc/monit/handlers && \
		install -D -v -m 755 \
		stages/monitoring/files/handlers/* /etc/monit/handlers
	install -d /etc/monit/scripts && \
		install -D -v -m 755 \
		stages/monitoring/files/scripts/* /etc/monit/scripts
	@printf "`tput bold`Partially implemented: installing monit complete`tput sgr0`\n"

monit_restart:
	systemctl restart monit.service

monit: monit_files monit_restart

checks_configs:
	bash stages/monitoring/templates/checks.sh stages/monitoring/variables/checks.json
	@printf "`tput bold`Partially implemented: installing monit checks complete`tput sgr0`\n"

checks: checks_configs monit_restart
