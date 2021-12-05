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
  Section* = ref object of BlockItemContainerObj
    page_width*, page_height*,
      left_margin*, right_margin*,
      top_margin*, bottom_margin*,
      header_distance*: Length
    header*: Section


proc `paragraphs`*(self: Section): seq[Paragraph] =  # {{{1
    result = @[]
    for i in self.items:
        if not (i of Paragraph):
            continue
        result.add(cast[Paragraph](i))


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
