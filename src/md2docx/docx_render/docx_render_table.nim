##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams

import ../docx
import ../docx_para
import ../docx_table
import ../private/logging
import docx_render_para


proc render_table*(self: DocxTable, s: Stream): void


proc render_cell*(self: TableCell, s: Stream): void =  # {{{1
    s.write("""<w:tc><w:tcPr><w:tcW w:type="dxa" w:w="1134"/><w:tcBorders><w:tl2br
w:color="000000" w:space="0" w:val="single" w:sz="4"/></w:tcBorders></w:tcPr>
    """)
    for i in self.items:
        if i of Paragraph:
            cast[Paragraph](i).render_para(s)
        elif i of DocxTable:
            cast[DocxTable](i).render_table(s)
    s.write("</w:tc>")


proc render_table*(self: DocxTable, s: Stream): void =  # {{{1
    s.write("""<w:tblPr><w:tblStyle w:val="TableGrid"/><w:tblW w:type="auto" w:w="0"/>
<w:jc w:val="left"/>
<w:tblLayout w:type="fixed"/><w:tblLook w:firstColumn="1" w:firstRow="1" w:lastColumn="0" w:lastRow="0" w:noHBand="0" w:noVBand="1" w:val="04A0"/>
<w:tblCellMar><w:top w:w="0" w:type="dxa"/>
<w:bottom w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/>
<w:right w:w="108" w:type="dxa"/><w:tblInd w:w="-6" w:type="dxa"/>
</w:tblCellMar></w:tblPr>""")

    s.write("<w:tblGrid>")
    for item in self.columns:
        s.write("""<w:gridCol w:w="2409"/>""")
    s.write("</w:tblGrid>")

    for row in self.rows:
        s.write("<w:tr>")
        s.write("""<w:trPr><w:trHeight w:val="1134"/></w:trPr>""")
        for cell in row.cells:
            eror("render:table: cell(" & $len(cell.items))
            cell.render_cell(s)
        s.write("</w:tr>")

# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
