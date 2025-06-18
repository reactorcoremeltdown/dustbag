#!/usr/bin/env bash

API_URL="https://api.rcmd.space/v6"
UA="User-Agent: ledger/alert-fatigue"

# Getting a job token
USER_TOKEN=$(cat /home/ledger/.token)
QUEUE="alert-fatigue"
GET_JOB_TOKEN=$(curl -s -H "${UA}" -XPOST --data-urlencode "token=${USER_TOKEN}" ${API_URL}/token/get)
JOB_ID=$(curl -s -XPOST -H "${UA}"\
    --data-urlencode "token=${GET_JOB_TOKEN}" \
    --data-urlencode "queue=${QUEUE}" \
    "${API_URL}/queue/get-job")

if [[ ${JOB_ID} != 'EOQ' ]]; then
    sleep 1
    echo "Getting job Payload"
    GET_JOB_PAYLOAD_TOKEN=$(curl -s -H "${UA}" -XPOST --data-urlencode "token=${USER_TOKEN}" ${API_URL}/token/get)
    JOB_PAYLOAD=$(curl -s -XPOST -H "${UA}" \
                --data-urlencode "token=${GET_JOB_PAYLOAD_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "${API_URL}/queue/get-job-payload")
    sleep 1

    echo "Locking job"
    LOCK_JOB_TOKEN=$(curl -s -H "${UA}" -XPOST --data-urlencode "token=${USER_TOKEN}" ${API_URL}/token/get)
    curl -s -XPOST -H "${UA}" \
        --data-urlencode "token=${LOCK_JOB_TOKEN}" \
        --data-urlencode "queue=${QUEUE}" \
        --data-urlencode "job=${JOB_ID}" \
        "${API_URL}/queue/lock-job"

    sleep 1

    echo "Payload: ${JOB_PAYLOAD}"

    if ! test -z ${SCORE}; then
            sqlite3 /home/ledger/expenses.db "insert into alert_fatigue (name) values (${JOB_PAYLOAD})"
            # echo -e "\n$(date '+%Y/%m/%d') ${DESCRIPTION}\n    ${DESTINATION_TOPIC}  ${AMOUNT}\n    ${SOURCE_TOPIC}  -${AMOUNT}\n" >> /home/ledger/ledger.book

            echo "Unlocking job"
            UNLOCK_JOB_TOKEN=$(curl -s -H "${UA}" -XPOST --data-urlencode "token=${USER_TOKEN}" ${API_URL}/token/get)
            curl -s -XPOST -H "${UA}" \
                --data-urlencode "token=${UNLOCK_JOB_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "${API_URL}/queue/unlock-job"

            sleep 1

            echo "Acknowledging job"
            ACK_JOB_TOKEN=$(curl -s -H "${UA}" -XPOST --data-urlencode "token=${USER_TOKEN}" ${API_URL}/token/get)
            curl -s -XPOST -H "${UA}"\
                --data-urlencode "token=${ACK_JOB_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "${API_URL}/queue/ack-job"

    else
            echo "Failed to parse transaction amount, unlocking job"
            UNLOCK_JOB_TOKEN=$(curl -s -H "${UA}" -XPOST --data-urlencode "token=${USER_TOKEN}" ${API_URL}/token/get)
            curl -s -XPOST -H "${UA}"\
                --data-urlencode "token=${UNLOCK_JOB_TOKEN}" \
                --data-urlencode "queue=${QUEUE}" \
                --data-urlencode "job=${JOB_ID}" \
                "${API_URL}/queue/unlock-job"
    fi
fi
