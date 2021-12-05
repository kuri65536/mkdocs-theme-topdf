##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams
import strutils
import tables

import ../docx_element
import ../docx_runner
import ../private/logging


proc to_string(self: OxmlElement): string =  # {{{1
    result = "<" & self.name
    for k, v in self.attrs.pairs():
        result &= " " & k & "=\"" & v & "\""
    if len(self.children) < 1:
        return result & " />"
    result &= ">"
    for i in self.children:
        result &= i.to_string()
    return result & "</" & self.name & ">"


method render_run(self: RunnerItem, s: Stream): void {.base.} =  # {{{1
    discard


method render_run(self: Runner, s: Stream): void =  # {{{1
    for i in self.r.children:
        if i.name == "w:t":
            let text = self.text.replace("<", "&lt;").replace(">", "&gt;")
            s.write("""<w:t xml:space="preserve">""" & text & "</w:t>")
        else:
            s.write(i.to_string())


proc render_runner*(self: RunnerItem, s: Stream): void =  # {{{1
    s.write("""<w:r>""")
    s.write("""<w:rPr><w:rStyle w:val="Strong"/></w:rPr>""")
    self.render_run(s)
    s.write("</w:r>\n")


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
