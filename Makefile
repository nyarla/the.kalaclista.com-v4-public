.PHONY: all clean install pre-build dist test serve

JOBS = $(shell cat /proc/cpuinfo | grep processor | tail -n1 | cut -d\  -f2)

all: clean build

clean:
	(test ! -e build || rm -rf build) && (test -e build || mkdir -p build)
	(test ! -e dist || rm -rf dist) && (test -e dist || mkdir -p dist)

pre-build:
	hugo --minify -e production -b 'https://the.kalaclista.com' -d build

dist:
	cat config.yml| grep -v '\- Test' | grep -v '\- Fixture' >config.dist.yaml
	hugo --minify -e production -b 'https://the.kalaclista.com' -d dist --config config.dist.yaml

test: pre-build
	prove -Mlocal::lib=extlib -Ilib -j$(JOBS) t/*.t

up: clean dist
	rsync --dry-run -crvz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
	  dist/ \
	  nyarla@nyarla.sakura.ne.jp:/home/nyarla/www/the.kalaclista.com/ \
	  | head --lines=-3 | tail --lines=+2 >resources/_gen/purge.txt
	bash scripts/purge_cache.sh

.PHONY: serve install website check

serve:
	hugo serve --minify -D -E -F -e development -b 'http://nixos:1313' --bind 0.0.0.0 --port 1313 --disableLiveReload

install:
	cpm install -L extlib

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
