#!/bin/bash

# shipper.sh
# Ships Kafka topics and offsets to GCP Storage using Linkedin Burrow

while getopts h:s:r:i:b:f: option
do
  case "${option}"
  in
    h) BURROW_HOST=${OPTARG};;
    s) OAUTH2_CLIENT_SECRET=${OPTARG};;
    r) OAUTH2_REFRESH_TOKEN=${OPTARG};;
    i) OAUTH2_CLIENT_ID=${OPTARG};;
    b) GCP_BUCKET=${OPTARG};;
    f) JSON_FILENAME=${OPTARG};;
  esac
done

# GET TOPICS AND OFFSETS
if BURROW_GET_TOPICS_CURL=$(curl "${BURROW_HOST}/v3/kafka/aws-msk/topic"); then
    KAFKA_TOPICS=$(echo $BURROW_GET_TOPICS_CURL | grep -Po '"topics":.*",'|awk -F':' '{print $2}')
    KAFKA_TOPICS="${KAFKA_TOPICS::-10}"
    KAFKA_TOPICS="${KAFKA_TOPICS:1:-1}"
    
    IFS=',' read -r -a TOPICS <<< "$KAFKA_TOPICS"
    
    # BUILD JSON PAYLOAD
    JSON='[{'
    for TOPIC in "${TOPICS[@]}"
    do
        TOPIC=${TOPIC:1:-1}
        if BURROW_GET_OFFSETS_CURL=$(curl "${BURROW_HOST}/v3/kafka/aws-msk/topic/${TOPIC}"); then
            OFFSETS=$(echo $BURROW_GET_OFFSETS_CURL | grep -Po '"offsets":.*?[^\\]",'|awk -F':' '{print $2}')

            if [ -z "$OFFSETS" ]
            then
                # TOPIC NOT FOUND, DELETED ETC
                echo "TOPIC DOES NOT EXISTS ANYMORE. SKIPPING.."
            else
                # TOPIC FOUND
                OFFSETS="${OFFSETS:1:-11}"

                JSON="${JSON} \"${TOPIC}\":\"${OFFSETS}\"," 
            fi

        fi
    done
    JSON="${JSON::-1}"
    JSON="${JSON}}]"

    # DISPLAY JSON PAYLOAD
    echo "JSON: ${JSON}"

    # REQUEST FOR NEW GCP TOKEN
    GCP_CURL=$(curl --location --request POST 'https://oauth2.googleapis.com/token' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode "client_secret=${OAUTH2_CLIENT_SECRET}" \
    --data-urlencode "grant_type=refresh_token" \
    --data-urlencode "refresh_token=${OAUTH2_REFRESH_TOKEN}" \
    --data-urlencode "client_id=${OAUTH2_CLIENT_ID}")

    # PLUCK TOKEN
    GCP_TOKEN=$(echo $GCP_CURL | grep -Po '"access_token":.*?[^\\]",'|awk -F':' '{print $2}')

    # SEND KAFKA TOPICS + OFFSETS TO GCP STORAGE
    GCP_STORAGE_CURL=$(curl --location --request POST "https://storage.googleapis.com/upload/storage/v1/b/${GCP_BUCKET}/o?uploadType=media&name=${JSON_FILENAME}" \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${GCP_TOKEN}" \
    --data "${JSON}")

    echo $GCP_STORAGE_CURL
fi
