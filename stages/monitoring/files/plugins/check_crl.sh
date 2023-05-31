#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

pubdate=`echo | openssl crl -in $1 -noout -text 2>/dev/null | grep 'Next Update:' | sed 's|^.*Next Update: ||g'`
pubdate_unix=`date +%s -d "$pubdate"`
current_date=`date +%s`
let delta="pubdate_unix - current_date"
let days="delta/86400"

if test $delta -lt 864000; then
    warning "The CRL at $1 will expire in $days days!" "$DESCRIPTION" "$ENVIRONMENT"
elif test $delta -lt 259200; then
    fail "The CRL at $1 will expire in $days days!" "$DESCRIPTION" "$ENVIRONMENT"
else
    ok "CRL is VALID for ${days} days." "$DESCRIPTION" "$ENVIRONMENT"
fi
