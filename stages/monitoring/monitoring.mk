# Main server

ifeq ($(MACHINE_ROLE), production)
MACHINE := production

monitoring: monitoring_begin wtfd_package checks wtfd prometheus monitoring_end
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"

## Fermium, the RPi 4
else ifeq ($(MACHINE_ROLE), homeserver)
MACHINE := fermium

monitoring: monitoring_begin wtfd_package checks wtfd monitoring_end
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"

else ifeq ($(MACHINE_ROLE), printserver)
MACHINE := printserver

monitoring: monitoring_begin wtfd_package checks wtfd monitoring_end
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"

else ifeq ($(MACHINE_ROLE), outpost)
MACHINE := outpost

monitoring: monitoring_begin wtfd_package checks wtfd monitoring_end
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"

endif

wtfd_package: setup_debian_repositories update_debian_repositories
	systemctl stop wtfd.service || true
	apt -y install dafuq
	cp stages/monitoring/files/configs/wtfd-standard.service /etc/systemd/system/wtfd.service
	chmod 644 /etc/systemd/system/wtfd.service

wtfd_armv6:
	systemctl stop wtfd.service || true
	apt -y install dafuq
	cp stages/monitoring/files/configs/wtfd_generic.service /etc/systemd/system/wtfd.service
	chmod 644 /etc/systemd/system/wtfd.service

wtfd_files:
	install -D -v -m 755 \
		stages/monitoring/files/bin/wtf /usr/local/bin
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
	test -d /var/www/healthchecks || mkdir -p /var/www/healthchecks
	systemctl daemon-reload
	systemctl enable wtfd.service

wtfd_restart:
	systemctl enable wtfd.service
	systemctl restart wtfd.service
	#systemctl stop wtfd.service
	#rm -f /tmp/dafuq.state
	#sleep 3
	#systemctl start wtfd.service

wtfd: wtfd_files wtfd_restart
	iac stages/monitoring/configs/wtfd.yaml
	@echo "$(ccgreen)Installing wtfd completed$(ccend)"

checks_configs:
	iac "stages/monitoring/configs/checks_$(MACHINE).yaml"
	@echo "$(ccgreen)Installing DAFUQ checks completed$(ccend)"

checks: wtfd_files checks_configs wtfd_restart

prometheus:
	iac stages/monitoring/configs/prometheus.yaml
	@echo "$(ccgreen)Installing prometheus completed$(ccend)"

monitoring_begin:
	iac begin monitoring_stage

monitoring_end:
	iac end monitoring_stage
