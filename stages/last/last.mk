last: laminar_restart
	@echo "Last stage completed"

laminar_restart:
	echo "sleep 10 && systemctl restart laminar.service" | at now
