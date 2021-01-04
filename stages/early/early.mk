UNAME := $(shell uname)
early:
	@echo "Early stage"
	jq --version
	test $(UNAME) = "Linux" || exit 1
	if ! test -f /etc/default/earlystageconfigs; then \
		echo "provisioning done" > /etc/default/earlystageconfigs; \
	fi
