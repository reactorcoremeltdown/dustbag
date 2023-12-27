#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

EXPIRY_DATE=`whois "${1}" | grep 'Registry Expiry Date' | cut -f 2- -d ':'`

TIMESTAMP=`date --date "${EXPIRY_DATE}" '+%s'`
CURRENT_TIMESTAMP=`date '+%s'`

DELTA=`echo "(${TIMESTAMP} - ${CURRENT_TIMESTAMP})/86400" | bc`

if test "${DELTA}" -lt 6; then
    warning "The domain ${1} expires in ${DELTA} days.\\nGo to https://namecheap.com to verify renewal status."
elif test "${DELTA}" -lt 3; then
    fail "The domain ${1} expires in ${DELTA} days!\\nGo to https://namecheap.com ASAP to fix renewal process!"
else
    ok "The domain ${1} expires in ${DELTA} days."
fi
