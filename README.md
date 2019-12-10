mkdocs-topdf
=========================================================
a mkdocs theme for generate pdf or printing

[TOC]


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


---



Demo
--------------------------

<!--
![snapshot in browser]()
-->

<!--
![snapshot in document viewer]()
-->



History
--------------------------
<!-- this comment is needed for paragraph class -->
{: .before-dl-table .table2-8 }

version
: desc

0.0.6
: start to edit



Donations
---------------------
If you are feel to nice for this software, please donation to my

-   Bitcoin **| 1FTBAUaVdeGG9EPsGMD5j2SW8QHNc5HzjT |**
-   or Ether **| 0xd7Dc5cd13BD7636664D6bf0Ee8424CFaF6b2FA8f |** .


