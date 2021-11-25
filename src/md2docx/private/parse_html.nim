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
  XmlElement* = ref XmlElementObj
  XmlElementObj* = object of RootObj
    children*: seq[XmlElement]
    attrs*: Table[string, string]

  Tag* = ref object of XmlElement
    name*, string*, text*: string
    parent*: Tag

  ElementComment* = ref object of Tag
    discard


proc find_element*(name: string): Tag =  # {{{1
    return result


proc find_all*(self: Tag, name: string): seq[Tag] =  # {{{1
    result = @[]
    for elem in self.children:
        let i = cast[Tag](elem)
        if len(i.children) > 0:
            let subseq = i.find_all(name)
            result.add(subseq)
        if i.name == name:
            result.add(i)
    return result


proc parents*(self: Tag): seq[Tag] =  # {{{1
    discard


proc next_siblings*(self: Tag): seq[Tag] =  # {{{1
    discard


proc previous_siblings*(self: Tag): seq[Tag] =  # {{{1
    discard


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
