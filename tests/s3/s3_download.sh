#!/usr/bin/env bash

set -euo pipefail

# -------- CONFIG --------
ENDPOINT="http://192.168.1.100:3900"
REGION="garage"
# ------------------------

BUCKET="$1"
OBJECT_NAME="$2"
DEST_FILE="${3:-$OBJECT_NAME}"

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    echo "ERROR: AWS credentials not set in environment."
    exit 1
fi

echo "Downloading s3://$BUCKET/$OBJECT_NAME to $DEST_FILE"

aws s3 cp "s3://$BUCKET/$OBJECT_NAME" "$DEST_FILE" \
    --endpoint-url "$ENDPOINT" \
    --region "$REGION"

echo "Download complete."

