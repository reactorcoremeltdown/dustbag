last: laminar_restart
	@echo "$(cccyan)Last stage completed$(ccend)"

laminar_restart:
	echo "sleep 10 && systemctl restart laminar.service" | at now
