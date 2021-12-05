##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import tables

import docx_element


type
  RunnerItem* = ref RunnerItemObj
  RunnerItemObj* = object of RootObj

  Runner* = ref RunnerObj
  RunnerObj* = object of RunnerItemObj
    r*: OxmlElement


proc `text`*(self: Runner): string =  # {{{1
    result = ""
    for i in self.r.children:
        if i.name == "w:t":
            result &= i.text
    return result


proc initRunner*(text: string): Runner =  # {{{1
    let t = OxmlElement(name: "w:t", text: text)
    let r = OxmlElement(children: @[t])
    result = Runner(r: r)


proc initRunnerItem*(text: string): RunnerItem =  # {{{1
    result = initRunner(text)


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
