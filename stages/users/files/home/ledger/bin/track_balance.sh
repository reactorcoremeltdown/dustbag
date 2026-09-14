#!/usr/bin/env bash

API_URL="https://api.rcmd.space/v6"
UA="User-Agent: ledger/balance-tracker-0.2"

# Getting a job token
USER_TOKEN=$(cat /home/ledger/.token)
QUEUE="balance"
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
    curl -s -XPOST -H "${UA}" \
        --data-urlencode "token=${LOCK_JOB_TOKEN}" \
        --data-urlencode "queue=${QUEUE}" \
        --data-urlencode "job=${JOB_ID}" \
        "https://api.rcmd.space/v6/queue/lock-job"

    sleep 1

    echo "Payload: ${JOB_PAYLOAD}"

    BALANCE=$(echo "${JOB_PAYLOAD}" | jq -r '.balance')
    if ! test -z ${BALANCE}; then
            sqlite3 /home/ledger/expenses.db "insert into balance (balance) values (${BALANCE})"

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
