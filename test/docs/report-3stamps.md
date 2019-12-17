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


Abstract
--------------------------
this is a sample of japan style technical report.


Conclusion
--------------------------
- this is a sample of japan style technical report.
- include edit/ check/ approve stamps.


Contents
--------------------------
[TOC]



Features of this plugin
--------------------------

### Script and Styles for stamps
- made by a dl-dt-dd markup in markdown.
- made by 1dt, 3dd.
- place after an elment have `class="table-3stamps"` .
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



### Script and Styles for tables
- this function is for improve to enable markdown syntax to  
    multi-line tables

- CSS-styles predefined in `_extra.pdf`

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



Demo
--------------------------
![screenshot in pdf viewer](https://user-images.githubusercontent.com/11357613/70920996-cf9ac080-2066-11ea-81f2-0e7c840ebea1.png)



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



Donations
---------------------
If you are feel to nice for this software, please donation to my

-   Bitcoin **| 1FTBAUaVdeGG9EPsGMD5j2SW8QHNc5HzjT |**
-   or Ether **| 0xd7Dc5cd13BD7636664D6bf0Ee8424CFaF6b2FA8f |** .




