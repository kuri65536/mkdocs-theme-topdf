##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams

import ../docx
import ../docx_common
import ../docx_element
import ../docx_para
import ../docx_table
import ../docx_styles
import ../private/logging
import docx_render_common
import docx_render_para


proc render_table*(self: DocxTable, s: Stream): void


proc render_cell*(self: TableCell, s: Stream): void =  # {{{1
    s.write("<w:tc>")
    var pr = self.width.render_length("w", true)
    if len(pr) > 0:
        debg("render:cell:width => " & pr)
        pr = "<w:tcW " & pr & "/>"
    when true:
        pr &= """<w:tcBorders><w:tl2br w:color="000000" w:space="0"
                   w:val="single" w:sz="4"/></w:tcBorders>"""
    if len(pr) > 0:
        s.write("<w:tcPr>" & pr & "</w:tcPr>")
    for i in self.items:
        if i of docx_para.Paragraph:
            i.render(s)
        elif i of DocxTable:
            cast[DocxTable](i).render_table(s)
    s.write("</w:tc>")


proc render_preferences(self: DocxTable): string =  # {{{1
    var p = """<w:tblStyle w:val="TableGrid"/>"""
    p &= """<w:tblW w:type="auto" w:w="0"/>"""
    p &= """<w:tblLayout w:type="fixed"/>"""
    p &= """<w:tblLook w:firstColumn="1" w:firstRow="1" w:lastColumn="0" w:lastRow="0" w:noHBand="0" w:noVBand="1" w:val="04A0"/>"""
    p &= self.alignment.to_xml()

    var flags = {0}
    for elem in self.preferences.children:
        if elem.name == "w:tblCellMar":
            ##[ ex::
                <w:tblCellMar>
                  <w:top w:w="0" w:type="dxa"/> <w:bottom w:w="0" w:type="dxa"/>
                  <w:left w:w="108" w:type="dxa"/> <w:right w:w="108" w:type="dxa"/>
                  <w:tblInd w:w="-6" w:type="dxa"/>
                </w:tblCellMar>
            ]##
            p &= elem.to_xml()
        else:
            warn("render:table:prefs: ignored: " & elem.name)

    if len(p) < 1:
        return ""
    return "<w:tblPr>" & p & "</w:tblPr>"


proc render_table*(self: DocxTable, s: Stream): void =  # {{{1
    s.write(self.render_preferences())

    s.write("<w:tblGrid>")
    for item in self.columns:
        s.write("""<w:gridCol w:w="2409"/>""")
    s.write("</w:tblGrid>")

    for r, row in self.rows:
        s.write("<w:tr>")
        var h = row.height.render_length("val", false)
        if len(h) > 0:
            s.write("<w:trPr><w:trHeight " & h & "/></w:trPr>")
        for c, cell in row.cells:
            eror("render:table: cell(" & $len(cell.items))
            assert len(cell.items) > 0, "at table (" & $r & "," & $c & ")"
            cell.render_cell(s)
        s.write("</w:tr>")

# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
