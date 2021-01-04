UNAME := $(shell uname)
early:
	@echo "Early stage"
	jq --version
	test $(UNAME) = "Linux" || exit 1
	if ! test -f /etc/defaults/earlystageconfigs; then
		echo "provisioning done" > /etc/defaults/earlystageconfigs
	fi
