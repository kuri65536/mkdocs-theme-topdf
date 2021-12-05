##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##

import docx_common
import docx_element
import docx_runner

import private/logging

type
  WD_ALIGN_PARAGRAPH* = enum
    AP_LEFT = 0
    RIGHT = 1

  Paragraph* = ref ParagraphObj
  ParagraphObj* = object of SectionItemObj
    alignment*: WD_ALIGN_PARAGRAPH
    style*: string
    items*: seq[RunnerItem]


proc initParagraph*(): Paragraph =  # {{{1
    ## .. todo:: shimoda sytle
    result = Paragraph(
        style: "Normal", items: @[])


proc initParagraph*(text, style: string): Paragraph =  # {{{1
    ## .. todo:: shimoda sytle
    result = Paragraph(
        style: style,
        items: @[initRunnerItem(text)])


proc dump*(self: Paragraph): void =  # {{{1
    for n, i in self.items:
        debg("dump:para: dump(" & $n & ") => " & i.r.name)


proc add_raw*(self: Paragraph, src: OxmlElement): void =  # {{{1
    verb("manip:para: add_raw(" & $len(self.items) & ") => " & src.name)
    self.items.add(RunnerItem(r: src))


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
