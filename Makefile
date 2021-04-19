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

website:
	@test -d resources/_website || mkdir -p resources/_website
	@(pt -e '[\-*+] \[' private/content \
		| grep '](' \
		| sed 's/.\+\](//' \
		| cut -d\) -f 1 \
		| cut -d\# -f 1 \
		| grep -v 'amazon.co.jp' | grep -v 'rakuten.co.jp' \
		| sort | uniq \
		| grep -P '^http') >resources/_website/links
	@perl -Mlocal::lib=extlib -Ilib scripts/website.pl

check:
	perl -Mlocal::lib=extlib -Ilib -c scripts/tf-idf.pl
	perl -Mlocal::lib=extlib -Ilib -c scripts/website.pl
