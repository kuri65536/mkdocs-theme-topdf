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
  WD_TABLE_ALIGNMENT* = enum
    LEFT = 0
    CENTER = 1

  WD_BREAK* = enum
    LINE = 0
    PAGE = 1

  DocumentSettings* = ref object of RootObj
    element*: OxmlElement

  DocxPicture* = ref object of OxmlElement
    discard

  TableColumn* = ref object of RootObj
    cells*: seq[TableCell]
    width*: Length

  TableRow* = ref object of RootObj
    cells*: seq[TableCell]
    height*: Length

  DocxTable* = ref DocxTableObj
  DocxTableObj* = object of SectionItemObj
    rows*: seq[TableRow]
    columns*: seq[TableColumn]
    autofit*: bool
    allow_autofit*: bool
    style*: string
    alignment*: WD_TABLE_ALIGNMENT
    preferences*: OxmlElement

  Document* = ref object of RootObj
    paragraphs*: seq[Paragraph]
    settings*: DocumentSettings
    sections*: seq[Section]
    tables*: seq[DocxTable]
    styles*: DocxStyles


proc qn*(src: string): string =  # {{{1
    return src


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


proc append*(self: OxmlElement, src: Element): void =  # {{{1
    discard


proc append*(self: ptr OxmlElement, src: OxmlElement): void =  # {{{1
    discard


proc append*(self, src: OxmlElement): void =  # {{{1
    discard


proc set*(self: OxmlElement, name, val: string): void =  # {{{1
    discard


proc Mm*(src: float): Length =  # {{{1
    discard


proc Mm*(src: int): Length =  # {{{1
    discard


proc add_r*(self: OxmlElement): OxmlElement =  # {{{1
    result = OxmlElement()


proc get_or_add_tcPr*(self: OxmlElement): OxmlElement =  # {{{1
    result = OxmlElement()


proc text*(self: Paragraph): string =  # {{{1
    discard


proc add_run*(self: Paragraph, src = "", style=""  # {{{1
              ): Runner {.discardable.} =
    ## .. todo:: shimoda: add sytle
    warn("docx:man:run: add " & src)
    result = Runner(text: src)
    self.items.add(result)


proc add_break*(self: Runner, typ = WD_BREAK.LINE  # {{{1
                    ): void =
    discard


proc add_picture*(self: Runner, fname: string,  # {{{1
                  args: varargs[tuple[k, v: string]]
                  ): DocxPicture {.discardable.} =
    discard


proc `current_block`*(self: Document): BlockItemContainer =  # {{{1
    return cast[BlockItemContainer](self.sections[^1])


proc add_paragraph*(self: Document, text = "", style = ""  # {{{1
                    ): Paragraph {.discardable.} =
    ## .. todo:: shimoda sytle
    result = initParagraph(text)
    self.sections[^1].items.add(result)


proc add_paragraph*(self: TableCell): Paragraph =  # {{{1
    ## .. todo:: shimoda text and sytle
    result = initParagraph("")
    self.items.add(cast[SectionItem](result))


proc add_paragraph*(self: BlockItemContainer, src = "", style=""  # {{{1
                    ): Paragraph {.discardable.} =
    ## .. todo:: shimoda sytle
    result = initParagraph(src)
    self.items.add(cast[SectionItem](result))


proc merge*(a, b: TableCell): void =  # {{{1
    discard


proc add_table*(self: Document, rows, cols: int): DocxTable =  # {{{1
    result = DocxTable()
    for i in 1..rows:
        var row = TableRow()
        for i in 1..cols:
            row.cells.add(initTableCell())
        result.rows.add(row)
    self.sections[^1].items.add(result)


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
