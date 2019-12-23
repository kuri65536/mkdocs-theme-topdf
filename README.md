mkdocs-theme-topdf
=========================================================
a mkdocs theme to generate pdf or print.

[TOC]


Prerequiresites/ Dependency
--------------------------
This plugin aim to use these softwares

- mkdocs (convert markdown to html)
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

### convert with paged.js

```bash
$ pagedjs-cli --outline-tags h1,h2,h3,h4,h5,h6 site/your/document.html
     -o document.pdf  # 1-line
```


### About PDF output
- paged.js render the PDF with portable chrome and pupetter  
    please watch out the difference of rendering results among  
    them engine and your browser.
- wkhtmltopdf render the PDF with webkit (old)  
    and stable release (0.12.5) can not generate TOC with its limitation.  
    wkhtmltopdf is more convinient to install, but  
    I can't resolve the TOC problem and switched to paged.js



---



Demo <!-- {{{1 -->
--------------------------
[a sample output of PDF](https://github.com/kuri65536/mkdocs-theme-topdf/files/3993873/report-3stamps.pdf)

![screenshot in pdf viewer](https://user-images.githubusercontent.com/11357613/70920996-cf9ac080-2066-11ea-81f2-0e7c840ebea1.png)



About scripts and styles
--------------------------
please see [the report sample](test/docs/report-3stamps.md)



FAQ
--------------------------
T.B.D



History <!-- {{{1 -->
--------------------------
<!-- this comment is needed for paragraph class -->
{: .before-dl-table .table2-8 }

version
: desc

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
If you are feel to nice for this software, please donation to my

-   Bitcoin **| 1FTBAUaVdeGG9EPsGMD5j2SW8QHNc5HzjT |**
-   or Ether **| 0xd7Dc5cd13BD7636664D6bf0Ee8424CFaF6b2FA8f |** .


<!-- vi: fdm=marker
  -->

