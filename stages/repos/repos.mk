repos: setup_gpg_keys
	@printf "`tput bold`Setting up Debian repositories completed`tput sgr0`\n"

setup_gpg_keys:
	jq -cr '.debian.repositories[].key' variables/main.json | xargs apt-key adv --fetch-keys --no-tty
