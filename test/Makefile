test: readme.pdf

### readme.pdf
readme.pdf: site/readme/index.html
	# wkhtmltopdf $(opt_pdf) $^ $@
	./node_modules/.bin/pagedjs-cli $^ -o $@

site/readme/index.html: docs/readme.md $(venv)mkdocs
	$(venv)mkdocs build

docs/readme.md:
	mkdir -p docs
	ln -sf ../../README.md $@




### setup tools
$(venv)mkdocs: venv
	$(venv)pip install mkdocs
	cd ..; test/$(venv)python setup.py install

venv:
	virtualenv -p python3.7 venv


venv:=./venv/bin/

header:=$(shell $(venv)/python -m topdf --header)
opt_pdf:=--print-media-type -T 20 -B 20 -L 20 -R 20 \
    --disable-smart-shrinking --javascript-delay 1000 --debug-javascript \
    --header-html $(header) \
    --title ISO-nnnn-nn

