VPATH		:= md
PANDOC		:= pandoc
PANDOC_FLAGS	:= --toc --toc-depth=3 --mathjax
TEMPLATE 	:= template.html
MARKDOWN	:= $(shell find $(VPATH) -name "*.md")
HTML		:= $(patsubst $(VPATH)/%.md,%.html,$(MARKDOWN))

%.html: %.md $(TEMPLATE)
	@mkdir -p $(dir $@)
	$(PANDOC) $< -o $@ --template $(TEMPLATE) $(PANDOC_FLAGS)

.PHONY: site
site: $(HTML)

