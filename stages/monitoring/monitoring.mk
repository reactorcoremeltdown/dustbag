monitoring: monit checks
	@echo "Not implemented yet"

monit:
	apt-get install -y monit
	cp -pR stages/monitoring/files/plugins /etc/monit/
	cp -pR stages/monitoring/files/handlers /etc/monit/
	cp -pR stages/monitoring/files/scripts /etc/monit/
	@echo "Not implemented yet"

checks:
	@echo "Not implemented yet"
