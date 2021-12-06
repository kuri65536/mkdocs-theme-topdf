##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##

import docx_common
import docx_element
import docx_para

type
  TablePrefWidth* = ref object of OxmlElement
    typ*: string
    w*: Length

  TablePreferences* = ref object of OxmlElement
    tcW*: TablePrefWidth

  TableCell2* = ref object of OxmlElement
    tcPr*: TablePreferences

  TableCell* = ref object of BlockItemContainerObj
    width*: Length
    text*: string
    element*: OxmlElement
    tc*: TableCell2


proc initTableCell*(): TableCell =  # {{{1
    result = TableCell(
        width: Length.not_set,
        tc: TableCell2(
            tcPr: TablePreferences(
                tcW: TablePrefWidth()
            ),
        ),
        items: @[cast[SectionItem](
            initParagraph("", "Normal")
        )],
    )


proc `paragraphs`*(self: TableCell): seq[Paragraph] =  # {{{1
    result = @[]
    for i in self.items:
        if not (i of Paragraph):
            continue
        result.add(cast[Paragraph](i))

# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
