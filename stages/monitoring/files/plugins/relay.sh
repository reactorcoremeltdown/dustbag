#!/usr/bin/env bash

source ${PLUGINSDIR}/okfail.sh

source <(curl -s "${1}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')

case ${CurrentStatus} in
    "0")
        ok ${Output}
        ;;
    "1")
        warning ${Output}
        ;;
    *)
        fail ${Output}
        ;;
esac
