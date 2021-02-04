users: early sudoers
	bash stages/users/templates/users.sh variables/main.json
	@echo "$(ccgreen)Setting up users complete$(ccend)"

sudoers:
	install -D -v -m 440 \
	stages/users/files/etc/sudoers.d/* /etc/sudoers.d/
