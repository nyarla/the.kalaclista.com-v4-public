#!/usr/bin/env bash

set -euo pipefail

export P="${1}"
export D="$(echo -n "$P" | sed 's!build/!resources/_tokens/!' | sed 's!/fixture!!')"

if test -e "${D}" && test -e "${D}.md5sum" ; then
  if test "$(cat "${D}.md5sum")" == "$(md5sum "${P}")" ; then
    exit 0
  fi
fi

if ! test -e "${D}" ; then
  perl -Mlocal::lib=extlib -Ilib scripts/tokenize.pl "$P" "$D"
  md5sum "${P}" >"${D}.md5sum"
  touch resources/_tokens/updated
fi
