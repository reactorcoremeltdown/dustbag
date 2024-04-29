#!/usr/bin/env bash

API_URL="https://api.rcmd.space/v6"
UA="User-Agent: ledger/expenses-tracker-0.2"

# Getting a job token
USER_TOKEN=$(cat /home/ledger/.token)
QUEUE="ledger"
GET_JOB_TOKEN=$(curl -s -XPOST -H "${UA}" --data-urlencode "token=${USER_TOKEN}" "https://api.rcmd.space/v6/token/get")
JOB_ID=$(curl -s -XPOST -H "${UA}" \
    --data-urlencode "token=${GET_JOB_TOKEN}" \
    --data-urlencode "queue=${QUEUE}" \
    "https://api.rcmd.space/v6/queue/get-job")

if [[ ${JOB_ID} != 'EOQ' ]]; then
    sleep 1
    echo "Getting job Payload"
    GET_JOB_PAYLOAD_TOKEN=$(curl -s -XPOST -H "${UA}" --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v6/token/get)
    JOB_PAYLOAD=$(curl -s -XPOST -H "${UA}" \
                --data-urlencode "token=${GET_JOB_PAYLOAD_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "https://api.rcmd.space/v6/queue/get-job-payload")
    sleep 1

    echo "Locking job"
    LOCK_JOB_TOKEN=$(curl -s -XPOST -H "${UA}" --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v6/token/get)
    curl -s -XPOST -H ${UA} \
        --data-urlencode "token=${LOCK_JOB_TOKEN}" \
        --data-urlencode "queue=${QUEUE}" \
        --data-urlencode "job=${JOB_ID}" \
        "https://api.rcmd.space/v6/queue/lock-job"

    sleep 1

    echo "Payload: ${JOB_PAYLOAD}"

    CATEGORY=$(echo "${JOB_PAYLOAD}" | jq -r '.category')
    AMOUNT=$(echo "${JOB_PAYLOAD}" | jq -r '.amount')
    DATE=$(echo "${JOB_PAYLOAD}" | jq -r '.date')
    TIMESTAMP=$(date --date "${DATE}" '+%s')
    if ! test -z ${AMOUNT}; then
            sqlite3 /home/ledger/expenses.db "insert into expenses (time, category, amount) values (${TIMESTAMP}, \"${CATEGORY}\", ${AMOUNT})"
            # echo -e "\n$(date '+%Y/%m/%d') ${DESCRIPTION}\n    ${DESTINATION_TOPIC}  ${AMOUNT}\n    ${SOURCE_TOPIC}  -${AMOUNT}\n" >> /home/ledger/ledger.book

            RATE=`sqlite3 /home/ledger/expenses.db "select (sum(amount)/30) as total from expenses where time > strftime(\"%s\", date(\"now\", \"-30 days\")) and category = \"${CATEGORY}\""`

            if (( $(echo "${RATE} > 1.65" | bc -l) )); then
                export NAME="expenses"
                export STATUS="2"
                export MESSAGE="Expenses for category ${CATEGORY} went over budget! Current spending rate is ${RATE}"

                /etc/monitoring/notifiers/gotify.sh
            fi
            echo "Unlocking job"
            UNLOCK_JOB_TOKEN=$(curl -s -XPOST -H "${UA}" --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v6/token/get)
            curl -s -XPOST -H "${UA}" \
                --data-urlencode "token=${UNLOCK_JOB_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "https://api.rcmd.space/v6/queue/unlock-job"

            sleep 1

            echo "Acknowledging job"
            ACK_JOB_TOKEN=$(curl -s -XPOST -H "${UA}" --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v6/token/get)
            curl -s -XPOST -H "${UA}" \
                --data-urlencode "token=${ACK_JOB_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "https://api.rcmd.space/v6/queue/ack-job"

    else
            echo "Failed to parse transaction amount, unlocking job"
            UNLOCK_JOB_TOKEN=$(curl -s -XPOST -H "${UA}" --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v6/token/get)
            curl -s -XPOST -H "${UA}" \
                --data-urlencode "token=${UNLOCK_JOB_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "https://api.rcmd.space/v6/queue/unlock-job"
    fi
fi
