VPATH		:= content
PANDOC		:= pandoc
PANDOC_FLAGS	:= --toc --toc-depth=3
TEMPLATE 	:= template.html
MARKDOWN	:= $(shell find content -name "*.md")
HTML		:= $(patsubst content/%.md,%.html,$(MARKDOWN))

%.html: %.md $(TEMPLATE)
	$(PANDOC) $< -o $@ --template $(TEMPLATE) $(PANDOC_FLAGS)

.PHONY: site
site: $(HTML)

