#!/bin/bash

for file in $(ls content/*.md); do
  pandoc ${file} --template template.html -o $(basename ${file/%.md/.html}) --toc --toc-depth=3
done

