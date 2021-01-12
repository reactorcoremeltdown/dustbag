#!/usr/bin/env bash

source /etc/monit/plugins/okfail.sh

pubdate=`echo | openssl s_client -connect $1':5222' 2>/dev/null -starttls xmpp | openssl x509 -noout -dates | grep notAfter | cut -f 2 -d '='`
pubdate_unix=`date +%s -d "$pubdate"`
current_date=`date +%s`
let delta="pubdate_unix - current_date"
let days="delta/86400"

if test $delta -lt 864000; then
    warning "The SSL cert of $1 will expire in $days days!" "$DESCRIPTION" "$ENVIRONMENT"
elif test $delta -lt 259200; then
    fail "The SSL cert of $1 will expire in $days days!" "$DESCRIPTION" "$ENVIRONMENT"
else
    ok "SSL cert is VALID" "$DESCRIPTION" "$ENVIRONMENT"
fi
