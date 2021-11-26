##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import tables

import etree


type
  Length* = enum
    zero = 0

  WD_ALIGN_PARAGRAPH* = enum
    RIGHT = 1

  OxmlElement* = ref object of RootObj
    name, text*: string

  DocumentSettings* = ref object of RootObj
    element*: OxmlElement

  Style* = ref object of RootObj
    discard

  Section* = ref object of RootObj
    page_width*, page_height*,
      left_margin*, right_margin*,
      top_margin*, bottom_margin*,
      header_distance*: Length
    header*: Section
    paragraphs*: seq[Paragraph]

  Runner* = ref object of RootObj
    r*: OxmlElement

  Paragraph* = ref object of RootObj
    alignment*: WD_ALIGN_PARAGRAPH
    raw*: OxmlElement

  TableCell* = ref object of RootObj
    discard

  TableRow* = ref object of RootObj
    cells*: seq[TableCell]

  DocxTable* = ref object of RootObj
    rows*: seq[TableRow]

  Document* = ref object of RootObj
    paragraphs*: seq[Paragraph]
    settings*: DocumentSettings
    sections*: seq[Section]
    tables*: seq[DocxTable]
    styles*: Table[string, Style]


proc qn*(src: string): string =  # {{{1
    return src


proc initOxmlElement*(name: string): OxmlElement =  # {{{1
    result = OxmlElement(
        name: name
    )


proc initDocument*(): Document =  # {{{1
    result = Document()


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


proc Mm*(src: int): Length =  # {{{1
    discard


proc add_r*(self: OxmlElement): OxmlElement =  # {{{1
    result = OxmlElement()


proc text*(self: Paragraph): string =  # {{{1
    discard


proc add_run*(self: Paragraph, src: string, style=""  # {{{1
              ): Runner {.discardable.} =
    discard


proc add_paragraph*(self: Document, text = "", style = ""  # {{{1
                    ): Paragraph {.discardable.} =
    discard


proc save*(self: Document, filename: string): void =  # {{{1
    discard


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
