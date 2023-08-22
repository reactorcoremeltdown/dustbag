lock:
	bash stages/lock/files/lock.sh

unlock:
	rm -f /var/lock/drone.lock
