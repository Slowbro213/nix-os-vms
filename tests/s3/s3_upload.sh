#!/usr/bin/env bash

set -euo pipefail

# -------- CONFIG --------
ENDPOINT="http://192.168.1.100:3900"   # change to your Garage endpoint
BUCKET="$1"
LOCAL_FILE="$2"
OBJECT_NAME="${3:-$(basename "$LOCAL_FILE")}"
REGION="garage"
# ------------------------

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    echo "ERROR: AWS credentials not set in environment."
    exit 1
fi

if [[ ! -f "$LOCAL_FILE" ]]; then
    echo "ERROR: File does not exist: $LOCAL_FILE"
    exit 1
fi

echo "Uploading $LOCAL_FILE to s3://$BUCKET/$OBJECT_NAME"

aws s3 cp "$LOCAL_FILE" "s3://$BUCKET/$OBJECT_NAME" \
    --endpoint-url "$ENDPOINT" \
    --region "$REGION"

echo "Upload complete."

