PROJECT				?= $(notdir $(patsubst %/,%,$(CURDIR)))
VERSION				?= 0.0.0-SNAPSHOT
YARN_CACHE_DIR      ?= .cache/yarn

.PHONY: all info version install uninstall

all: info

info:
	$(info PROJECT: $(PROJECT))
	$(info VERSION: $(VERSION))

.PHONY: version release install uninstall

version:
	sed -i '' "s/^version:.*/version: $(VERSION)/" plugin.yaml

release:
	yarn global add \
		--non-interactive --ignore-engines --production --no-lockfile \
		--cache-folder "$(YARN_CACHE_DIR)" \
		@semantic-release/git@7 \
		@semantic-release/gitlab@3 \
		@semantic-release/changelog@3 \
		@semantic-release/exec@3 \
		semantic-release@15
	semantic-release --no-ci

install:
	helm plugin install .

uninstall:
	helm plugin remove gs
