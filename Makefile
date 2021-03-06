JOBS = $(shell cat /proc/cpuinfo | grep processor | tail -n1 | cut -d\  -f2)
NIX = nix-shell
HUGO = env LANG=en_US.UTF-8 hugo

.PHONY: clean pre-build dist test up

all: clean build

clean:
	@rm -rf resources/*
	@(test ! -e build || rm -rf build) && (test -e build || mkdir -p build)
	@(cd dist && rm -r *)

pre-build:
	@bash scripts/content-date.sh
	@$(HUGO) --minify -e production -b 'https://the.kalaclista.com' -d build
	@test -d static/images || mkdir -p static/images
	@cp -R private/assets/images/* static/images/

dist:
	@cat config.yml| grep -v '\- Test' | grep -v '\- Fixture' >config.dist.yaml
	@$(HUGO) --minify -e production -b 'https://the.kalaclista.com' -d dist --config config.dist.yaml
	@find dist/*/*/ -type f -name "jsonfeed.json" -exec rm {} \;
	@find dist/*/*/ -type f -name "index.xml" -exec rm {} \;
	@find dist/*/*/ -type f -name "atom.xml" -exec rm {} \;
	@rm -rf static/images/assets

test: pre-build
	@prove -Ilib -j$(JOBS) t/*.t

build: clean webfont dist

push:
	cd dist && git add . && git ci -m "feat(update): $(shell date "+%Y-%m-%d %H:%M:%S")" && git push origin main

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

extract: clean pre-build
	@perl scripts/webdata-extract.pl

webdata:
	@perl scripts/webdata-fetch.pl

.PHONY: webfont

webfont:
	@perl scripts/webfont.pl
	@bash scripts/webfont.sh

.PHONY: edit shell serve check cpan-deps cpan-nix

shell:
	@nix develop -c env SHELL=zsh zsh

serve:
	@$(HUGO) serve --minify -D -E -F -e development -b 'http://nixos:1313' --bind 0.0.0.0 --port 1313

check:
	find scripts -type f -name '*.pl' -exec perl -c {} \;

cpan-deps:
	@perl scripts/cpanfile-deps.pl

cpan-nix:
	@perl scripts/cpanfile-nix.pl

.PHONY: posts echos amazon rakuten lint

posts:
	$(HUGO) new posts/$(shell date +%Y/%m/%d/%H%M%S.md)

echos:
	$(HUGO) new echos/$(shell date +%Y/%m/%d/%H%M%S.md)

amazon:
	@cat - | perl scripts/edit-affiliate.pl amazon

rakuten:
	@cat - | perl scripts/edit-affiliate.pl rakuten

lint:
	@test -d resources/_textlint || mkdir -p resources/_textlint
	@(find private/content -type f -name '*.md' | sort -r ) | fzy --query=$(shell cat resources/_textlint/log) | cat - >resources/_textlint/log
	@npm run textlint $$(cat resources/_textlint/log | head -n1) 
