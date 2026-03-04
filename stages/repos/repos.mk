ifeq ($(MACHINE_ROLE), production)
repos: setup_debian_repositories reprepro
	@echo "$(ccgreen)Setting up Debian repositories completed$(ccend)"
else
repos: setup_debian_repositories
	@echo "$(ccgreen)Setting up Debian repositories completed$(ccend)"
endif

setup_debian_repositories:
	bash stages/repos/templates/repo.sh stages/repos/variables/repos.yaml $(MACHINE_ROLE)

reprepro:
	apt -y install reprepro
	bash stages/repos/templates/reprepro.sh stages/repos/variables/repos.yaml
