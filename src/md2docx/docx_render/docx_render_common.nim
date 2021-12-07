##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams

import ../docx_common
import ../docx_para
import ../docx_table
import ../private/logging


method render*(self: SectionItem, s: Stream): void {.base.} =  # {{{1
    eror("render: ???")


proc render_length*(self: Length, attr: string, f_unit: bool): string =  # {{{1
    if self == Length.not_set:
        return ""
    var n = 0
    result = ""
    if self.is_percent():
        if f_unit: result = "w:type=\"pct\" "
        n = self.percent_to_int()
    else:
        if f_unit: result = "w:type=\"dxa\" "
        n = int(self)
    result &= "w:" & attr & "=\"" & $n & "\""


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
