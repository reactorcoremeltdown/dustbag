users: early sudoers
	bash stages/users/templates/users.sh variables/main.json
	@printf "`tput bold`Setting up system users complete`tput sgr0`\n"

sudoers:
	install -D -v -m 440 \
	stages/users/files/etc/sudoers.d/* /etc/sudoers.d/
