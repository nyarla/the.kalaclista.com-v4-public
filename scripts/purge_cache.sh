#!/usr/bin/env bash

source .env

curl -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/purge_cache" \
  -H "Authorization: Bearer ${ZONE_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'

