##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import tables

import etree
import private/logging


type
  OxmlElement* = ref object of RootObj
    name*, text*: string
    attrs*: Table[string, string]
    children*: seq[OxmlElement]


proc initOxmlElement*(name: string): OxmlElement =  # {{{1
    result = OxmlElement(
        name: name, text: "", children: @[],
        attrs: initTable[string, string]()
    )


proc append*(self: ptr OxmlElement, src: OxmlElement): void =  # {{{1
    discard


proc append*(self: OxmlElement, src: Element): void =  # {{{1
    discard


proc append*(self, src: OxmlElement): void =  # {{{1
    warn("manip:oxml: raw element add:" & self.name & "<-" & src.name)
    self.children.add(src)


proc qn*(src: string): string =  # {{{1
    return src


proc set*(self: OxmlElement, name, val: string): void =  # {{{1
    self.attrs[name] = val


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
