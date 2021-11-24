##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import parsexml
import tables


type
  XmlElement* = ref object of RootObj
    children: seq[XmlElement]
    attrs: Table[string, string]


proc find_element*(name: string): XmlElement =  # {{{1

    return result

# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
