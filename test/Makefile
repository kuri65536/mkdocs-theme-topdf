test: readme.pdf

pagedjs:=./node_modules/.bin/pagedjs-cli --outline-tags h2,h3,h4,h5,h6

src:=../topdf/html_conv_docx.py \
     ../topdf/common.py

### readme.pdf
readme.pdf: site/readme.html
	# wkhtmltopdf $(opt_pdf) $^ $@
	$(pagedjs) $^ -o $@

site/readme.html: docs/readme.md $(venv)mkdocs
	$(venv)mkdocs build

docs/readme.md:
	mkdir -p docs
	ln -sf ../../README.md $@



### report-3stamps.pdf
report-3stamps.pdf: site/report-3stamps.html
	$(pagedjs) $^ -o $@

site/report-3stamps.html: docs/report-3stamps.md $(venv)mkdocs
	$(venv)mkdocs build



### report-docx.docx
report-docx.docx: site/report-docx.html $(src)
	./venv/bin/python ../topdf/html_conv_docx.py $(word 1,$^) -o $@

site/report-docx.html: docs/report-docx.md
	$(venv)mkdocs build



### setup tools
./node_modules/.bin/pagedjs-cli:
	npm install pagedjs-cli

$(venv)mkdocs: venv
	$(venv)pip install mkdocs
	cd ..; test/$(venv)python setup.py install

venv:
	virtualenv -p python3.7 venv


venv:=./venv/bin/

# header:=$(shell $(venv)/python -m topdf --header)
opt_pdf:=--print-media-type -T 20 -B 20 -L 20 -R 20 \
    --disable-smart-shrinking --javascript-delay 1000 --debug-javascript \
    --header-html $(header) \
    --title ISO-nnnn-nn

