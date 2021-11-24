##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##

type
  Element* = ref object of RootObj  # {{{1
    name: string


proc initElement*(name: string): Element =  # {{{1
    result = Element(name: name)


proc append*(self, src: Element): void =  # {{{1
    discard


proc set*(self: Element, name, val: string): void =  # {{{1
    discard


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
