.PHONY: all clean build test

all: clean build

install:
	cpm install -L extlib

test:
	prove -Mlocal::lib=extlib -j15 t/*.t

clean:
	test ! -e dist || rm -rf dist
	test -e dist || mkdir -p dist

build:
	hugo --minify -e production -b 'https://the.kalaclista.com'
