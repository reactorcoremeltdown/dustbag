davfs2:
	timeout 5 test -d /var/storage/smallwastebox || mkdir -p /var/storage/smallwastebox
	bash stages/services/includes/media/templates/davfs2/secrets.sh
	install -D -m 644 stages/services/includes/media/files/etc/systemd/system/davfs2-mounts/* /etc/systemd/system
	vault-request-key password system/gocryptfs > /etc/secrets/gocryptfs
	chmod 400 /etc/secrets/gocryptfs
	test -d /var/storage/wastebox || mkdir -p /var/storage/wastebox
	systemctl daemon-reload
	systemctl enable var-storage-smallwastebox.automount gocryptfs.service
	systemctl disable var-storage-wastebox.automount var-storage-wastebox.mount
	systemctl start var-storage-smallwastebox.mount gocryptfs.service
	@echo "$(ccgreen)Setting up davfs2 mounts completed$(ccend)"

podsync:
	test -L /usr/local/bin/youtube-dl || ln -s /opt/virtualenv/bin/yt-dlp /usr/local/bin/youtube-dl
	install -D -m 755 -v stages/services/includes/media/files/usr/local/bin/podsync /usr/local/bin
	install -d -m 750 --owner=syncthing --group=syncthing /etc/podsync
	install -d -m 750 --owner=syncthing --group=syncthing /var/log/podsync
	install -D -m 644 -v stages/services/includes/media/files/etc/systemd/system/podsync.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable podsync.service
	bash stages/services/includes/media/templates/podsync/podsync.toml.sh stages/services/includes/media/variables/podsync.yaml
	systemctl restart podsync.service
	@echo "$(ccgreen)Setting up podsync completed$(ccend)"

dave: davfs2
	install -D -m 755 stages/services/includes/media/files/usr/local/bin/dave /usr/local/bin
	install -D -m 644 -v stages/services/includes/media/files/etc/systemd/system/dave.service /etc/systemd/system
	install -d -m 750 --owner=www-data --group=www-data /var/www/.dave
	install -D -m 644 -v stages/services/includes/media/files/var/www/dave/config.yaml /var/www/.dave
	systemctl daemon-reload
	systemctl enable dave.service
	systemctl restart dave.service
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

diskplayer: mpd
	install -D -m 644 stages/services/includes/media/files/etc/udev/rules.d/100-floppy-change.rules /etc/udev/rules.d
	install -D -m 755 stages/services/includes/media/files/usr/local/bin/media_mount /usr/local/bin
	test -d /mnt/floppy || mkdir -p /mnt/floppy
	test -d /usr/local/share/diskplayer || mkdir -p /usr/local/share/diskplayer
	install -D -m 644 stages/services/includes/media/files/usr/local/share/diskplayer/bleep.mp3 /usr/local/share/diskplayer
	systemctl restart udev.service
	@echo "$(ccgreen)Setting up diskplayer completed$(ccend)"

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
	dpkg-query -s mpd mpc mpdscribble > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y mpd mpc mpdscribble
	install -D -m 644 -v stages/services/includes/media/files/etc/systemd/system/mpdscribble.service.d/service.conf /etc/systemd/system/mpdscribble.service.d/service.conf
	bash stages/services/includes/media/templates/mpd/mpd.conf.sh
	bash stages/services/includes/media/templates/mpd/mpdscribble.conf.sh
	systemctl daemon-reload
	systemctl enable mpd.service mpdscribble.service
	mpc status | grep -oq playing || systemctl restart mpd.service mpdscribble.service
	@echo "$(ccgreen)Setting up mpd completed$(ccend)"
