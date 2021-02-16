users: early sudoers configs
	bash stages/users/templates/users.sh stages/users/variables/users.json
	@echo "$(ccgreen)Setting up users completed$(ccend)"

sudoers:
	install -D -v -m 440 \
	stages/users/files/etc/sudoers.d/* /etc/sudoers.d/

configs:
	install -D -v -m 640 \
	stages/users/files/root/.gitconfig /root/
