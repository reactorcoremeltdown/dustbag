ifeq ($(MAKECMDGOALS), production)
	PYTHON_PACKAGES := $(shell yq -r '.python.server[]' stages/packages/variables/packages.yaml | xargs)
packages: packages_begin packages_generic packages_server packages_end packages_venv
else
	PYTHON_PACKAGES := $(shell yq -r '.python.noop[]' stages/packages/variables/packages.yaml | xargs)
packages: packages_begin packages_generic packages_end packages_venv
endif

packages_begin:
	iac begin packages

packages_begin:
	iac end packages

packages_server:
	iac stages/packages/configs/packages_server.yaml

packages_generic:
	iac stages/packages/configs/packages_essentials.yaml

packages_venv: repos
	mkdir -p /opt/virtualenv || true
	python3 -m venv /opt/virtualenv
	/opt/virtualenv/bin/pip3 install $(PYTHON_PACKAGES) || true
	@echo "$(ccgreen)Installing Packages completed$(ccend)"
