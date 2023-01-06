last: drone_restart
	@echo "$(cccyan)Last stage completed$(ccend)"

drone_restart:
	bash stages/last/files/bin/prepare_drone_restart.sh
