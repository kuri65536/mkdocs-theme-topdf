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
  WD_BREAK* = enum
    LINE = 0
    PAGE = 1

  WD_LINE_SPACING* = enum
    AT_LEAST = 1

  WD_STYLE_TYPE* = enum
    PARAGRAPH = 1

  WD_PARAGRAPH_ALIGNMENT* = enum
    PA_CENTER = 1
    PA_BOTH = 3

  WD_TABLE_ALIGNMENT* = enum
    TA_NOTSET = -1
    LEFT = 0
    CENTER = 1

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
    first_line_indent*, line_spacing*,
      left_indent*, right_indent*,
      space_after*: Length
    alignment*: WD_PARAGRAPH_ALIGNMENT
    line_spacing_rule*: WD_LINE_SPACING

  Style* = ref object of RootObj
    name: string
    base_style_name: string
    font*: Font
    paragraph_format*: ParagraphFormat

  DocxStyles* = ref object of RootObj
    db: Table[string, Style]



proc to_xml*(self: WD_TABLE_ALIGNMENT): string =  # {{{1
    ## ex: `<w:jc w:val="left"/>`
    var ret = ""
    case self:
    of WD_TABLE_ALIGNMENT.TA_NOTSET: return ""
    of WD_TABLE_ALIGNMENT.LEFT:      ret = "left"
    of WD_TABLE_ALIGNMENT.CENTER:    ret = "center"
    return "<w:jc w:val=\"" & ret & "\"/>"


proc `base_style=`*(self: Style, name: string): void =  # {{{1
    self.base_style_name = name


proc `base_style=`*(self: Style, src: Style): void =  # {{{1
    self.base_style_name = src.name


proc initStyle*(): Style =  # {{{1
    result = Style(font: Font(
        color: Color()
      ), paragraph_format: ParagraphFormat(
        alignment: WD_PARAGRAPH_ALIGNMENT.PA_BOTH,
        line_spacing_rule: WD_LINE_SPACING.AT_LEAST,
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
        raise newException(ValueError, "dup.: " & name)
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
    result.db["Normal"] = initStyle()
    return result


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
