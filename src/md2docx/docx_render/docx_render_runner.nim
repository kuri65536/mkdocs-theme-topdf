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


proc to_string_open(self: OxmlElement): string =  # {{{1
    result = "<" & self.name
    for k, v in self.attrs.pairs():
        result &= " " & k & "=\"" & v & "\""
    if len(self.children) < 1:
        return result & " />"
    return result & ">"


proc to_string(self: OxmlElement): string =  # {{{1
    if self.name == "w:t":
        let text = self.text.replace("<", "&lt;").replace(">", "&gt;")
        result = """<w:t xml:space="preserve">""" & text & "</w:t>"
        return result

    warn("render:oxml: raw element: " & self.name)
    result = self.to_string_open()
    if len(self.children) < 1:
        return result
    for i in self.children:
        result &= i.to_string()
    return result & "</" & self.name & ">"


method render_run(self: RunnerItem, s: Stream): void {.base.} =  # {{{1
    for i in self.r.children:
        verb("render:run: " & i.name)
        if i.name == "w:t":
            s.write(i.to_string())
        else:
            debg("render:run: " & i.name & " (not w:t)")
            s.write(i.to_string())


proc render_runner*(self: RunnerItem, s: Stream): void =  # {{{1
    s.write("\n " & self.r.to_string_open())
    if len(self.r.children) < 1:
        return
    if self.r.name == "w:r":
        discard #[
        s.write("""<w:rPr><w:rStyle w:val="Strong"/></w:rPr>""")
        ]#
    self.render_run(s)
    s.write("</" & self.r.name & ">")


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
