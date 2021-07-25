#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${0}")/../${1}"

STATIC='Header set Cache-Control "max-age=31536000"'
ENTRIES='Header set Cache-Control "max-age=7200"'
ARCHIVES='Header set Cache-Control "max-age=86400"'
PAGES='Header set Cache-Control "max-age=86400"'
CDNCACHE='Header set CDN-Cache-Control "max-age=3153600000"'

echo "Generating .htaccess ...";

# static files
for dir in "assets" "images"; do
  echo "${STATIC}" > $dir/.htaccess 
  echo "${CDNCACHE}" >> $dir/.htaccess
done

# entries (archives)
for dir in $(find . -type d | grep -P '^\./\w+/\d{4}/\d{2}/\d{2}/\d{6}'); do
  echo "${ARCHIVES}" > $dir/.htaccess
  echo "${CDNCACHE}" >> $dir/.htaccess
done

# entries (live)
for dir in $(find . -type d \
              | grep "./*/$(date +%Y/%m)" \
              | grep -P '^\./\w+/\d{4}/\d{2}/\d{2}/\d{6}'); do
  echo "${ENTRIES}" > $dir/.htaccess
  echo "${CDNCACHE}" >> $dir/.htaccess
done

# entries (notes)
for dir in $(find . -type d | grep -P '^\./notes'); do
  echo "${ENTRIES}" > $dir/.htaccess
  echo "${CDNCACHE}" >> $dir/.htaccess
done

# pages
for dir in "nyarla" "policies" "licenses"; do
  echo "${PAGES}" > $dir/.htaccess
  echo "${CDNCACHE}" >> $dir/.htaccess
done

echo "Done."
