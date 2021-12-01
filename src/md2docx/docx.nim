##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import tables

import etree

import docx_element
import docx_para
import docx_section
import docx_runner


type
  WD_TABLE_ALIGNMENT* = enum
    LEFT = 0
    CENTER = 1

  WD_BREAK* = enum
    LINE = 0
    PAGE = 1

  DocumentSettings* = ref object of RootObj
    element*: OxmlElement

  Style* = ref object of RootObj
    discard

  BlockItemContainer* = ref BlockItemContainerObj
  BlockItemContainerObj* = object of RootObj
    ##[ class for Tables or Sections
        can be include: paragraphs or tables

        - x paragraph  -> cannot be include tables.
        - x table      -> cannot
        - o table-cell -> can
        - o section    -> can
    ]##
    items: seq[SectionItem]

  DocxPicture* = ref object of OxmlElement
    discard

  TablePrefWidth* = ref object of OxmlElement
    typ*: string
    w*: Length

  TablePreferences* = ref object of OxmlElement
    tcW*: TablePrefWidth

  TableCell2* = ref object of OxmlElement
    tcPr*: TablePreferences

  TableCell* = ref object of BlockItemContainerObj
    paragraphs*: seq[Paragraph]
    width*: Length
    text*: string
    element*: OxmlElement
    tc*: TableCell2

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

  Document* = ref object of BlockItemContainerObj
    paragraphs*: seq[Paragraph]
    settings*: DocumentSettings
    sections*: seq[Section]
    tables*: seq[DocxTable]
    styles*: Table[string, Style]


proc qn*(src: string): string =  # {{{1
    return src


proc initDocument*(): Document =  # {{{1
    var styles = initTable[string, Style]()
    styles["Table Grid"] = Style()
    styles["List Bullet"] = Style()
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
    ## .. todo:: shimoda sytle
    result = Runner(text: src)
    self.items.add(result)


proc add_break*(self: Runner, typ = WD_BREAK.LINE  # {{{1
                    ): void =
    discard


proc add_picture*(self: Runner, fname: string,  # {{{1
                  args: varargs[tuple[k, v: string]]
                  ): DocxPicture {.discardable.} =
    discard


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
            row.cells.add(TableCell())
        result.rows.add(row)
    self.sections[^1].items.add(result)


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
