##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams
import parsexml
import tables


type
  XmlElement* = ref XmlElementObj
  XmlElementObj* = object of RootObj
    attrs*: Table[string, string]

  Tag* = ref object of XmlElement
    children*: seq[Tag]
    name*, string*, text*: string
    parent*: Tag

  ElementComment* = ref object of Tag
    discard

var current_content: string
var current_dom: Tag


proc parse_html_push*(self: var seq[Tag], name: string,  # {{{1
                      attrs: seq[tuple[k, v: string]]): Tag {.discardable.} =
    # echo("parse_html:loop: tag => " & name)
    var tag = Tag(name: name,
                  attrs: initTable[string, string]())
    for tup in attrs:
        let (k, v) = tup
        tag.attrs[k] = v
    if len(self) > 0:
        self[^1].children.add(tag)
    self.add(tag)
    return tag


proc parse_html_conv*(name: string): string =  # {{{1
    case name:
    of "nbsp": return " "
    else:
        echo("parse_html:entity: => " & name)
    return name


proc register_data*(self: var seq[Tag], data: string): void =  # {{{1
    let tag = self[len(self) - 1]
    tag.text &= data
    # echo("parse_html:data: => " & tag.text)


proc parse_html*(src: string): Tag =  # {{{1
    var s = newStringStream(src)
    defer: s.close()

    result = nil
    var stack: seq[Tag]
    var tag_opened = ""
    var attrs: seq[tuple[k, v: string]]

    var x: XmlParser
    x.open(s, "tmp.html")
    while true:
        x.next()
        var tmp: Tag = nil
        # echo("parse_html:loop: " & $x.kind)
        case x.kind
        of xmlError: discard
        of xmlEof:   break
        of xmlElementStart: tmp = parse_html_push(stack, x.elementName, @[])
        of xmlElementClose:
            tmp = parse_html_push(stack, tag_opened, attrs)
            tag_opened = ""
        of xmlElementEnd:
            if len(stack) > 1:
                stack.del(len(stack) - 1)
        of xmlElementOpen:
            attrs = @[]; tag_opened = x.elementName
        of xmlAttribute:
            # echo("parse_html:attr: " & x.attrKey)
            attrs.add((x.attrKey, x.attrValue))
        of xmlPI: discard
        of xmlSpecial: discard
        of xmlComment: discard
        of xmlWhitespace: stack.register_data(x.charData)
        of xmlCharData:   stack.register_data(x.charData)
        of xmlEntity:     stack.register_data(parse_html_conv(x.entityName))
        of xmlCData:      stack.register_data(x.charData)

        if isNil(result) and not isNil(tmp):
            result = tmp
            echo("parse_html:loop: root tag = " & tmp.name)

    x.close()
    return result


proc has_attr*(self: Tag, k: string): bool =  # {{{1
    return self.attrs.hasKey(k)


proc find*(self: Tag, name: string): Tag =  # {{{1
    if self.name == name:
        return self
    for i in self.children:
        let ret = i.find(name)
        if not isNil(ret):
            return ret
    return nil


proc find_element*(name: string): Tag =  # {{{1
    if isNil(current_dom):
        current_dom = parse_html(current_content)
    return current_dom.find(name)


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


proc load*(src: string): void =  # {{{1
    current_content = src

# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
