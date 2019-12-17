mkdocs-topdf
=========================================================
a mkdocs theme to generate pdf or print.

[TOC]


Prerequiresites/ Dependency
--------------------------
This plugin aim to use these softwares

- mkdocs (convert markdown to html)
- paged.js (to generate pdf, page borders and page headers)



Installation
--------------------------
Install this package with pip.

### from PyPi
```bash
pip install mkdocs-topdf
```

### from github
```bash
pip install git+https://github.com/kuri65536/mkdocs-topdf
```



How to use
--------------------------
### prepare
to use mkdocs theme see [material theme documentation][mkdocs-theme]

[mkdocs-theme]: https://squidfunk.github.io/mkdocs-material/getting-started/

### setup mkdocs.yml
change mkdocs.yml to use this plugin.

```
site_name: the test document
theme:
    name: topdf
```

### write markdown
write your document

### convert with wkhtmltopdf

```bash
$ header:=$(./venv/bin/python -m topdf --header)
$ wkhtmltopdf --print-media-type -T 20 -B 20 -L 20 -R 20 \
    --disable-smart-shrinking --javascript-delay 1000 --debug-javascript \
    --header-html $header \
    --title ISO-nnnn-nn
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



Demo
--------------------------
![screenshot in pdf viewer](https://user-images.githubusercontent.com/11357613/70920996-cf9ac080-2066-11ea-81f2-0e7c840ebea1.png)

<!--
![snapshot in browser]()
-->

![screenshot in pdf viewer](https://user-images.githubusercontent.com/11357613/70920996-cf9ac080-2066-11ea-81f2-0e7c840ebea1.png)



About scripts and styles
--------------------------
please see [the report sample](test/docs/report-3stamps.md)



### FAQ
B.B.D



History
--------------------------
<!-- this comment is needed for paragraph class -->
{: .before-dl-table .table2-8 }

version
: desc

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


