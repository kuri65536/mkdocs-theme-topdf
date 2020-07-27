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


### 4.2. Script and Styles for stamps <!-- {{{1 -->
- made by a dl-dt-dd markup in markdown, made by 1dt, 3dd.
- place after an elment have `class="table-3stamps"` .
- if stamp fields have no `<br>`, the slash line will be insereted.
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
- [@R4-3-1] **bugfix**: tables are always auto width
    in MS Word (not in LibreOffice).

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


<br>

<p class="before-dl-table table2-4-4"></p>

20%
: 40%
: 40%


<br>

<p class="before-dl-table table2-2-2-4"></p>

20%
: 20%
: 20%
: 40%


<br>

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


### 4.5. **(Under fix)** TOC <!-- {{{1 -->
- insert docx `TOC` field at `[TOC]` in markdown
- now support just embed a `TOC` field into document.  
    FIXME(shimoda): manipurate TOC contents by script
- LibreOffice users will need to update the `TOC` field by manual.
- MS Word may ask to update the TOC field at launch,

    - from [pandoc issue #458](https://github.com/jgm/pandoc/issues/458),
        the `dirty` flag at a field element and `updateFields` in settings.xml

- **TODO(shimoda)** remove line-height or
    reduce extra spaces after paragraph of TOC.


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
- **TODO(shimoda)** id attributes to bookmarks

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


### 4.11. **(Under fix)** nested paragraphs <!-- {{{1 -->
- not support nested p or div. this app just flat them.
- nested `ul` or `ol` `li` tags inside `ul` or `ol`, a sample markup::
- **TODO(shimoda)** remove line-height or
    reduce extra spaces after paragraph of ul-li-ul-li.

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
        {: #test-nested-lists}
    - bbb2
- cccc
    - ccc1
    - ccc2
- dddd
    - ddd1
    - ddd2
        - [ddd2-1](#test-nested-lists)
        - ddd2-2
            - ddd2-2-1
            - ddd2-2-2
        - ddd2-3
- eeee
    1. eee-1
    2. eee-2


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




### 4.13. **(Under fix)** tables <!-- {{{1 -->
- **TODO(shimoda)** apply extra style to header.
- sample markup::

```
<p class="none table2-6-2"></p>

aaa | bbb | ccc
----|-----|-----
ddd | eee | fff
ggg | hh<br>hh | iii
jjj | kkk | lll
```

<p class="none table2-6-2"></p>

aaa | bbb | ccc
----|-----|-----
ddd | eee | fff
ggg | hh<br>hh | iii
jjj | kkk | lll


sample markup for small columns
{: .table2-6-10mm-10mm-10mm}

term | desc. | ok | t1 | t2
-----|-------|----|----|---
name1 | abc  | o  | W  | R
name2 | bcd  | x  |    | R
...   | ...  | .. | .. | ..
name3 | co2  | o  | W  |



fit to contents
{: .table1-a-2-a-a-a}

name   | lvl | desc | 1 | 2 | 3
-------|-----|------|---|---|---
aby    | 6   | o    | dddddd   | s | aaaaa
billy  | 7   | x    | eeeeeeee | s | bb
catoly | ?   | o    | ff       | o | ccccccccccccc
haty   | 3   | o    | ggg      | p | hhhh


### 4.13.1. **(Under construction)** rowspan and colspan <!-- {{{1 -->
- you need to generate tables have rowspan and colspan attributes by
    the `cell_row_span` extension.
- **TODO(shimoda):** can't parse rowspan and colspan now, test-case:


|name   | lvl | desc |
|-------|-----|------|
|aby    | 6   | o    |
|_     _| 7   | x    |
|catoly | ?         ||
|haty   | 3   | o    |


### 4.14. **(Under fix)** Process images or figures <!-- {{{1 -->
- extract base64-encoded images.
    - plantuml outputs in mkdocs documents.
- resize images to fit the document.
- **TODO(shimoda):** multiple images at one line.
- **TODO(shimoda):** center images at some rules.

![uml diagram](data:image/png;base64,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)


### 4.15. Styles for docx <!-- {{{1 -->
- **TODO(shimoda):** set styles to images.
    - one line.
    - set paragraph style (vertical-align) to top


### 4.16. **(Under construction)** Convert KaTex <!-- {{{1 -->
- implement convert method of KaTex XML.
- sample::

<p><span class="katex-display"><span class="katex">
 <span class="katex-mathml">
  <math><semantics><mrow>
    <mi>D</mi><mi>a</mi><mi>t</mi>
    <msub><mi>a</mi>
      <mrow><mi>g</mi><mi>a</mi><mi>i</mi><mi>n</mi></mrow></msub>
    <mo>=</mo>
    <mo stretchy="false">(</mo><mi>D</mi><mi>a</mi><mi>t</mi>
    <msub><mi>a</mi>
      <mrow><mi>r</mi><mi>a</mi><mi>w</mi></mrow></msub>
    <mo>+</mo><mtext>Offset</mtext><mo stretchy="false">)</mo>
    <mo>×</mo><mtext>Gain</mtext>
  </mrow>
  <annotation encoding="application/x-tex">
    Data_{gain}=(Data_{raw} + \text{Offset})× \text{Gain}
  </annotation></semantics></math>
 </span>
 <span aria-hidden="true" class="katex-html">
  <span class="base">
    <span class="strut" style="height:0.969438em;vertical-align:-0.286108em;"></span>
    <span class="mord mathdefault" style="margin-right:0.02778em;">D</span>
    <span class="mord mathdefault">a</span><span class="mord mathdefault">t</span>
    <span class="mord"><span class="mord mathdefault">a</span>
    <span class="msupsub"><span class="vlist-t vlist-t2"><span class="vlist-r">
    <span class="vlist" style="height:0.311664em;">
    <span style="top:-2.5500000000000003em;margin-left:0em;margin-right:0.05em;">
    <span class="pstrut" style="height:2.7em;"></span>
    <span class="sizing reset-size6 size3 mtight"><span class="mord mtight">
    <span class="mord mathdefault mtight" style="margin-right:0.03588em;">g</span>
    <span class="mord mathdefault mtight">a</span>
    <span class="mord mathdefault mtight">i</span>
    <span class="mord mathdefault mtight">n</span>
    </span></span></span></span>
    <span class="vlist-s">​</span></span>
    <span class="vlist-r"><span class="vlist" style="height:0.286108em;"><span>
    </span></span></span></span></span></span>
    <span class="mspace" style="margin-right:0.2777777777777778em;"></span>
    <span class="mrel">=</span>
    <span class="mspace" style="margin-right:0.2777777777777778em;"></span></span>
  <span class="base">
    <span class="strut" style="height:1em;vertical-align:-0.25em;"></span>
    <span class="mopen">(</span>
    <span class="mord mathdefault" style="margin-right:0.02778em;">D</span>
    <span class="mord mathdefault">a</span><span class="mord mathdefault">t</span>
    <span class="mord"><span class="mord mathdefault">a</span><span class="msupsub">
    <span class="vlist-t vlist-t2"><span class="vlist-r">
    <span class="vlist" style="height:0.151392em;">
    <span style="top:-2.5500000000000003em;margin-left:0em;margin-right:0.05em;">
    <span class="pstrut" style="height:2.7em;"></span>
    <span class="sizing reset-size6 size3 mtight"><span class="mord mtight">
    <span class="mord mathdefault mtight" style="margin-right:0.02778em;">r</span>
    <span class="mord mathdefault mtight">a</span>
    <span class="mord mathdefault mtight" style="margin-right:0.02691em;">w
    </span></span></span></span></span>
    <span class="vlist-s">​</span></span>
    <span class="vlist-r"><span class="vlist" style="height:0.15em;">
    <span></span></span></span></span></span></span>
    <span class="mspace" style="margin-right:0.2222222222222222em;"></span>
    <span class="mbin">+</span>
    <span class="mspace" style="margin-right:0.2222222222222222em;"></span>
  </span>
  <span class="base">
    <span class="strut" style="height:0.77777em;vertical-align:-0.08333em;"></span>
    <span class="mord text"><span class="mord">Offset</span></span>
    <span class="mspace" style="margin-right:0.2222222222222222em;"></span>
  </span>
  <span class="base">
    <span class="strut" style="height:1em;vertical-align:-0.25em;"></span>
    <span class="mclose">)</span>
    <span class="mspace" style="margin-right:0.2222222222222222em;"></span>
    <span class="mbin">×</span>
    <span class="mspace" style="margin-right:0.2222222222222222em;"></span>
  </span>
  <span class="base">
    <span class="strut" style="height:0.76666em;vertical-align:-0.08333em;"></span>
    <span class="mord text"><span class="mord">Gain</span></span>
  </span>
 </span>
</span></span></p>


### 4.17. footnotes2 <!-- {{{1 -->
belows are sample content for this footnotes2 extension.

requirements for this theme

- [@R1-1] convert markdown to print.
- [@R2-1] convert markdown to presentation.
- [@R2-2] convert images to print/ presentation.


specifications for this theme

- [@S1-1-1] mkdocs (python-markdown)
- [@S1-1-2] parse HTML and make output: beautiful-soup4, python-docx
- [@S2-1-1] javascript, CSS
- [@S2-1-2] javascript for navigations


designs for this theme

- [@D1-1-1] script `mkdocs`, setup this plugin.
- [@D1-1-2-1] parse HTML: `html_conv_docx.py`, manipulate docx: `common.py`


program/scripts for this theme

- [@P1-1-1] Makefile/ setup.py and mkdocs.yml
- [@P1-1-2] `topdf/html_conv_docx.py` ...
- [@R1-1] test, same id from multi-positions.


<p class="before-dl-table table3-7"></p>

///Footnotes2 Go Here///


### 4.18. navigation controller <!-- {{{1 -->
- implement a navigation controller for presentations.
- **TODO(shimoda):** enable/disable in docuemnt or setup.


### 4.19. fixed: duplicated carridge return <!-- {{{1 -->
- [@R4-19-1] treat return caracters as space or nothing.
- test1: insert duplicated carridge returns (breaks)  
    after br element on paragraph.
- test2: paragraph1  
    contains 1 return  
    contains 2 return  
    contains 3 return  


### 4.20. guide: conditional documents <!-- {{{1 -->
- by pcpp.
- you can use [my verseion](https://github.com/kuri65536/pcpp)
    to preserve trailing whitespaces for  
    make return sentens, `<br />` elements.

```bash
$ ./venv/bin/pip install https://github.com/kuri65536/pcpp
```


#if 0

sample  
document not output.

#endif


### 4.99. not supported expressions <!-- {{{1 -->
- [@4-99-001] sup elements.
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
: descriptions

0.5.1
: fixed multiple `<tbody>` elements in dl-tables.

0.5.0
: add a script: fix the mkdocs invalid html-id to prevent paged.js exceptions.

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

