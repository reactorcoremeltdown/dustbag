monitoring: monit wtfd netdata checks
	@printf "`tput bold`Setting up monitoring completed`tput sgr0`\n"

monit:
	apt-get purge -y monit

wtfd_files:
	install -D -v -m 755 \
		stages/monitoring/files/bin/wtfd /usr/local/bin
	install -D -v -m 644 \
		stages/monitoring/files/configs/wtfd.service /etc/systemd/system
	install -d /etc/monitoring
	install -d /etc/monitoring/configs
	install -d /etc/monitoring/plugins && \
		install -D -v -m 755 \
		stages/monitoring/files/plugins/* /etc/monitoring/plugins
	install -d /etc/monitoring/notifiers && \
		install -D -v -m 755 \
		stages/monitoring/files/handlers/* /etc/monitoring/notifiers
	systemctl daemon-reload
	systemctl enable wtfd.service

wtfd_restart:
	systemctl restart wtfd.service

wtfd: wtfd_files wtfd_restart
	@pritnf "`tput bold`Installing wtfd complete`tput sgr0`\n"

netdata_files:
	apt-get install -y netdata

netdata_restart:
	systemctl restart netdata

netdata: netdata_files
	@printf "`tput bold`Partially implemented: installing netdata complete`tput sgr0`\n"

checks_configs:
	bash stages/monitoring/templates/checks.sh stages/monitoring/variables/checks.json
	@printf "`tput bold`Partially implemented: installing monit checks complete`tput sgr0`\n"

checks: checks_configs monit_restart netdata_restart
