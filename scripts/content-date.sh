#!/usr/bin/env bash

set -euo pipefail

for year in $(seq 2006 $(date +%Y)); do
  for section in posts echos ; do
    if test -d private/content/$section/$year \
        && test ! -e private/content/$section/$year/_index.md ; then 
      cat <<EOF >private/content/$section/$year/_index.md
---
title: ${year}年の記事一覧
type: archive
---
EOF
  fi
  done
done
