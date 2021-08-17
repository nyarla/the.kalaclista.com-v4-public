#!/usr/bin/env bash

echo Mamelon
pyftsubset font/Mamelon-3HiRegular.woff2 --text-file=resources/_webfont/sans.txt --layout-features=palt --flavor=woff2 --output-file=static/assets/Mamelon.subset.woff2

echo Inconsolata
pyftsubset font/Inconsolata-Regular.ttf --text-file=resources/_webfont/mono.txt --layout-features=palt --flavor=woff2 --output-file=static/assets/Inconsolata.subset.woff2
