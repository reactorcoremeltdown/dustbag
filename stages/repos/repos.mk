repos: setup_debian_repositories update_debian_repositories
	@printf "`tput bold`Setting up Debian repositories completed`tput sgr0`\n"

setup_gpg_keys:
	jq -cr '.debian.repositories[].key' variables/main.json | xargs apt-key adv --fetch-keys --no-tty

setup_debian_repositories: setup_gpg_keys
	@echo "Not implemented yet"

update_debian_repositories:
	apt update
