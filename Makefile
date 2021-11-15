all: early firewall repos packages users services monitoring last

lite: early repos packages_lite users_lite tinc_client

printserver: early packages_lite

include variables/colors.mk
include stages/early/early.mk
include stages/firewall/firewall.mk
include stages/repos/repos.mk
include stages/packages/packages.mk
include stages/users/users.mk
include stages/secrets/secrets.mk
include stages/services/services.mk
include stages/monitoring/monitoring.mk
include stages/last/last.mk
