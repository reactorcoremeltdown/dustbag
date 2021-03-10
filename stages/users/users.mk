users: early sudoers configs ledger_scripts
	bash stages/users/templates/users.sh stages/users/variables/users.json
	@echo "$(ccgreen)Setting up users completed$(ccend)"

sudoers:
	install -D -v -m 440 \
	stages/users/files/etc/sudoers.d/* /etc/sudoers.d/

configs:
	install -D -v -m 640 \
	stages/users/files/root/.gitconfig /root/

ledger_scripts:
	jq -cr '.secrets.ledger.token' /etc/secrets/secrets.json > /home/ledger/.token
	jq -cr '.secrets.telegram.bot_token' /etc/secrets/secrets.json > /home/ledger/.config/telegram_token
	jq -cr '.secrets.telegram.chat_id' /etc/secrets/secrets.json > /home/ledger/.config/telegram_chat_id
	chmod 600 /home/ledger/.token && chown ledger:ledger /home/ledger/.token /home/ledger/.config/telegram_token /home/ledger/.config/telegram_chat_id
	install -d -m 775 --owner root --group apps /var/spool/api/ledger
	install -d /home/ledger/bin
	install -D -v -m 755 stages/users/files/home/ledger/bin/track_pocket_expenses.sh /home/ledger/bin
