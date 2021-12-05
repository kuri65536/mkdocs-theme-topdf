##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams
import strutils
import parsexml
import tables

import logging


type
  XmlElement* = ref XmlElementObj
  XmlElementObj* = object of RootObj
    attrs*: Table[string, string]

  Tag* = ref object of XmlElement
    children*: seq[Tag]
    name*, text*: string
    parent*: Tag

  ElementComment* = ref object of Tag
    discard

var current_content: string
var current_dom: Tag


proc parse_html_push_closed*(self: var seq[Tag], name: string,  # {{{1
                             attrs: seq[tuple[k, v: string]]
                             ): Tag {.discardable.} =
    debg("parse_html:loop: push closed tag(" & $len(self) & ") => " & name)
    var tag = Tag(name: name,
                  attrs: initTable[string, string](), )
    for tup in attrs:
        let (k, v) = tup
        tag.attrs[k] = v
    self[^1].children.add(tag)
    return tag


proc parse_html_push*(self: var seq[Tag], name: string,  # {{{1
                      attrs: seq[tuple[k, v: string]]): Tag {.discardable.} =
    if name in ["meta", "link"]:
        return nil
    debg("parse_html:loop: push tag(" & $len(self) & ") => " & name)
    var tag = Tag(name: name,
                  attrs: initTable[string, string](), )
    tag.children = @[]
    for tup in attrs:
        let (k, v) = tup
        tag.attrs[k] = v
    if len(self) > 0:
        verb("parse_html:loop: push tag  => (lv." & $len(self) & ")=(" &
             $len(self[^1].children) & ")")
        self[^1].children.add(tag)
    self.add(tag)
    return tag


proc parse_html_conv*(name: string): string =  # {{{1
    case name:
    of "nbsp": return " "
    else:
        eror("parse_html:entity: ignored => " & name & " (not implemented)")
    return name


proc register_data*(self: var seq[Tag], data: string): void =  # {{{1
    let tag = self[len(self) - 1]
    var tmp = Tag(parent: tag, children: @[],
                  name: "", text: data)
    tag.children.add(tmp)
    verb("parse_html:data: (" & tag.name & ") => " & tag.text)


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
        verb("parse_html:loop: " & $x.kind)
        case x.kind
        of xmlError: discard
        of xmlEof:   break
        of xmlElementStart: tmp = parse_html_push(stack, x.elementName, @[])
        of xmlElementClose:
            tmp = parse_html_push(stack, tag_opened, attrs)
            attrs = @[]; tag_opened = ""
        of xmlElementEnd:
            if len(tag_opened) > 0:  # self closed tag.
                tmp = parse_html_push_closed(stack, tag_opened, attrs)
                attrs = @[]; tag_opened = ""
            elif len(stack) > 1:
                verb("parse_html:loop: close tag => " & stack[^1].name)
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
            warn("parse_html:loop: root tag = " & tmp.name)

    x.close()
    return result


proc has_attr*(self: Tag, k: string): bool =  # {{{1
    return self.attrs.hasKey(k)


proc find*(self: Tag, name: string): Tag =  # {{{1
    if self.name == name:
        info("parse_html:find: found " & name & "(" & $len(self.children) & ")")
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


proc quote_attrs(src: Stream): Stream =  # {{{1
    result = newStringStream()
    type state_t = enum
        outtag, tag_start, tag_name, tag_in,
        tag_attr_name, tag_attr_name_end,
        tag_attr_value_quoted, tag_attr_value_unquoted,
        tag_closing,
    var (st, buf) = (state_t.outtag, "")
    while true:
        if src.atEnd: break
        var ch = src.readChar()
        case st
        of state_t.outtag:
            if ch == '<': st = state_t.tag_start
        of state_t.tag_start:
            st = if ch == '/': state_t.tag_closing
                 else:         state_t.tag_name
        of state_t.tag_closing:
            if ch == '>': st = state_t.outtag
        of state_t.tag_name:
            if ch == ' ': st = state_t.tag_in
        of state_t.tag_in:
            if ch == ' ': discard
            elif ch == '>': st = state_t.outtag
            elif ch == '/': st = state_t.tag_closing
            else:           st = state_t.tag_attr_name
        of state_t.tag_attr_name:
            if ch == '=': st = state_t.tag_attr_name_end
        of state_t.tag_attr_name_end:
            if ch == ' ':   discard
            elif ch == '"': st = state_t.tag_attr_value_quoted
            else:
                result.write('"')
                st = state_t.tag_attr_value_unquoted
        of state_t.tag_attr_value_unquoted:
            if ch == ' ':
                result.write('"')
                st = state_t.tag_in
            elif ch == '>':
                result.write('"')
                st = state_t.outtag
        of state_t.tag_attr_value_quoted:
            if ch == '"':   st = state_t.tag_in
        result.write(ch)
    result.setPosition(0)
    return result


proc fix_br(src: Stream): Stream =  # {{{1
    ##[ nim's parsexml treat `<br />` to `<br></br>`.
        but `<br>` cannot be handled as single tag.
    ]##
    result = newStringStream()
    while true:
        if src.atEnd: break
        var line = src.readLine()
        if line.contains("<br>"):
            line = line.replace("<br>", "<br />")
        result.write(line & "\n")
    result.setPosition(0)
    return result


proc load*(src: string): void =  # {{{1
    var strm1 = cast[Stream](newStringStream(src))
    var strm2 = quote_attrs(strm1)
    strm1.close()

    strm1 = fix_br(strm2)
    strm2.close()

    current_content = strm1.readAll()
    strm1.close()

    when true:
        let dump = newFileStream("aaa.html", fmWrite)
        dump.write(current_content)
        dump.close()


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
