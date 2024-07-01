#!/usr/bin/env bash

case $NAME in
  "motion")
    if [[ ${STATUS} = '1' ]]; then
      systemctl enable motion.service && systemctl start motion.service
    else
      systemctl disable motion.service && systemctl stop motion.service
    fi
    ;;
  *)
    echo "No service defined"
    ;;
esac
