birdhouse-setup: hdmi recorder powerbutton sonar cleanup

cleanup:
	install -D -m 755 -v stages/services/includes/system/files/usr/local/bin/birdhouse-cleanup.sh /usr/local/bin
	install -D -m 644 -v stages/services/includes/system/files/etc/systemd/system/birdhouse-cleanup.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable birdhouse-cleanup.service
	systemctl start birdhouse-cleanup.service

powerbutton:
	install -D -m 755 -v stages/services/includes/system/files/usr/local/bin/powerbutton /usr/local/bin
	install -D -m 644 -v stages/services/includes/system/files/etc/systemd/system/powerbutton.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable powerbutton.service
	systemctl start powerbutton.service
	
sonar:
	install -D -m 755 -v stages/services/includes/system/files/usr/local/bin/sonar /usr/local/bin
	install -D -m 644 -v stages/services/includes/system/files/etc/systemd/system/sonar.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable sonar.service
	systemctl start sonar.service

recorder:
	install -D -m 755 -v stages/services/includes/system/files/usr/local/bin/permanent-record /usr/local/bin
	install -D -m 644 -v stages/services/includes/system/files/etc/systemd/system/pir-capture.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable pir-capture.service
	systemctl start pir-capture.service

hdmi:
	install -D -m 644 -v stages/services/includes/system/files/etc/systemd/system/disable-hdmi.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable disable-hdmi.service
	systemctl start disable-hdmi.service
