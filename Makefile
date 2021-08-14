.PHONY: all clean install pre-build dist test serve tokenize tfidf

JOBS = $(shell cat /proc/cpuinfo | grep processor | tail -n1 | cut -d\  -f2)

all: clean build

clean:
	@(test ! -e resources/_tfidf  || rm -rf resources/_tfidf)
	@(test ! -e resources/_tokens || rm -rf resources/_tokens)
	@(test ! -e build || rm -rf build) && (test -e build || mkdir -p build)
	@(test ! -e dist || rm -rf dist) && (test -e dist || mkdir -p dist)

pre-build:
	hugo --minify -e production -b 'https://the.kalaclista.com' -d build
	@bash scripts/htaccess.sh build

dist:
	@cat config.yml| grep -v '\- Test' | grep -v '\- Fixture' >config.dist.yaml
	@hugo --minify -e production -b 'https://the.kalaclista.com' -d dist --config config.dist.yaml
	@bash scripts/htaccess.sh dist

test: pre-build
	prove -Mlocal::lib=extlib -Ilib -j$(JOBS) t/*.t

tokenize: pre-build
	@perl -Mlocal::lib=extlib -Ilib scripts/tokenize.pl

terms:
	@echo count all terms...
	@perl -Mlocal::lib=extlib -Ilib scripts/terms.pl

tfidf:
	@echo calcurate TF-IDF...
	@perl -Mlocal::lib=extlib -Ilib scripts/tf-idf.pl

scores:
	@echo calcurate scores...
	@perl -Mlocal::lib=extlib -Ilib scripts/scores.pl


related: tokenize terms tfidf scores
	perl -Mlocal::lib=extlib -Ilib scripts/merge.pl

up: clean related dist
	@rsync -crvz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
	  dist/ \
	  nyarla@nyarla.sakura.ne.jp:/home/nyarla/www/the.kalaclista.com/ \
	  | head --lines=-3 | tail --lines=+2 >resources/_gen/purge.txt
	@echo Updated:
	@cat resources/_gen/purge.txt
	@bash scripts/purge_cache.sh

.PHONY: serve install website check

serve:
	hugo serve --minify -D -E -F -e development -b 'http://nixos:1313' --bind 0.0.0.0 --port 1313 --disableLiveReload

install:
	env PERL_TEXT_MECAB_ENCODING=utf-8 cpm install -L extlib

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

amazon:
	@cat - | perl -Mlocal::lib=extlib -Ilib scripts/affiliate.pl amazon

rakuten:
	@cat - | perl -Mlocal::lib=extlib -Ilib scripts/affiliate.pl rakuten

check:
	perl -Mlocal::lib=extlib -Ilib -c scripts/tf-idf.pl
	perl -Mlocal::lib=extlib -Ilib -c scripts/website.pl

.PHONY: posts echos

posts:
	hugo new posts/$(shell date +%Y/%m/%d/%H%M%S.md)
	nvim private/content/posts/$(shell date +%Y/%m/%d/%H%M%S.md)

echos:
	hugo new echos/$(shell date +%Y/%m/%d/%H%M%S.md)
	nvim private/content/echos/$(shell date +%Y/%m/%d/%H%M%S.md)
