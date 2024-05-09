#!/usr/bin/env bash

IFS=$'\n'

YESTERDAY=`date --date "yesterday" "+%Y-%m-%d"`
TIMESTAMP=`date --date "${YESTERDAY} 20:00" "+%s"`

sqlite3 /var/storage/wastebox/Gadgetbridge/Gadgetbridge.db '.mode json' '.once /tmp/gadgetbridge-live.json' "select * from HUAWEI_ACTIVITY_SAMPLE where TIMESTAMP > ${TIMESTAMP} and RAW_KIND != '-1'"

ADD_DELTA=0
CURRENT_TIMESTAMP=0
SUM=0

for i in `jq -cr '.[]' /tmp/gadgetbridge-live.json`; do
    NEW_TIMESTAMP=`echo "$i" | jq '.TIMESTAMP'`
    ACTIVITY=`echo "$i" | jq '.RAW_KIND'`
    DELTA=`echo "${NEW_TIMESTAMP}-${CURRENT_TIMESTAMP}" | bc`
    if [ ${ADD_DELTA} = "1" ]; then
        SUM=`echo "${SUM} + ${DELTA}" | bc`
        # if [ ${DELTA} != "0" ]; then
        #     echo "Event recorded at $(date --date @${NEW_TIMESTAMP})"
        # fi
    fi
    if [ ${ACTIVITY} = "6" ] || [ ${ACTIVITY} = "7" ]; then
        ADD_DELTA=1
    else
        ADD_DELTA=0
    fi
    CURRENT_TIMESTAMP=${NEW_TIMESTAMP}
    # echo "Delta is ${DELTA}"
done


SCORE=`echo "scale=2; ${SUM}/3600" | bc`

echo "Result is ${SCORE}"

echo "insert into sleep(score) values(${SCORE})" | sqlite3 /home/ledger/expenses.db

rm -fr /tmp/gadgetbridge-live.json
