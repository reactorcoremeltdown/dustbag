monitoring: wtfd netdata checks
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"

wtfd_files:
	install -D -v -m 755 \
		stages/monitoring/files/bin/wtfd /usr/local/bin
	install -D -v -m 755 \
		stages/monitoring/files/bin/wtf /usr/local/bin
	install -D -v -m 644 \
		stages/monitoring/files/configs/wtfd.service /etc/systemd/system
	install -d /etc/monitoring && \
		install -D -v -m 644 \
		stages/monitoring/files/configs/config.ini /etc/monitoring
	install -d /etc/monitoring/configs
	install -d /etc/monitoring/plugins && \
		install -D -v -m 755 \
		stages/monitoring/files/plugins/* /etc/monitoring/plugins
	install -d /etc/monitoring/notifiers && \
		install -D -v -m 755 \
		stages/monitoring/files/handlers/* /etc/monitoring/notifiers
	install -d /etc/monitoring/scripts && \
		install -D -v -m 755 \
		stages/monitoring/files/scripts/* /etc/monitoring/scripts
	systemctl daemon-reload
	systemctl enable wtfd.service

wtfd_restart:
	systemctl restart wtfd.service

wtfd: wtfd_files wtfd_restart
	@echo "$(ccgreen)Installing wtfd complete$(ccend)"

netdata_files:
	apt-get install -y netdata

netdata_restart:
	systemctl restart netdata

netdata: netdata_files
	@echo "$(ccgreen)Installing netdata complete$(ccend)"

checks_configs:
	bash stages/monitoring/templates/checks.sh stages/monitoring/variables/checks.json
	@echo "$(ccgreen)Installing DAFUQ checks complete$(ccend)"

checks: checks_configs wtfd_restart
