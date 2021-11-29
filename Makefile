.PHONY: all clean

all:
	@echo **recipe**
	@echo start

src_nim := $(wildcard src/*) \
           $(wildcard src/md2docx/*) \

### section of build / launch {{{1
bin/mkdocs2docx: src/md2docx/mkdocs2docx.nim $(src_nim)
	mkdir -p bin
	nim c -o=$@ $<


start: bin/mkdocs2docx
	$< tests/test.html

# end of a file {{{1
# vi: ft=make:fdm=marker
