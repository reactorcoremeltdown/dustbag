ifeq ($(MAKECMDGOALS),)
	PACKAGES := $(shell jq -cr '.debian.packages[]' stages/packages/variables/packages.json | xargs)
PYTHON_PACKAGES := pip3 install youtube-dl tqdm==4.62.2
else
	PACKAGES := $(shell jq -cr '.debian.packages_lite[]' stages/packages/variables/packages.json | xargs)
PYTHON_PACKAGES := /bin/true
endif

packages: repos
	dpkg-query -s $(PACKAGES) > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y $(PACKAGES)
	$(PYTHON_PACKAGES)
	@echo "$(ccgreen)Installing Debian packages completed$(ccend)"
