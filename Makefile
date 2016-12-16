VPATH		:= content
PANDOC		:= pandoc
PANDOC_FLAGS	:= --toc --toc-depth=3 --mathjax
TEMPLATE 	:= template.html
MARKDOWN	:= $(shell find content -name "*.md")
HTML		:= $(patsubst content/%.md,%.html,$(MARKDOWN))

%.html: %.md $(TEMPLATE)
	@mkdir -p $(dir $@)
	$(PANDOC) $< -o $@ --template $(TEMPLATE) $(PANDOC_FLAGS)

.PHONY: site
site: $(HTML)

