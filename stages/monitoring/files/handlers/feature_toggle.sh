#!/usr/bin/env bash

case $NAME in
  "ft_motion")
    if [[ ${STATUS} = '0' ]]; then
      systemctl enable motion.service && systemctl start motion.service
    else
      systemctl disable motion.service && systemctl stop motion.service
    fi
    ;;
  *)
    echo "No service defined"
    ;;
esac
