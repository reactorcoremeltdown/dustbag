ifeq ($(MAKECMDGOALS),)
	PACKAGES := $(shell jq -cr '.debian.essentials[], .debian.server[]' stages/packages/variables/packages.json | xargs)
	PYTHON_PACKAGES := $(shell jq -cr '.python.server[]' stages/packages/variables/packages.json | xargs)
else ifeq($(MAKECMDGOALS), seedbox)
	PACKAGES := $(shell jq -cr '.debian.essentials[]' stages/packages/variables/packages.json | xargs)
	PYTHON_PACKAGES := $(shell jq -cr '.python.noop[]' stages/packages/variables/packages.json | xargs)
else
	PACKAGES := $(shell jq -cr '.debian.essentials[]' stages/packages/variables/packages.json | xargs)
	PYTHON_PACKAGES := $(shell jq -cr '.python.noop[]' stages/packages/variables/packages.json | xargs)
PYTHON_PACKAGES := /bin/true
endif

packages: repos
	dpkg-query -s $(PACKAGES) > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y $(PACKAGES)
	pip3 install $(PYTHON_PACKAGES)
	@echo "$(ccgreen)Installing Packages completed$(ccend)"
