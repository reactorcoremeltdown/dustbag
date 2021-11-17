#!/usr/bin/env bash

cat <<EOF > /home/ledger/plot.gnu
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 600, 400
set output '/home/ledger/out.png'
set style data histogram
set xtics nomirror rotate by -45
set style fill solid border -1
set arrow from graph 0,first 25 to graph 1,first 25 nohead lc rgb "#FF0000" front
plot for [i=2:5] '/dev/stdin' using i:xtic(1) title col
EOF

#!/usr/bin/env bash

BOT_TOKEN=`cat /home/ledger/.config/telegram_token`
CHAT_ID=`cat /home/ledger/.config/telegram_chat_id`

IFS=$'\n'

textdata_food=$(mktemp)

echo -e "category\tweek_1\tweek_2\tweek_3\tweek_4" >> ${textdata_food}

for i in $(hledger -f /home/ledger/ledger.book balance -O json --depth 2 --weekly --begin=$(date --date="today - 3 weeks" "+%Y/%m/%d") food:cafe food:misc | jq -cr '.prRows[]'); do
        NAME=$(echo "${i}" | jq -cr '.prrName')
        #echo ${i}
        NUMBERS=$(echo "${i}" | jq -cr '.prrAmounts[][0].aquantity.floatingPoint' | sed "s|null|0|g" | tr "\n" "\t")
        echo -e "${NAME}\t${NUMBERS}" >> ${textdata_food}
done

gnuplot -p /home/ledger/plot.gnu < ${textdata_food}
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${CHAT_ID}" -F "photo=@/home/ledger/out.png"
rm ${textdata_food}

textdata_leisure=$(mktemp)

echo -e "category\tweek_1\tweek_2\tweek_3\tweek_4" >> ${textdata_leisure}

for i in $(hledger -f /home/ledger/ledger.book balance -O json --depth 2 --weekly --begin=$(date --date="today - 3 weeks" "+%Y/%m/%d") leisure:misc leisure:gear leisure:music leisure:sponsorship | jq -cr '.prRows[]'); do
        NAME=$(echo "${i}" | jq -cr '.prrName')
        #echo ${i}
        NUMBERS=$(echo "${i}" | jq -cr '.prrAmounts[][0].aquantity.floatingPoint' | sed "s|null|0|g" | tr "\n" "\t")
        echo -e "${NAME}\t${NUMBERS}" >> ${textdata_leisure}
done

gnuplot -p /home/ledger/plot.gnu < ${textdata_leisure}
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${CHAT_ID}" -F "photo=@/home/ledger/out.png"
rm ${textdata_leisure}

textdata_service=$(mktemp)

echo -e "category\tmonth_1\tmonth_2\tmonth_3\tmonth_4" >> ${textdata_service}

for i in $(hledger -f /home/ledger/ledger.book balance -O json --depth 2 --monthly --begin=$(date --date="today - 4 months" "+%Y/%m/%d") service:vps service:domains | jq -cr '.prRows[]'); do
        NAME=$(echo "${i}" | jq -cr '.prrName')
        #echo ${i}
        NUMBERS=$(echo "${i}" | jq -cr '.prrAmounts[][0].aquantity.floatingPoint' | sed "s|null|0|g" | tr "\n" "\t")
        echo -e "${NAME}\t${NUMBERS}" >> ${textdata_service}
done

gnuplot -p /home/ledger/plot.gnu < ${textdata_service}
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${CHAT_ID}" -F "photo=@/home/ledger/out.png"
rm ${textdata_service}
