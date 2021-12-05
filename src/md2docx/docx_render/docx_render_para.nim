##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams

import ../docx_para
import ../private/logging
import docx_render_common
import docx_render_runner


method render*(self: Paragraph, s: Stream): void =  # {{{1
    const tag = "w:p"
    s.write("\n")
    verb("save:render: para")
    s.write("<" & tag & ">")

    if len(self.style) > 0:
        verb("render:para: pStyle =>" & self.style)
        s.write("<w:pPr><w:pStyle w:val=\"" & self.style & "\" /></w:pPr>")
    else:
        s.write("""<w:pPr><w:pStyle w:val="Normal" /></w:pPr>""")

    for item in self.items:
        item.render_runner(s)
    s.write("</" & tag & ">")


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
