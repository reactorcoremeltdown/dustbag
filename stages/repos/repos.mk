repos: setup_debian_repositories update_debian_repositories
	@printf "`tput bold`Setting up Debian repositories completed`tput sgr0`\n"

setup_debian_repositories:
	bash stages/repos/templates/repo.sh variables/main.json

update_debian_repositories:
	apt update
