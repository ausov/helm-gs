VERSION ?= snapshot

.PHONY: release install uninstall

release:
	sed -i '' "s/^version:.*/version: $(VERSION)/" plugin.yaml

install:
	helm plugin install .

uninstall:
	helm plugin remove gs
