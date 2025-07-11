# Main server

ifeq ($(MAKECMDGOALS), production)
MACHINE := production

monitoring: wtfd_package checks wtfd
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"

## Fermium, the little Pi Zero W
else ifeq ($(MAKECMDGOALS), fermium)
MACHINE := fermium

monitoring: wtfd_package checks wtfd
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"

else ifeq ($(MAKECMDGOALS), printserver)
MACHINE := printserver

monitoring: wtfd_armv6 checks wtfd
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"

else ifeq ($(MAKECMDGOALS), outpost)
MACHINE := outpost

monitoring: wtfd_package checks wtfd
	cat stages/monitoring/files/configs/wtfd_generic.service > /etc/systemd/system/wtfd.service
	systemctl daemon-reload && systemctl restart wtfd
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"

endif

wtfd_package:
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
	@echo "$(ccgreen)Installing wtfd completed$(ccend)"

checks_configs:
	bash stages/monitoring/templates/checks.sh stages/monitoring/variables/checks.yaml $(MACHINE)
	@echo "$(ccgreen)Installing DAFUQ checks completed$(ccend)"

checks: wtfd_files checks_configs wtfd_restart
