.PHONY: all clean build test

all: clean build

install:
	cpm install -L extlib

test: build
	prove -Mlocal::lib=extlib -Ilib -j15 t/*.t

clean:
	test ! -e dist || rm -rf dist
	test -e dist || mkdir -p dist

build:
	hugo --minify -e production -b 'https://the.kalaclista.com'

tf-idf: build
	perl -Mlocal::lib=extlib -Ilib scripts/tf-idf.pl
