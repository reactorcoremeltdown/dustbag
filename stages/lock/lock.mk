lock:
	test $(MOTION_SERVICE_STATUS) = "stop" || exit 0
	bash stages/lock/files/lock.sh

unlock:
	rm -f /var/lock/drone.lock
