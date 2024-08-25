define enable
	systemctl daemon-reload
	systemctl enable $(1)
	systemctl stop $(1)
	systemctl restart $(1)
endef

define disable
	systemctl daemon-reload
	systemctl disable $(1)
	systemctl stop $(1)
endef

define installfile
	install -D -m 644 $(1) $(2) $(3)
endef

define installexec
	install -D -m 755 $(1) $(2) $(3)
endef
