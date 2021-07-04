#!/usr/bin/env bash

source .env

if ! test -e resources/_gen/purge.txt || test -z resources/_gen/purge.txt ; then
  exit 0
fi

if test $(cat resources/_gen/purge.txt | wc -l) -gt 30 ; then
  curl -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/purge_cache" \
    -H "Authentication: Bearer ${ZONE_TOKEN}" \
    --data '{"purge_everything":true}'
else
  curl -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/purge_cache" \
    -H "Authentication: Bearer ${ZONE_TOKEN}" \
    --data "$(cat resources/_gen/purge.txt | sed 's/^\(.\+\)$/"\1",/g' | tr "\n" " " | (echo -n '{"files":['; cat - ; echo -n "]}") | sed 's/, ]}$/]}/')"
fi
