PANDOC		:= pandoc
PANDOC_FLAGS	:= --toc --toc-depth=3
TEMPLATE 	:= template.html
MARKDOWN	:= $(wildcard content/*.md)
HTML		:= $(patsubst content/%.md,%.html,$(MARKDOWN))

%.html: content/%.md $(TEMPLATE)
	$(PANDOC) $< -o $@ --template $(TEMPLATE) $(PANDOC_FLAGS)

.PHONY: site
site: $(HTML)

