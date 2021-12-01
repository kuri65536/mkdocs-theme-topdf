##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams

import ../docx_para
import docx_render_runner


proc render_para*(self: Paragraph, s: Stream): void =  # {{{1
    s.write("""<w:p>""")
    s.write("""<w:pPr><w:pStyle w:val="Title"/></w:pPr>""")
    for i in self.items:
        i.render_runner(s)
    s.write("</w:p>")


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
