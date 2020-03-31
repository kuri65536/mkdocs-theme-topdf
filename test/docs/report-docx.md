<p class="doc-num">ISO-nnnn</p>
<p class="before-dl-table table-3stamps"></p>

Japan style<br>Technical Report
: edit<br><svg viewbox="0 0 52 52" width=16mm height=16mm>
    <defs>
        <g id="stamp" stroke=#000 fill=none stroke-width=1pt>
            <circle r=25 cx=26 cy=26  />
            <line x1=3 x2=49 y1=18 y2=18 />
            <line x1=3 x2=49 y1=32 y2=32 />
        </g>
    </defs>
    <use xlink:href="#stamp" x=0 y=0 />
    <g text-anchor=middle font-size=9>
        <text x=25 y=16>FOSS</text>
        <text x=25 y=29>19-10-10</text>
        <text x=16 y=45 font-size=8>sn</text>
        <text x=31 y=45 font-size=12>D.S</text>
    </g>
    </svg>
: check
: approve  
    <svg viewbox="0 0 52 52" width=16mm height=16mm>
    <use xlink:href="#stamp" x=0 y=0 />
    <g text-anchor=middle font-size=9>
        <text x=25 y=16>FOSS</text>
        <text x=25 y=29>19-10-11</text>
        <text x=16 y=45 font-size=8>mn</text>
        <text x=31 y=45 font-size=12>N.S</text>
    </g>
    </svg>


