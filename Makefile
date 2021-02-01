all: early firewall repos packages users secrets services monitoring

lite: early repos packages_lite users

include stages/early/early.mk
include stages/firewall/firewall.mk
include stages/repos/repos.mk
include stages/packages/packages.mk
include stages/users/users.mk
include stages/secrets/secrets.mk
include stages/services/services.mk
include stages/monitoring/monitoring.mk
