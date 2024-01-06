ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

mpd:
	dpkg-query -s mpd mpc mpdscribble > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y mpd mpc mpdscribble
	install -D -m 644 -v $(ROOT_DIR)/files/etc/systemd/system/mpdscribble.service.d/service.conf /etc/systemd/system/mpdscribble.service.d/service.conf
	bash $(ROOT_DIR)/templates/mpd/mpd.conf.sh
	bash $(ROOT_DIR)/templates/mpd/mpdscribble.conf.sh
	systemctl daemon-reload
	systemctl enable mpd.service mpdscribble.service
	mpc status | grep -oq playing || systemctl restart mpd.service mpdscribble.service
	@echo "$(ccgreen)Setting up mpd completed$(ccend)"

