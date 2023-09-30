lock:
ifeq($(MOTION_SERVICE_STATUS),"start")
	exit 0
endif
	bash stages/lock/files/lock.sh

unlock:
	rm -f /var/lock/drone.lock
