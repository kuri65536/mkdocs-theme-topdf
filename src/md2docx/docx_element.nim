##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import tables


type
  OxmlElement* = ref object of RootObj
    name*, text*: string
    attrs*: Table[string, string]
    children*: seq[OxmlElement]


proc initOxmlElement*(name: string): OxmlElement =  # {{{1
    result = OxmlElement(
        name: name
    )


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
