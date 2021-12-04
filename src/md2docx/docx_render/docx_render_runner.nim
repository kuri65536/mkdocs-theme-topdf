##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams

import ../docx_runner
import ../private/logging


method render_run(self: RunnerItem, s: Stream): void {.base.} =  # {{{1
    discard


method render_run(self: Runner, s: Stream): void =  # {{{1
    s.write("""<w:t xml:space="preserve">""" & self.text & "</w:t>")


proc render_runner*(self: RunnerItem, s: Stream): void =  # {{{1
    s.write("""<w:r>""")
    s.write("""<w:rPr><w:rStyle w:val="Strong"/></w:rPr>""")
    self.render_run(s)
    s.write("</w:r>\n")


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
