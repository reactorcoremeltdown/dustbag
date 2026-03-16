davfs2:
	timeout 5 test -d /var/storage/smallwastebox || mkdir -p /var/storage/smallwastebox
	grep -oq "managed by dustbag" /etc/davfs2/secrets || (vault-request-unlock && bash stages/services/includes/media/templates/davfs2/secrets.sh)
	install -D -m 644 stages/services/includes/media/files/etc/systemd/system/davfs2-mounts/* /etc/systemd/system
	test -f /etc/secrets/gocryptfs || (vault-request-unlock && vault-request-key password system/gocryptfs > /etc/secrets/gocryptfs)
	chmod 400 /etc/secrets/gocryptfs
	test -d /var/storage/wastebox || mkdir -p /var/storage/wastebox
	test -d /var/lib/chatserver_secondary || mkdir -p /var/lib/chatserver_secondary
	systemctl daemon-reload
	systemctl enable var-storage-smallwastebox.automount var-lib-chatserver_secondary.automount
	systemctl disable var-storage-wastebox.automount var-storage-wastebox.mount
	systemctl start var-storage-smallwastebox.mount var-lib-chatserver_secondary.mount
	@echo "$(ccgreen)Setting up davfs2 mounts completed$(ccend)"

wastebox:
	install -D -m 644 stages/services/includes/media/files/etc/systemd/system/davfs2-mounts/* /etc/systemd/system
	test -d /var/storage/wastebox || mkdir -p /var/storage/wastebox
	systemctl daemon-reload
	systemctl enable var-storage-wastebox.automount var-storage-wastebox.mount
	@echo "$(ccgreen)Setting up wastebox mounts completed$(ccend)"

podsync:
	iac stages/services/includes/media/configs/podsync.yaml
	@echo "$(ccgreen)Setting up podsync completed$(ccend)"

dave:
	iac stages/services/includes/media/configs/dave.yaml
	@echo "$(ccgreen)Setting up dave completed$(ccend)"

radicale:
	jq -cr '.secrets.radicale.users' /etc/secrets/secrets.json | base64 -d > /etc/radicale/users
	chown radicale:radicale /etc/radicale/users && chmod 640 /etc/radicale/users
	install -D -m 644 -v stages/services/includes/media/files/etc/radicale/config /etc/radicale
	install -D -m 644 -v stages/services/includes/media/files/etc/radicale/logging /etc/radicale
	install -D -m 644 -v stages/services/includes/media/files/etc/radicale/rights /etc/radicale
	install -D -m 644 -v stages/services/includes/media/files/etc/systemd/system/radicale.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable radicale
	systemctl restart radicale
	@echo "$(ccgreen)Setting up radicale completed$(ccend)"

phockup:
	test -d /opt/phockup || mkdir -p /opt/phockup
	rsync -av stages/services/includes/media/files/opt/phockup/ /opt/phockup
	ln -sf /opt/phockup/phockup.py /usr/local/bin/phockup
	install -D -m 755 stages/services/includes/media/files/usr/local/bin/phockup-wrapper /usr/local/bin

motion:
	dpkg-query -s motion > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y motion
	install -D -m 644 stages/services/includes/media/files/etc/motion/motion.conf /etc/motion
	install -D -m 755 stages/services/includes/media/files/usr/local/bin/webcam.sh /usr/local/bin
	systemctl $(MOTION_SERVICE_STATE) motion.service
	@echo "$(ccgreen)Setting up motion completed$(ccend)"

cups: nginx_printer
	apt-get -o Acquire::ForceIPv4=true install -y cups avahi-daemon hpijs-ppds printer-driver-hpijs
	install -D -m 644 stages/services/includes/media/files/etc/cups/cupsd.conf /etc/cups
	systemctl restart cups.service
	@echo "$(ccgreen)Setting up cups completed$(ccend)"

mpd:
	iac stages/services/includes/media/configs/mpd.yaml
