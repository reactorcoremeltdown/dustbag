ifeq ($(MAKECMDGOALS), production)
USERSDB := stages/users/variables/users.yaml

users: early accounts sudoers configs ledger_scripts
	@echo "$(ccgreen)Setting up users completed$(ccend)"
else
USERSDB := stages/users/variables/users_lite.yaml

users: early accounts sudoers
	@echo "$(ccgreen)Setting up users completed$(ccend)"
endif

accounts:
	bash stages/users/templates/users.sh $(USERSDB)

sudoers:
	apt install -y sudo
	install -D -v -m 440 \
	stages/users/files/etc/sudoers.d/* /etc/sudoers.d/

configs:
	install -D -v -m 640 \
	stages/users/files/root/.gitconfig /root/

ledger_scripts:
	install -d -m 755 --owner ledger --group ledger /home/ledger/.config
	jq -cr '.secrets.ledger.token' /etc/secrets/secrets.json > /home/ledger/.token
	jq -cr '.secrets.telegram.bot_token' /etc/secrets/secrets.json > /home/ledger/.config/telegram_token
	jq -cr '.secrets.telegram.chat_id' /etc/secrets/secrets.json > /home/ledger/.config/telegram_chat_id
	jq -cr '.secrets.kanboard.secret' /etc/secrets/secrets.json > /home/ledger/.config/kanboard_secret
	chmod 600 /home/ledger/.token /home/ledger/.config/* && chown ledger:ledger /home/ledger/.token /home/ledger/.config/*
	install -d -m 775 --owner root --group apps /var/spool/api/ledger
	install -d /home/ledger/bin
	install -D -v -m 755 stages/users/files/home/ledger/bin/* /home/ledger/bin
