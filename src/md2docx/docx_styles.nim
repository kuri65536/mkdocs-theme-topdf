##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import tables

import docx_common

type
  WD_STYLE_TYPE* = enum
    PARAGRAPH = 1

  RGBColor* = ref object of RootObj
    r*, g*, b*: int

  Color* = ref object of RootObj
    rgb*: RGBColor

  Font* = ref object of RootObj
    name*: string
    size*: Length
    italic*: bool
    color*: Color

  ParagraphFormat* = ref object of RootObj
    line_spacing*,
      left_indent*, right_indent*: Length

  Style* = ref object of RootObj
    base_style*: string
    font*: Font
    paragraph_format*: ParagraphFormat

  DocxStyles* = ref object of RootObj
    db: Table[string, Style]


proc initStyle*(): Style =  # {{{1
    result = Style(font: Font(
        color: Color()
      ), paragraph_format: ParagraphFormat(
      ))


proc `[]`*(self: DocxStyles, name: string): Style =  # {{{1
    if name not_in self.db:
        raise newException(ValueError, "not found")
    return self.db[name]


proc contains*(self: DocxStyles, name: string): bool =  # {{{1
    return self.db.contains(name)


proc add_style*(self: DocxStyles, name: string,  # {{{1
                typ: WD_STYLE_TYPE): Style =
    if name in self:
        raise newException(ValueError, "dup.")
    result = initStyle()
    self.db[name] = result
    return result


proc initDocxStyles*(): DocxStyles =  # {{{1
    result = DocxStyles(
        db: initTable[string, Style]()
    )
    result.db["Table Grid"] = Style()
    result.db["List Bullet"] = Style()
    result.db["Quote"] = initStyle()
    return result


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
