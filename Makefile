PROJECT				?= $(notdir $(patsubst %/,%,$(CURDIR)))
PACKAGE_VERSION		:= $(shell node -e 'console.log(require("./package.json").version)')
VERSION				?= $(PACKAGE_VERSION)

.PHONY: all info version install uninstall

all: info

info:
	$(info PROJECT: $(PROJECT))
	$(info VERSION: $(VERSION))

.PHONY: release install uninstall

version:
	sed -i '' "s/^version:.*/version: $(VERSION)/" plugin.yaml

install:
	helm plugin install .

uninstall:
	helm plugin remove gs
