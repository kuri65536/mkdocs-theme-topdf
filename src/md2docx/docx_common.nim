##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##


type
  Length* = enum  # dxa (1/1440 inch)
    not_set = -200000
    zero = 0
    low = 1
    max = 100000

  BlockItemContainer* = ref BlockItemContainerObj
  BlockItemContainerObj* = object of RootObj
    ##[ class for Tables or Sections
        can be include: paragraphs or tables

        - x paragraph  -> cannot be include tables.
        - x table      -> cannot
        - o table-cell -> can
        - o section    -> can
    ]##
    items*: seq[SectionItem]

  SectionItem* = ref SectionItemObj
  SectionItemObj* = object of RootObj
    ##[ class for children such as Paragraphs and Tables
    ]##


proc Mm*(src: float): Length =  # {{{1
    ##[ - 25.4mm = 1inch  -> 1440 dxa
    ]##
    return Length(int(1440.0 * src / 25.4 + 0.5))


proc Mm*(src: int): Length =  # {{{1
    return Mm(float(src))


proc Pt*(n: int): Length =  # {{{1
    return Length(n)


proc is_percent*(self: Length): bool =  # {{{1
    return (int(self) and 0x1000_0000) != 0


proc percent_to_int*(self: Length): int =  # {{{1
    return int(self) and 0x0FFF_FFFF


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
