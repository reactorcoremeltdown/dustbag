repos: setup_debian_repositories update_debian_repositories
	@echo "$(ccgreen)Setting up Debian repositories completed$(ccend)"

setup_debian_repositories:
	bash stages/repos/templates/repo.sh variables/main.json

update_debian_repositories:
	apt update
