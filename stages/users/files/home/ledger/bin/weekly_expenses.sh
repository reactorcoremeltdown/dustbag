#!/usr/bin/env bash

BOT_TOKEN=`cat /home/ledger/.config/telegram_token`
CHAT_ID=`cat /home/ledger/.config/telegram_chat_id`

hledger -f /home/ledger/ledger.book balance --depth 2 --weekly --begin=$(date --date="today - 3 weeks" "+%Y/%m/%d") > /home/ledger/report.txt

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?parse_mode=html&chat_id=${CHAT_ID}" -H "Content-Type: application/json" -d "{ \"text\": \"<code>$(cat /home/ledger/report.txt)</code>\" }"

rm -f /home/ledger/report.txt
