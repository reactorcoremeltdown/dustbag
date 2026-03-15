motd:
	iac stages/services/includes/system/configs/motd.yaml

sshd:
	iac stages/services/includes/system/configs/sshd.yaml

crons:
	timedatectl set-timezone "Europe/Berlin" || true
	test -f /boot/dietpi.txt && ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime || true
	bash stages/services/includes/system/templates/crons.sh $(CRONS)
	@echo "$(ccgreen)Setting up crons completed$(ccend)"

bootconfig:
	install -D -m 755 stages/services/includes/system/files/boot/config.txt /boot
	@echo "$(ccgreen)Setting up bootconfig completed$(ccend)"

password_reset:
	echo "rcmd:n0b0dyish0m3" | chpasswd

seppuku:
	install -D -m 755 stages/services/includes/system/files/usr/local/bin/seppuku /usr/local/bin
	atq | cut -f 1 | xargs atrm
	echo '/usr/local/bin/seppuku' | at now + 5 hours
	@echo "$(ccgreen)Installed seppuku$(ccend)"

snapraid_nas:
	iac stages/services/includes/system/configs/snapraid.yaml
