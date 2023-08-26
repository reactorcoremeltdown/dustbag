#!/usr/bin/env bash

# Getting a job token
USER_TOKEN=$(cat /home/ledger/.token)
QUEUE="snacks"
GET_JOB_TOKEN=$(curl -s -XPOST --data-urlencode "token=${USER_TOKEN}" "https://api.rcmd.space/v5/token/get")
JOB_ID=$(curl -s -XPOST \
    --data-urlencode "token=${GET_JOB_TOKEN}" \
    --data-urlencode "queue=${QUEUE}" \
    "https://api.rcmd.space/v5/queue/get-job")

if [[ ${JOB_ID} != 'EOQ' ]]; then
    sleep 1
    echo "Getting job Payload"
    GET_JOB_PAYLOAD_TOKEN=$(curl -s -XPOST --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v5/token/get)
    JOB_PAYLOAD=$(curl -s -XPOST \
                --data-urlencode "token=${GET_JOB_PAYLOAD_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "https://api.rcmd.space/v5/queue/get-job-payload")
    sleep 1

    echo "Locking job"
    LOCK_JOB_TOKEN=$(curl -s -XPOST --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v5/token/get)
    curl -s -XPOST \
        --data-urlencode "token=${LOCK_JOB_TOKEN}" \
        --data-urlencode "queue=${QUEUE}" \
        --data-urlencode "job=${JOB_ID}" \
        "https://api.rcmd.space/v5/queue/lock-job"

    sleep 1

    echo "Payload: ${JOB_PAYLOAD}"

    SCORE=$(echo "${JOB_PAYLOAD}" | jq -r '.score')
    if ! test -z ${SCORE}; then
            sqlite3 /home/ledger/expenses.db "insert into snacks (score) values (${SCORE})"
            # echo -e "\n$(date '+%Y/%m/%d') ${DESCRIPTION}\n    ${DESTINATION_TOPIC}  ${AMOUNT}\n    ${SOURCE_TOPIC}  -${AMOUNT}\n" >> /home/ledger/ledger.book

            echo "Unlocking job"
            UNLOCK_JOB_TOKEN=$(curl -s -XPOST --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v5/token/get)
            curl -s -XPOST \
                --data-urlencode "token=${UNLOCK_JOB_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "https://api.rcmd.space/v5/queue/unlock-job"

            sleep 1

            echo "Acknowledging job"
            ACK_JOB_TOKEN=$(curl -s -XPOST --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v5/token/get)
            curl -s -XPOST \
                --data-urlencode "token=${ACK_JOB_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "https://api.rcmd.space/v5/queue/ack-job"

    else
            echo "Failed to parse transaction amount, unlocking job"
            UNLOCK_JOB_TOKEN=$(curl -s -XPOST --data-urlencode "token=${USER_TOKEN}" https://api.rcmd.space/v5/token/get)
            curl -s -XPOST \
                --data-urlencode "token=${UNLOCK_JOB_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "https://api.rcmd.space/v5/queue/unlock-job"
    fi
fi