1. 概要 <!-- {{{1 -->
--------------------------
漢字のテスト
this is a sample of japan style technical report.


2. (Conclusion)
--------------------------
- this is a sample of japan style technical report.
- include edit/ check/ approve stamps.
- include TOC styles with page outputs.


3. Con\\tents
--------------------------
[TOC]



4. Features of this plugin
--------------------------

### 4.1. Script for dl-dt-dd tables <!-- {{{1 -->
- conert dl-dt-dd markup to tables
- dl with class `before dl-tables`


### 4.2. **Under construction** Script and Styles for stamps <!-- {{{1 -->
- made by a dl-dt-dd markup in markdown, made by 1dt, 3dd.
- place after an elment have `class="table-3stamps"` .
- TODO(shimoda): if stamp fields have no `<br>`, the slash line will be insereted.
- TODO(shimoda): importing svg
- samples:

```markdown
<p class="before-dl-table table-3stamps"></p>

Japan style<br>Technical Report
: edit<br>![stamp-editor](stamp-A.svg)
: check
: approve<br>![stamp-approve](stamp-C.svg)
```

or

```markdown
{: .before-dl-table .table-3stamps }

Japan style<br>Technical Report
: edit<br>![stamp-editor](stamp-A.svg)
: check
: approve<br>![stamp-approve](stamp-C.svg)
```

- to disable the slash lines, you can specify these style:

```css
th.no-stamps {
    background-image: none !importatnt;
}
```



### 4.3. Script and Styles for tables <!-- {{{1 --> {: #css-tables }
- this function is for improve to enable markdown syntax to  
    multi-line tables

- CSS-styles predefined in `_extra.pdf`

*pre-defined CSS styles for table*{: .table-tag }

class        | size
:-----------:|:-------:
table2-8     | 20-80%
table3-7     | 30-70%
table4-6     | 40-60%
table5-5     | 50-50%
table2-2-6   | 20-20-60%
table2-3-5   | 20-30-50%
table2-4-4   | 20-40-40%
table3-3-3   | 33-33-33%
table2-5-3   | 20-50-30%
table2-6-2   | 20-60-20%
table2-2-2-4 | 20-20-20-40%%

<br>

<p class="before-dl-table table2-8"></p>

20%
: 80%

<p class="before-dl-table table2-4-4"></p>

20%
: 40%
: 40%

<p class="before-dl-table table2-2-2-4"></p>

20%
: 20%
: 20%
: 40%

<p class="before-dl-table table3-3-3"></p>

multi line sample
: tables can be<br>write with<br>regular syntax
:   1. list ok
    2. ol ok
    3. ul too

but dt can't be multi-line
: ...
: ...



### 4.4. Styles for page-header (paged.js) <!-- {{{1 -->
- now supported fixed docx header format: `string (page/pages)`
- supported markdown::

```markdown
<p class="doc-num">document number. ISO-nnnn-nn</p>

or

document number. ISO-nnnn-nn
{: .doc-num }
```


### 4.5. **need help** TOC <!-- {{{1 -->
- insert docx `TOC` field at `[TOC]` in markdown
- now support just embed a `TOC` field into docuemnt.  
    users will update the `TOC` field at thier editor.
- TODO(shimoda): manipurate TOC contents by script
- TODO(shimoda): or Launch and update fields in LibreOffice or MS Word.


### 4.6. Styles for page-break <!-- {{{1 -->
just use `hr`, markup:

```markdown

---

```

sample page break is here:


---


### 4.7. Styles for auto-numbered images and tables <!-- {{{1 -->
figure or table captions can be described with `em` tags.  

```css
img + em, svg + em {
    ...
    counter-increment: num_figure; }
img + em::before, svg + em::before {
    content: "Fig." counter(num_figure) " ";
}
```

see samples in this section, [Styles for Tables](#css-tables)
and [Demo](#demo).

<svg width=150mm height=30mm viewbox="0 0 100 100">
   <circle r=49 cx=49 cy=49 fill=#CCC />
</svg>
*sample svg*

<svg width=150mm height=30mm viewbox="0 0 100 100">
   <rect x=0 x=0 width=100 height=100 fill=#CCC />
</svg>
*sample svg part2*


*sample table*

<p class="before-dl-table table3-3-3"></p>

sample
: 1
: 2

sample
: 1
: 2


### 4.8. Convert anchors to docx bookmarks <!-- {{{1 -->
- anchor tags were converted to `w:hyperlink`

```
<w:hyperlink w:anchor="ahref_target_id"><w:r><w:t>
    text
</w:t></w:r></w:hyperlink>
```

- title tags were appended `w:bookmarkStart` attributes

```
<w:p>
    <w:bookmarkStart w:id="0" w:name="ahref_target_id" />
    <w:bookmarkEnd w:id="0" />
    <w:r><w:t>
        text
    </w:t></w:r>
</w:p>
```


### 4.10. **need help** Convert inner svg to DrawingML <!-- {{{1 -->
- previous version of topdf demo embed stamps or simple examples as SVG.  
    but python-docx does not support SVG now.


### 4.11. nested paragraphs <!-- {{{1 -->
- not support nested p or div. this app just flat them.
- nested `ul` or `ol` `li` tags inside `ul` or `ol`, a sample markup::

```
- aaaa
- bbbb
    - bbb1
    - bbb2
- cccc
    - ccc1
    - ccc2
- dddd
    - ddd1
    - ddd2
        - ddd2-1
        - ddd2-2
            - ddd2-2-1
            - ddd2-2-2
        - ddd2-3
- eeee
```

- aaaa
- bbbb
    - bbb1
    - bbb2
- cccc
    - ccc1
    - ccc2
- dddd
    - ddd1
    - ddd2
        - ddd2-1
        - ddd2-2
            - ddd2-2-1
            - ddd2-2-2
        - ddd2-3
- eeee



### 4.12. list in tables <!-- {{{1 -->
- sample markup::

```
aaa
{: .before-dl-table }

row 1
: col2
:   - item1
    - item2

row 2
:   - item3
    - item4
: col3
```

aaa
{: .before-dl-table }

row 1
: col2
:   - item1
    - item2

row 2
:   - item3
    - item4
: col3




### 4.13. tables <!-- {{{1 -->
- sample markup::

```
aaa | bbb | ccc
----|-----|-----
ddd | eee | fff
ggg | hh<br>hh | iii
jjj | kkk | lll
```

aaa | bbb | ccc
----|-----|-----
ddd | eee | fff
ggg | hh<br>hh | iii
jjj | kkk | lll


### 4.14. **Under construction** Process images or figures <!-- {{{1 -->
- TODO(shimoda): extract text-encoded images.
- TODO(shimoda): resize images to fit the document.


### 4.99. not supported expressions <!-- {{{1 -->
- nested tables.


5. Demo <!-- {{{1 -->
--------------------------
![screenshot in pdf viewer](https://user-images.githubusercontent.com/11357613/70920996-cf9ac080-2066-11ea-81f2-0e7c840ebea1.png)
*screenshot in pdf viewer*



6. History <!-- {{{1 -->
--------------------------
<em class="table-tag">Revision History</em>


dummy text for attr-lists
{: .before-dl-table .table2-8 }

version
: desc

0.5.1
: fixed multiple `<tbody>` element in 

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
If you are feel to nice for this software, please donation to my

-   Bitcoin **| 1FTBAUaVdeGG9EPsGMD5j2SW8QHNc5HzjT |**
-   or Ether **| 0xd7Dc5cd13BD7636664D6bf0Ee8424CFaF6b2FA8f |** .


<!-- vi: fdm=marker
  -->

