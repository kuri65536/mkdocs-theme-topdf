mkdocs-theme-topdf
=========================================================
a mkdocs theme to generate pdf or print.

[TOC]


Prerequiresites/ Dependency
--------------------------
This plugin aim to use these softwares

- mkdocs (convert markdown to html)
- python-docx (to generate docx)
- paged.js (to generate pdf, page borders and page headers)
- node.js (to generate pdf, for pagedjs-cli)



Installation - this plugin <!-- {{{1 -->
--------------------------
Install this package with pip.

### from PyPi
```bash
pip install mkdocs-theme-topdf
```

### from github
```bash
pip install git+https://github.com/kuri65536/mkdocs-theme-topdf
```


Installation - paged.js
--------------------------
so paged.js uses node.js and portable chrome,
it is separate from mkdocs theme.

to prepare paged.js, follow these method.

### from this plugin
```bash
python -m topdf --check
> ... check node.js and npm ...
python -m topdf --setup
> ... install take long time ...
python -m topdf --test
> output report-3stamps.pdf
```

### from manual
```bash
$ npm install pagedjs-cli
... take long time ...
$ ./node_modules/.bin/pagedjs-cli
... paged.js message ...
```



How to use <!-- {{{1 -->
--------------------------
### prepare
to use mkdocs theme see [material theme documentation][mkdocs-theme]

[mkdocs-theme]: https://squidfunk.github.io/mkdocs-material/getting-started/

### setup mkdocs.yml
change mkdocs.yml to use this plugin.

```yaml
site_name: the test document
theme:
    name: topdf
```

### write markdown
write your document

```bash
$ vi docs/your/document.md
```


### convert to html
```bash
$ ./venv/bin/mkdocs build
```


### convert to docx <!-- {{{1 -->
```bash
$ /path/to/python -m topdf site/your/document/index.html -o document.docx
```

see [problem with python-docx](#backend-python-docx)

<img src="https://user-images.githubusercontent.com/11357613/86648803-245e5280-c01c-11ea-98fc-64cdcd73c399.png"
  style="max-width: 100%;" />



### (old method) convert with paged.js

```bash
$ pagedjs-cli --outline-tags h1,h2,h3,h4,h5,h6 site/your/document/index.html
     -o document.pdf  # 1-line
```

see [problem with paged.js](#backend-paged-js)

<img src="https://user-images.githubusercontent.com/11357613/70920996-cf9ac080-2066-11ea-81f2-0e7c840ebea1.png"
  style="max-width: 100%;" />



### About PDF output

#### backend: python-docx
- now, I choose this solution.
- python-docx has some problems too,
    - can't handle to include SVG images
    - can't handle complex HTML. (it's my problem)
    - you need Office365 account or MS Office license to generate pdf.
    - LibreOffice and O365 output are different,  
        AbiWord can't handle tables (may crash).


#### backend: paged.js
- I choose this for second, but not use now.
- under development.
- paged.js render the PDF with portable chrome and pupetter  
    please watch out the difference of rendering results among  
    them engine and your browser.
- paged.js has some problems with mkdocs outputs.
    - generated html-id is invalid for their javascript  
        heading the digit aka: `1-contents`
- paged.js has some problems.
    - a multi-byte problem in pdflib.js, TOC can't handle multi-byte outputs.  
        I made the patch and succeed to output,  
        but this cause wide sub-effects and can't fix it.
    - long tables across the pages, may break your tables.


#### backend: wkhtmltopdf
- I choose this for first, but not use now.
- no-longer developped.
- wkhtmltopdf render the PDF with webkit (old)  
    and stable release (0.12.5) can not generate TOC with its limitation.  
    wkhtmltopdf is more convinient to install, but  
    I can't resolve the TOC problem and switched to paged.js



---



Demo <!-- {{{1 -->
--------------------------
[a sample output of PDF with paged.js](https://github.com/kuri65536/mkdocs-theme-topdf/files/3993873/report-3stamps.pdf)


![screenshot in Android Word](https://user-images.githubusercontent.com/11357613/86648803-245e5280-c01c-11ea-98fc-64cdcd73c399.png)


![screenshot in pdf viewer](https://user-images.githubusercontent.com/11357613/70920996-cf9ac080-2066-11ea-81f2-0e7c840ebea1.png)



About scripts and styles
--------------------------
please see [the report sample](test/docs/report-3stamps.md)



FAQ
--------------------------
can not open docx in AbiWord

: In my experience, AbiWord can not open python-docx tables,  
    please use LibreOffice. this is an AbiWord limitation.



History <!-- {{{1 -->
--------------------------
<!-- this comment is needed for paragraph class -->
{: .before-dl-table .table2-8 }

version
: descriptions

1.3.0
:   - import SVG to docx.

1.2.0
:   - fix parsing strong elements at heads of paragraphs.
    - enable tests.

1.1.3
:   first version of footnotes2.

1.1.2
:   - enable table styles to normal table.
    - enable tables detail width (for docx only).
    - enable tables auto width for docx.

1.1.1
: bugfix for 3stamps, br elements. and add support for sup elements.

1.1.0
: append controls for presensation.

1.0.2
: ignore katex outputs/ start to implement footnotes2.

1.0.1
: enable styles for `code` / reduce file size by styles/ auto numbers

1.0.0
: update to github/ nested lists/ hr as page-breaks

0.9.6
: enable inline elements: comments, em, br, strong or etc...

0.9.5
: support embedded images.

0.9.4
: enable ooxml fields: TOC, page numbers, bookmarks

0.9.3
: borders on code blocks/ control tables width/ floating rectangles on header

0.9.2
: borders on code blocks/ control tables width.

0.9.1
: enable document numbers on header

0.9.0
: append docx backend by python-docx

0.5.1
: fixed multiple `<tbody>` element in dl-tables.

0.5.0
: add a script: fix the mkdocs invalid html-id to prevent paged-js exceptions.

0.4.0
: append CSS-counters for figures and tables.

0.3.0
: append `theme` to the package name

0.2.7
: TOC and styles

0.2.6
: append explanation for paged.js TOC and styles

0.2.5
: append explanation for paged.js styles

0.2.4
: append explanation for paged.js styles

0.2.3
: append slash line to the no-stamp cells.

0.2.2
: append screenshot

0.2.1
: append explanation for dl-dt-dd tables

0.2.0
: start to edit/ 3stamps

0.1.2
: start to use paged.js

0.1.1
: start to use mkhtmltopdf

0.1.0
: append dl-dt-dd tables

0.0.6
: start to edit



Donations
---------------------
If you are feel to nice for this software, please donate to

[![img-bitcoin]][lnk-bitcoin]
&nbsp;&nbsp;or&nbsp;&nbsp;
[![img-etherium]][lnk-bitcoin]

- [bitcoin:39Qx9Nffad7UZVbcLpVpVanvdZEQUanEXd][lnk-bitcoin]
- [ethereum:0x9d03b1a8264023c3ad8090b8fc2b75b1ba2b3f0f][lnk-bitcoin]
- or [liberapay](https://liberapay.com/kuri65536) .

[lnk-bitcoin]:  https://kuri65536.bitbucket.io/donation.html?message=thank-for-mkdocs_theme_topdf
[img-bitcoin]:  https://github.com/user-attachments/assets/abce4347-bcb3-42c6-a9e8-1cd12f1bd4a5
[img-etherium]: https://github.com/user-attachments/assets/d1bdb9a8-9c6f-4e74-bc19-0d0bfa041eb2

