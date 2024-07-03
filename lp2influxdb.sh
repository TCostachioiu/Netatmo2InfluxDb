#!/bin/bash

set -e

# InfluxDB configuration
HOST=${INFLUXDB_HOST:-localhost}
PORT=${INFLUXDB_PORT:-8086}
BUCKET=${INFLUXDB_BUCKET:-Netatmo2}
ORG=${INFLUXDB_ORG:-your_org_name}
TOKEN=${INFLUXDB_TOKEN:-your_token}

PRECISION=s

# Directory containing the CSV files (default is current directory)
DATA_DIR=${1:-.}

# Check if HOST, PORT, BUCKET, ORG, and TOKEN are set
echo "Using InfluxDB host: $HOST"
echo "Using InfluxDB port: $PORT"
echo "Using InfluxDB bucket: $BUCKET"
echo "Using InfluxDB org: $ORG"

# Loop over all files starting with "lp_"
# for file in "$DATA_DIR"/lp_*.txt; do
# Loop over all files ending with ".lp"
for file in "$DATA_DIR"/*.lp; do
    if [ -f "$file" ]; then
        echo "Importing $file to InfluxDB..."

        # Use curl to write the data to InfluxDB
        response=$(curl --write-out "%{http_code}" --silent --output /dev/null -X POST \
            "http://${HOST}:${PORT}/api/v2/write?org=${ORG}&bucket=${BUCKET}&precision=${PRECISION}" \
            --header "Authorization: Token ${TOKEN}" \
            --data-binary @"${file}")

        if [ "$response" -eq 204 ]; then
            echo "Successfully imported $file"
        else
            echo "Failed to import $file. HTTP response code: $response"
        fi
    else
        echo "No files found starting with lp_"
    fi
done

echo "Import process completed."
