last: laminar_restart
	@echo "Last stage completed"

laminar_restart:
	echo "systemctl restart laminar.service" | at 'now + 10'
