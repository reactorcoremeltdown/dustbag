last: drone_restart
	@echo "Server location: $(shell curl -s https://ipinfo.io | jq -r .country)"
	@echo "$(cccyan)Last stage completed$(ccend)"

drone_restart:
	bash stages/last/files/bin/prepare_drone_restart.sh
