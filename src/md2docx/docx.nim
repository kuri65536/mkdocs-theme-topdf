##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import tables

import etree

import ./private/logging
import docx_common
import docx_element
import docx_para
import docx_runner
import docx_section
import docx_styles
import docx_table


type
  WD_BREAK* = enum
    LINE = 0
    PAGE = 1

  DocumentSettings* = ref object of RootObj
    element*: OxmlElement

  DocxPicture* = ref object of OxmlElement
    discard

  Document* = ref object of RootObj
    paragraphs*: seq[Paragraph]  ## .. todo:: shimoda to a property
    settings*: DocumentSettings
    sections*: seq[Section]
    tables*: seq[DocxTable]      ## .. todo:: shimoda to a property
    styles*: DocxStyles


proc initDocument*(): Document =  # {{{1
    var styles = initDocxStyles()
    result = Document(
        settings: DocumentSettings(
            element: initOxmlElement("root")
        ),
        sections: @[Section(
            header: Section(
                items: @[cast[SectionItem](Paragraph(
                    alignment: WD_ALIGN_PARAGRAPH.AP_LEFT,
                ))]
            )
        )],
        styles: styles,
    )


proc initDocument*(fname: string): Document =  # {{{1
    result = Document()


proc get_or_add_tcPr*(self: OxmlElement): OxmlElement =  # {{{1
    result = OxmlElement()


proc text*(self: Paragraph): string =  # {{{1
    discard


proc add_run*(self: Paragraph, src = "", style=""  # {{{1
              ): Runner {.discardable.} =
    verb("manip:para: add_run " & src)
    result = initRunner(src, style)
    self.items.add(result)


proc add_break*(self: Paragraph, typ = WD_BREAK.LINE  # {{{1
                ): Runner {.discardable.} =
    result = initRunner("")
    self.items.add(result)


proc add_picture*(self: Runner, fname: string,  # {{{1
                  args: varargs[tuple[k, v: string]]
                  ): DocxPicture {.discardable.} =
    discard


proc `current_block`*(self: Document): BlockItemContainer =  # {{{1
    return cast[BlockItemContainer](self.sections[^1])


proc `current_para_or_table`*(self: Document): SectionItem =  # {{{1
    return cast[SectionItem](self.sections[^1].items[^1])


proc add_empty_paragraph*(self: Document, style = ""  # {{{1
                          ): Paragraph {.discardable.} =
    result = initParagraph()
    if len(style) > 0:
        result.style = style
    self.sections[^1].items.add(result)


proc add_paragraph*(self: Document, text, style: string  # {{{1
                    ): Paragraph {.discardable.} =
    result = initParagraph(text, style)
    self.sections[^1].items.add(result)


proc add_paragraph*(self: TableCell): Paragraph =  # {{{1
    result = initParagraph("", "Normal")
    self.items.add(cast[SectionItem](result))


proc add_paragraph*(self: BlockItemContainer, text = "", style="Normal"  # {{{1
                    ): Paragraph {.discardable.} =
    ## .. todo:: shimoda sytle
    result = initParagraph(text, style)
    self.items.add(cast[SectionItem](result))


proc merge*(a, b: TableCell): void =  # {{{1
    discard


proc add_table*(self: Document, rows, cols: int): DocxTable =  # {{{1
    verb("manip:table: add (" & $rows & "," & $cols & ")")
    result = DocxTable(
        preferences: initOxmlElement("w:tblPr")
    )
    for i in 1..rows:
        var row = TableRow(height: Length.not_set)
        for i in 1..cols:
            row.cells.add(initTableCell())
        result.rows.add(row)
    self.sections[^1].items.add(result)



# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
