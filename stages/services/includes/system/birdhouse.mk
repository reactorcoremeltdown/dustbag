birdhouse: cleanup

cleanup:
	install -D -m 755 -v stages/services/includes/system/files/usr/local/bin/birdhouse-cleanup.sh /usr/local/bin
	install -D -m 644 -v stages/services/includes/system/files/etc/systemd/system/birdhouse-cleanup.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable birdhouse-cleanup.service
	systemctl start birdhouse-cleanup.service

#powerbutton:
