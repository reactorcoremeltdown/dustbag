motd:
	install -D -v -m 644 stages/services/includes/system/files/etc/motd \
		/etc/motd
	@echo "$(ccgreen)Setting up motd completed$(ccend)"

sshd_config:
	install -D -v -m 644 \
		stages/services/includes/system/files/etc/ssh/sshd_config \
		/etc/ssh
	install -D -v -m 755 \
		stages/services/includes/system/files/etc/ssh/login-notify.sh \
		/etc/ssh
	install -D -v -m 644 \
		stages/services/includes/system/files/etc/pam.d/sshd \
		/etc/pam.d

sshd_restart:
	systemctl restart sshd.service

sshd: sshd_config sshd_restart
	@echo "$(ccgreen)Setting up sshd completed$(ccend)"

crons:
	timedatectl set-timezone "Europe/Berlin" || true
	test -f /boot/dietpi.txt && ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime || true
	bash stages/services/includes/system/templates/crons.sh $(CRONS)
	@echo "$(ccgreen)Setting up crons completed$(ccend)"

tinc:
	bash stages/services/includes/system/templates/tinc/configs.sh
	@echo "$(ccgreen)Setting up tinc completed$(ccend)"

tinc_client:
	bash stages/services/includes/system/templates/tinc/configs_client.sh
	@echo "$(ccgreen)Setting up tinc completed$(ccend)"
	systemctl restart tinc@clusternet

bootconfig:
	install -D -m 755 stages/services/includes/system/files/boot/config.txt /boot
	@echo "$(ccgreen)Setting up bootconfig completed$(ccend)"

password_reset:
	echo "rcmd:n0b0dyish0m3" | chpasswd

pki:
	install -D -m 755 -v stages/services/includes/system/files/usr/local/bin/genpfx /usr/local/bin

seppuku:
	install -D -m 755 stages/services/includes/system/files/usr/local/bin/seppuku /usr/local/bin
	atq | cut -f 1 | xargs atrm
	echo '/usr/local/bin/seppuku' | at now + 5 hours
	@echo "$(ccgreen)Installed seppuku$(ccend)"
