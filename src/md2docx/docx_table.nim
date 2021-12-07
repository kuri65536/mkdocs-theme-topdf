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
import docx_styles

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

  TableColumn* = ref object of RootObj
    cells*: seq[TableCell]

  TableRow* = ref object of RootObj
    cells*: seq[TableCell]
    height*: Length

  DocxTable* = ref DocxTableObj
  DocxTableObj* = object of SectionItemObj
    rows*: seq[TableRow]
    autofit*: bool
    allow_autofit*: bool
    style*: string
    alignment*: WD_TABLE_ALIGNMENT
    preferences*: OxmlElement


proc `width=`*(self: TableColumn, src: Length): void =  # {{{1
    for i in self.cells:
        i.width = src


proc initTableCell*(): TableCell =  # {{{1
    result = TableCell(
        width: Length.not_set,
        tc: TableCell2(
            tcPr: TablePreferences(
                tcW: TablePrefWidth()
            ),
        ),
        items: @[],
    )


proc `paragraphs`*(self: TableCell): seq[Paragraph] =  # {{{1
    result = @[]
    for i in self.items:
        if not (i of docx_para.Paragraph):
            continue
        result.add(cast[Paragraph](i))


proc `columns`*(self: DocxTable): seq[TableColumn] =  # {{{1
    result = @[]
    for n, row in self.rows:
        for c, cell in row.cells:
            if n == 0:
                result.add(TableColumn(
                    cells: @[cell]
                ))
            else:
                result[c].cells.add(celL)
    return result


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
