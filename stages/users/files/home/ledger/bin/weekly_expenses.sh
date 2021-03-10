#!/usr/bin/env bash

BOT_TOKEN=`cat /home/ledger/.config/telegram_token`
CHAT_ID=`cat /home/ledger/.config/telegram_chat_id`

hledger balance --depth 1 --weekly --begin=$(date --date="today - 3 weeks" "+%Y/%m/%d") | convert label:@- /home/ledger/expenses.png
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${CHAT_ID}" -F "@/home/ledger/expenses.png"
