JOBS = $(shell cat /proc/cpuinfo | grep processor | tail -n1 | cut -d\  -f2)
NIX = nix-shell -I nixpkgs=/etc/nixpkgs

.PHONY: clean pre-build dist test up

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
	@prove -Ilib -j$(JOBS) t/*.t

up: clean related webfont dist
	@rsync -crvz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
	  dist/ \
	  nyarla@nyarla.sakura.ne.jp:/home/nyarla/www/the.kalaclista.com/ \
	  | head --lines=-3 | tail --lines=+2 >resources/_gen/purge.txt
	@echo Updated:
	@cat resources/_gen/purge.txt
	@bash scripts/purge_cache.sh

.PHONY: tokenize terms tfidf scoring related

tokenize: pre-build
	@perl scripts/related-tokenize.pl

terms:
	@echo count all terms...
	@perl scripts/related-terms.pl

tfidf:
	@echo calcurate TF-IDF...
	@perl scripts/related-tfidf.pl

scoring:
	@echo calcurate scores...
	@perl scripts/related-scoring.pl

related: tokenize terms tfidf scoring
	@echo generate related.yaml
	@perl scripts/related-merge.pl

.PHONY: extract webdata

extract:
	@perl scripts/webdata-extract.pl

webdata:
	@perl scripts/webdata-fetch.pl

.PHONY: webfont

webfont:
	@perl scripts/webfont.pl
	@bash scripts/webfont.sh

.PHONY: edit serve check cpan-deps cpan-nix

edit:
	@$(NIX) --run "env SHELL=zsh nvim ."

serve:
	hugo serve --minify -D -E -F -e development -b 'http://nixos:1313' --bind 0.0.0.0 --port 1313 --disableLiveReload

check:
	find scripts -type f -name '*.pl' -exec perl -c {} \;

cpan-deps:
	@perl scripts/cpanfile-deps.pl 2>/dev/null

cpan-nix: cpan-deps
	@perl scripts/cpanfile-nix.pl 2>/dev/null

.PHONY: posts echos amazon rakuten

posts:
	hugo new posts/$(shell date +%Y/%m/%d/%H%M%S.md)
	nvim private/content/posts/$(shell date +%Y/%m/%d/%H%M%S.md)

echos:
	hugo new echos/$(shell date +%Y/%m/%d/%H%M%S.md)
	nvim private/content/echos/$(shell date +%Y/%m/%d/%H%M%S.md)

amazon:
	@cat - | perl scripts/edit-affiliate.pl amazon

rakuten:
	@cat - | perl scripts/edit-affiliate.pl rakuten
