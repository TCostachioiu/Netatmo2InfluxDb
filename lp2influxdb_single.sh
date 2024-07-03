#!/bin/bash

set -e

# InfluxDB configuration
HOST=${INFLUXDB_HOST:-localhost}
PORT=${INFLUXDB_PORT:-8086}
BUCKET=${INFLUXDB_BUCKET:-Netatmo2}
ORG=${INFLUXDB_ORG:-your_org_name}
TOKEN=${INFLUXDB_TOKEN:-your_token}

PRECISION=s

# File to import (given as argument)
FILE="$1"

# Check if file is provided and exists
if [[ -z "$FILE" ]]; then
    echo "Error: No file provided. Usage: ./lp2influxdb_single.sh file.lp"
    exit 1
elif [[ ! -f "$FILE" ]]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi

# Check if HOST, PORT, BUCKET, ORG, and TOKEN are set
echo "Using InfluxDB host: $HOST"
echo "Using InfluxDB port: $PORT"
echo "Using InfluxDB bucket: $BUCKET"
echo "Using InfluxDB org: $ORG"

echo "Importing $FILE to InfluxDB..."

# Use curl to write the data to InfluxDB
response=$(curl --write-out "%{http_code}" --silent --output /dev/null -X POST \
    "http://${HOST}:${PORT}/api/v2/write?org=${ORG}&bucket=${BUCKET}&precision=${PRECISION}" \
    --header "Authorization: Token ${TOKEN}" \
    --data-binary @"${FILE}")

if [ "$response" -eq 204 ]; then
    echo "Successfully imported $FILE"
else
    echo "Failed to import $FILE. HTTP response code: $response"
fi

echo "Import process completed."

