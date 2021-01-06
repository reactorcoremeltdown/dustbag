users: early
	bash stages/users/templates/users.sh variables/main.json
	@printf "`tput bold`Setting up system users`tput sgr0`\n"
