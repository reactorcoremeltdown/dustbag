all: early firewall repos packages users services

include stages/early/early.mk
include stages/firewall/firewall.mk
include stages/repos/repos.mk
include stages/packages/packages.mk
include stages/users/users.mk
include stages/services/services.mk
