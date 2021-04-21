#!/usr/bin/env bash

BOT_TOKEN=`cat /home/ledger/.config/telegram_token`
CHAT_ID=`cat /home/ledger/.config/telegram_chat_id`

hledger -f /home/ledger/ledger.book balance --depth 2 --weekly --begin=$(date --date="today - 3 weeks" "+%Y/%m/%d") | convert -font /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf -pointsize 24 -resize 1024x768 label:@- /home/ledger/expenses.png
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${CHAT_ID}" -F "photo=@/home/ledger/expenses.png"
