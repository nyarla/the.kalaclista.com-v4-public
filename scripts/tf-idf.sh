#!/usr/bin/env bash

set -euo pipefail

export P="${1}"
export D="$(echo -n "$P" | sed 's!/_tokens/!/_tfidf/data/!')"
export M="$(echo -n "$D" | sed 's!resources/_tfidf/data!!' | sed 's!.yaml!/!')"

echo $M;
perl -Mlocal::lib=extlib -Ilib scripts/tf-idf.pl "${P}" "${D}"
