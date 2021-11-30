#!/usr/bin/env bash

echo Inconsolata
pyftsubset font/Inconsolata-Regular.ttf --text-file=resources/_webfont/mono.txt --layout-features=palt --flavor=woff2 --output-file=static/assets/Inconsolata.subset.woff2
