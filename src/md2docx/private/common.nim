# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import /usr/lib/nim/pure/options
import algorithm
import hashes
import os
import strutils
import tables

import ../docx
import ../docx_common
import ../docx_element
import ../docx_para
import ../docx_styles
import logging
import parse_html

export Option, get, isNone, isSome, none, some

type
  StylesObj = object of RootObj
    ##[- define styles in `init_***` and
       - call `init_***` methods when styles were not defiend.
    ]##
    allocated: seq[string]

  fn_style = proc(self: StylesObj, doc: Document, name: string): string

  Global = ref object of RootObj
    seq_files: seq[string]
    numbers_of_captions: Table[string, int]
    funcs_style_init: Table[string, fn_style]
    bookmark_id: int

  ParseError* = object of CatchableError


var glb = Global(
        funcs_style_init: initTable[string, fn_style](),
        bookmark_id: 1
)
var Styles* = StylesObj()


#[
import base64
import sys
from tempfile import NamedTemporaryFile as Temporary
from typing import (Callable, Dict, Iterable, List, Optional, Set,
                    Text, Tuple, )
import zlib

from docx.enum.style import WD_STYLE_TYPE  # type: ignore
from docx.enum.text import (                  # type: ignore
        WD_COLOR_INDEX, WD_LINE_SPACING, WD_PARAGRAPH_ALIGNMENT, )
from docx.oxml import OxmlElement  # type: ignore
from docx.oxml.ns import qn  # type: ignore
from docx.shared import Mm, Pt, RGBColor  # type: ignore
from docx.text.paragraph import Paragraph  # type: ignore
from bs4.element import Tag  # type: ignore
import get_image_size  # type: ignore


try:
    import requests
    f_not_online = False
except ImportError:
    f_not_online = True


]#
proc parse_trailing_numbers(src: string): tuple[s: string, n: int] =  # {{{1
    var (ret_n, ret) = (0, "")
    for n, ch in reversed(src):
        if len(ret) > 0:
            ret = ch & ret
            continue
        if ch not_in "0123456789":
            ret = $ch
            continue
        ret_n += int(ch) - int('0')
    return (ret.strip(leading = false, trailing = true), ret_n)


proc has_class*(tag: Tag, names: varargs[string]): bool =  # {{{1
    const key = "class"
    if len(tag.name) < 1:
        return false
    let cls = tag.attrs.getOrDefault(key, "")
    let classes = cls.split(" ")
    for name in names:
        if classes.contains(name):
            return true
    return false


proc has_prev_sibling*(target: Tag, tags: varargs[string]): bool =  # {{{1
    for elem in target.previous_siblings:
        if len(elem.name) < 1:
            continue
        if elem.name in tags:
            return true
        break
    return false


proc has_next_table*(target: Tag): bool =  # {{{1
    for elem in target.next_siblings:
        if len(elem.name) < 1:
            continue
        if elem.name == "table":
            return true
        break
    let parent = target.parent
    if isNil(parent):
        return false
    for elem in parent.next_siblings:
        if len(elem.name) < 1:
            continue
        if elem.name == "p":
            let cls = elem.attrs.getOrDefault("class", "").split(" ")
            if "before-dl-table" in cls:
                return true
        break
    return false


proc has_width_and_parse*(classes: seq[string]  # {{{1
                          ): tuple[s: string, l: seq[Length]] =
    proc parse_float_or_0(src: string): float =
        var n: float
        try:
            n = parseFloat(src)
        except ValueError:
            return 0.0
        return n

    proc parse_base(src: string): float =
        var (n_max, n_sum) = (0.0, 0.0)
        for num in src.split("-"):
            var n: float
            n = parse_float_or_0(num)
            if n <= 0.0:
                if num == "a":
                    continue
                if num.endswith("mm") and parse_float_or_0(num[0..^2]) > 0.0:
                    continue
                return NaN
            (n_max, n_sum) = (max(n, n_max), n_sum + n)
        if n_sum > 10.49999:
            return 160.0 / n_sum
        return float(160 / 10)

    var src: string
    src = ""
    for cls in classes:
        if cls.startswith("table"):
            src = cls
            break
    if len(src) < 1:
        return ("", @[])
    var
        ret: seq[Length] = @[]
        base: float
    base = parse_base(src[5..^1])
    if base != base:
        return ("", @[])
    for num in src[5..^1].split("-"):
        if num == "a":
            ret.add(Mm(0))
            continue
        if num.endswith("mm"):
            var n = parse_float_or_0(num[0..^2])
            ret.add(Mm(n))
            continue
        var n: float
        n = parse_float_or_0(num)
        ret.add(Mm(n * base))
    return (src, ret)


proc count_tags_around_image*(src: Tag): int =  # {{{1
    ## [@P14-1-12] image under a rule
    if isNil(src):
        return 0
    var i: int
    i = 0
    for elem in src.children:
        if len(elem.name) < 1:
            continue
        i += 1
    return i


proc classes_from_prev_sibling*(target: Tag): seq[string] =  # {{{1
    for elem in reversed(target.previous_siblings):
        if len(elem.name) < 1:
            continue
        verb("prev_sibling: " & $elem.attrs)
        var ret = elem.attrs.getOrDefault("class", "").split(" ")
        return ret
    return @[]


proc table_cellspan*(e: Tag, keys: varargs[string]): seq[int] =  # {{{1
    var ret: seq[int] = @[]
    for key in keys:
        if e.has_attr(key):
            let n = parseInt(e.attrs.getOrDefault(key, "0"))
            ret.add(n - 1)
        else:
            ret.add(0)
    return ret


iterator sorted_by_keys*[A, B](self: TableRef[A, B],  # {{{1
                               fn: proc(a, b: A): int): tuple[key: A, val: B] =
    assert isNil(self) == false
    var keys: seq[A]
    for k in self.keys():
        keys.add(k)
    for k in sorted(keys, fn):
        yield (k, self[k])


proc table_update_rowcolspan*(dct: TableRef[tuple[r, c: int], Tag]  # {{{1
                              ): TableRef[tuple[r, c: int], Tag] =
    ## [@P13-1-13] alignment cell potisions
    proc cmp_rc(a, b: tuple[r, c: int]): int =
        if a.r > b.r: return 1
        if a.r < b.r: return -1
        if a.c > b.c: return 1
        if a.c < b.c: return -1
        return 0

    proc update(self: var seq[int], src: seq[int]): void =
        for i in src:
            self.add(i)

    # echo("rcspan: enter1")
    var
        rowspans: seq[seq[int]]
        ret = newTable[tuple[r, c: int], Tag]()
        (r, c) = (-1, 0)
    # echo("rcspan: enter2")
    for tup, elem in sorted_by_keys(dct, cmp_rc):
        # echo("rcspan: enter3")
        let (row, col) = tup
        if r != row:
            rowspans = if len(rowspans) > 0: rowspans[1..^1] else: @[@[0]]
        (r, c) = (row, col)
        if len(rowspans) < 1:
            c = 1
        else:
            while c in rowspans[0]:
                c += 1
        var x, y: int
        (x, y) = table_cellspan(elem, "colspan", "rowspan")
        var cols = @[c]
        ret[(r, c)] = elem
        if x != 0:
            for i in 1..x:
              if cols.contains(i):
                cols.add(c + i)
        if len(rowspans) < 1:
            rowspans = @[cols]
        else:
            rowspans[0].update(cols)
        if y != 0:
            for i in 1..y:
                if i >= len(rowspans):
                    rowspans.add(cols)
                else:
                    rowspans[i].update(cols)
    #[
    """while True:  # dump cells information
        r, msg = -1, ""
        for (row, col), elem in sorted(ret.items(), key=lambda x: x[0]):
            x, y = table_cellspan(elem, "colspan", "rowspan")
            if r != row:
                warn("common.table:" + msg[1:])
                msg, r = "", row
            msg += ",(%d,%d" % (row, col)
            if x > 0 or y > 0:
                msg += "-%d,%d" % (x, y)
            msg += ")"
        if len(msg):
            warn("common.table:" + msg[1:])
        break"""
    ]#
    return ret
#[


def is_online_mode() -> bool:  # {{{1
    import socket
    socket.setdefaulttimeout(1.0)
    try:
        socket.gethostbyname("www.python.org")
        return True
    except OSError:
        pass
    return False


def init(force_offline: bool) -> None:  # {{{1
    global f_not_online
    if f_not_online:
        warn("img-tag: package 'requests' required, "
             "online images will be ignored...")
        return

    if force_offline is not True and is_online_mode():
        f_not_online = False
    else:
        warn("img-tag: now in off-line mode, "
             "online images will be ignored...")
        f_not_online = True


]#
proc is_target_in_http*(url: string): bool =  # {{{1
    if url.startsWith("http://"):
        return true
    elif url.startsWith("https://"):
        return true
    return false


proc remove_temporaries*(): void =  # {{{1
    for fname in glb.seq_files:
        try:
            os.removeFile(fname)
        except OSError:
            discard
    try:
        os.removeDir("tmp")
    except OSError:
        discard


proc download_image*(url_doc: string, src: string): string =  # {{{1
    discard
#[
    # absolute
    if src.startswith("http://"):
        fname = download_image_run(src)
    elif src.startswith("https://"):
        fname = download_image_run(src)
    elif src.startswith("file://"):
        fname = src[7:]  # just remove prefix
    elif src.startswith("data:image/"):
        fname = download_image_extract(src)
    elif "://" in src:
        eror("img-tag: url was not recognized, ignored...: " + src)
        return ""
    else:  # relative
        if is_target_in_http(url_doc):
            src = download_image_unified_http(url_doc, src)
            fname = download_image_run(src)
        else:
            dname = os.path.dirname(url_doc)
            fname = os.path.join(dname, src)
            fname = os.path.realpath(fname)

    if os.path.exists(fname):
        return fname
    warn("img-tag: file is not found: " + fname)
    return ""


def download_image_run(url: Text) -> Text:  # {{{1
    if f_not_online:
        eror("img-tag: now offline, ignored: " + url)
        return ""

    sfx = url.split("?")[0]   # remove the request string.
    sfx = sfx.split(".")[-1]  # remove prefix.
    if sfx.lower() not in ("jpg", "png", "svg", "tiff", "tif", "gif"):
        eror("img-tag: unsupported format: " + sfx)
        return ""
    sfx = "." + sfx

    resp = requests.get(url)
    if (resp.status_code / 100) != 2:
        return ""  # failed to download

    dname, fname = "tmp", ""
    if not os.path.exists(dname):
        os.mkdir(dname)
    with Temporary(mode="w+b", dir=dname, suffix=sfx, delete=False
                   ) as fp:
        fname = fp.name
        fp.write(resp.content)
    glb.seq_files.append(fname)
    return fname


def download_image_unified_http(url: Text, src: Text) -> Text:  # {{{1
    # TODO(shimoda): check target url and manipulate url of images.
    if url.endswith("/"):
        return url + src
    seq = url.split("/")
    seq = seq[:-1]
    seq.append(src)
    return "/".join(seq)


def download_image_extract(url: Text) -> Text:  # {{{1
    url = url[11:]  # remove "data:image/"
    if ";" not in url:
        return ""
    i = url.index(";")
    sfx = "." + url[:i]
    url = url[i:]
    if "," not in url:
        return ""
    i = url.index(",")
    if not url.startswith(";base64,"):
        warn("img-tag: now support extract from base64: " + url[:i])
        return ""
    url = url[i:]
    data = base64.b64decode(url)

    dname, fname = "tmp", ""
    if not os.path.exists(dname):
        os.mkdir(dname)
    with Temporary(mode="w+b", dir=dname, suffix=sfx, delete=False
                   ) as fp:
        fname = fp.name
        fp.write(data)
    glb.seq_files.append(fname)
    return fname


]#
proc image_width_and_height*(src: string): tuple[w, h: int] =  # {{{1
    discard
#[
    try:
        return get_image_size.get_image_size(src)  # type: ignore
    except get_image_size.UnknownImageFormat:
        pass
    if src.endswith(".svg.gz"):
        return (0, 0)
    if src.endswith(".svgz"):
        return (0, 0)
    if src.endswith(".svg"):
        return (0, 0)
    return (-1, -1)


def dot_to_mm(n: int) -> int:  # {{{1
    inch = n / 96         # dpi -> inch
    mm = Mm(inch * 25.4)  # inch -> Mm
    return mm  # type: ignore


]#
proc dot_to_page*(w, h: int): seq[tuple[k, v: string]] =  # {{{1
    discard
#[
    if w < 1 and h < 1:
        return {}
    if dot_to_mm(w) > Mm(210 - 40):
        args = {"width": Mm(210 - 40)}
        if dot_to_mm(h) > Mm(279 - 40):
            if h > w:
                args = {"height": Mm(279 - 40)}
    elif dot_to_mm(h) > Mm(279 - 40):
        args = {"height": Mm(279 - 40)}
    else:
        args = {"width": dot_to_mm(w),
                "height": dot_to_mm(h)}
    return args

]#
proc docx_add_field*(para: Paragraph, instr: string,  # {{{1
                     cache: proc(para: Paragraph): Paragraph,
                     dirty: Option[bool]): void =
  block:
    let r = para.add_run("").r
    let fld = initOxmlElement("w:fldChar")
    fld.set(qn("w:fldCharType"), "begin")
    if dirty.isSome:
        let v = if dirty.get(): "true" else: "false"
        fld.set(qn("w:dirty"), v)
    r.append(fld)

  block:
    let r = para.add_run("").r
    let cmd = initOxmlElement("w:instrText")
    cmd.text = instr
    r.append(cmd)

  block:
    let r = para.add_run("").r
    let fld = initOxmlElement("w:fldChar")
    fld.set(qn("w:fldCharType"), "separate")
    r.append(fld)

  block:
    let para = cache(para)

    let r = para.add_run("").r
    let fld = initOxmlElement("w:fldChar")
    fld.set(qn("w:fldCharType"), "end")
    r.append(fld)


proc docx_add_field*(para: Paragraph, instr: string): void =  # {{{1
    proc fn_dummy(src: Paragraph): Paragraph =
        return src
    docx_add_field(para, instr, fn_dummy, none(bool))


proc docx_add_caption*(para: Paragraph, title, caption: string): void =  # {{{1
    #[
        <w:p><w:pPr>
            <w:pStyle w:val="Normal"/><w:bidi w:val="0"/><w:jc w:val="left"/>
            <w:rPr></w:rPr></w:pPr>
          <w:r><mc:AlternateContent><mc:Choice Requires="wps">
            <w:drawing>
            <wp:anchor behindDoc="0" distT="0" distB="0" distL="0"
                       distR="0" simplePos="0" locked="0" layoutInCell="1"
                       allowOverlap="1" relativeHeight="2">
              <wp:simplePos x="0" y="0"/>
              <wp:positionH relativeFrom="column">
                <wp:align>center</wp:align></wp:positionH>
              <wp:positionV relativeFrom="paragraph">
                <wp:posOffset>635</wp:posOffset></wp:positionV>
              <wp:extent cx="5409565" cy="1374140"/>
              <wp:effectExtent l="0" t="0" r="0" b="0"/>
              <wp:wrapSquare wrapText="largest"/>
              <wp:docPr id="1" name="Frame1"/>
              <a:graphic
               xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
                <a:graphicData
       uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
                  <wps:wsp><wps:cNvSpPr txBox="1"/>
                    <wps:spPr>
                      <a:xfrm><a:off x="0" y="0"/>
                        <a:ext cx="5409565" cy="1374140"/>
                      </a:xfrm>
                      <a:prstGeom prst="rect"/>
                    </wps:spPr>
                    <wps:txbx><w:txbxContent>
                      <w:p>
                        <w:pPr><w:pStyle w:val="Figure"/>
                               <w:bidi w:val="0"/>
                               <w:spacing w:before="120" w:after="120"/>
                               <w:jc w:val="left"/>
                               <w:rPr></w:rPr>
                        </w:pPr>
                        <w:r><w:drawing>
                          <wp:inline distT="0" distB="0" distL="0" distR="0">
                          <wp:extent cx="5409565" cy="1089660"/>
                          <wp:effectExtent l="0" t="0" r="0" b="0"/>
                          <wp:docPr id="2" name="Image1" descr=""></wp:docPr>
                          <wp:cNvGraphicFramePr>
                            <a:graphicFrameLocks
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                                                           noChangeAspect="1"/>
                        </wp:cNvGraphicFramePr>
                        <a:graphic
               xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
                                <a:graphicData
                uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                                    <pic:pic
          xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                          <pic:nvPicPr>
                            <pic:cNvPr id="2" name="Image1" descr="">
                            </pic:cNvPr>
                            <pic:cNvPicPr>
                              <a:picLocks noChangeAspect="1"
                                          noChangeArrowheads="1"/>
                            </pic:cNvPicPr>
                          </pic:nvPicPr>
                          <pic:blipFill>
                            <a:blip r:embed="rId2"></a:blip>
                            <a:stretch><a:fillRect/></a:stretch>
                          </pic:blipFill>
                          <pic:spPr bwMode="auto">
                            <a:xfrm><a:off x="0" y="0"/>
                                    <a:ext cx="5409565" cy="1089660"/>
                            </a:xfrm>
                            <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
                          </pic:spPr>
                        </pic:pic></a:graphicData> </a:graphic>
                        </wp:inline></w:drawing>
                        </w:r>
            <w:r><w:rPr><w:vanish/></w:rPr><w:br/></w:r>

            <!-- core part -->
            <w:r><w:t xml:space="preserve">Figure </w:t></w:r>
            <w:r><w:fldChar w:fldCharType="begin"></w:fldChar></w:r>
            <w:r><w:instrText> SEQ Figure \* ARABIC</w:instrText></w:r>
            <w:r><w:fldChar w:fldCharType="separate"/></w:r>
            <w:r><w:t>1</w:t></w:r>
            <w:r><w:fldChar w:fldCharType="end"/></w:r>
            <w:r><w:t>.  aaa</w:t></w:r>

            </w:p>
          </w:txbxContent></wps:txbx>
          <wps:bodyPr anchor="t" lIns="0" tIns="0" rIns="0" bIns="0">
            <a:noAutofit/></wps:bodyPr>
        </wps:wsp>
        </a:graphicData></a:graphic></wp:anchor>
        </w:drawing></mc:Choice><mc:Fallback>
        <w:pict><v:rect style="position:absolute;rotation:0;width:425.95pt;
                               height:108.2pt;mso-wrap-distance-left:0pt;
                               mso-wrap-distance-right:0pt;
                               mso-wrap-distance-top:0pt;
                               mso-wrap-distance-bottom:0pt;
                               margin-top:0pt;
                               mso-position-vertical:top;
                               mso-position-vertical-relative:text;
                               margin-left:28pt;
                               mso-position-horizontal:center;
                               mso-position-horizontal-relative:text">
          <v:textbox...
    ]#
    if caption not_in glb.numbers_of_captions:
        glb.numbers_of_captions[caption] = 1
    else:
        glb.numbers_of_captions[caption] += 1
    let n = glb.numbers_of_captions[caption]

    proc cb(p: Paragraph): Paragraph =
        p.add_run($n)
        return p

    # TODO(shimoda): surround figure by frame
    para.add_run(caption & " ")  # r:vanish??
    docx_add_field(para, r"SEQ %s \* ARABIC" % caption, cb, none(bool))
    para.add_run(". " & title)


proc docx_bookmark_normalize(name: string): string =  # {{{1
    var name = name
    if len(name) > 32:
        # [@P8-1-1]
        var (pfx, sfx) = (name[0..32], name[32..^1])
        let hash = hash(name)
        sfx = ("00000000" & toHex(hash))[^8..^1]
        name = pfx & sfx
    return name


proc docx_add_bookmark*(para: Paragraph, name, instr: string  # {{{1
                        ): void =
    var id = glb.bookmark_id

    proc mark(tag, name: string): void =
        var mk = initOxmlElement("w:bookmark" & tag)
        mk.set(qn("w:id"), $id)
        if len(name) > 0:
            var name = name
            name = docx_bookmark_normalize(name)
            mk.set(qn("w:name"), name)
            verb("book: " & name)
        para.add_raw(mk)

    if len(name) > 0:
        mark("Start", name)

    para.add_run(instr)

    if len(name) > 0:
        mark("End", "")
        glb.bookmark_id += 1


proc docx_add_hlink*(para: Paragraph, instr, name: string,  # {{{1
                     ): void =
    let link = initOxmlElement("w:hyperlink")
    para.add_raw(link)
    let run = initOxmlElement("w:r")
    link.append(run)
    var text = initOxmlElement("w:t")
    text.text = instr
    run.append(text)

    var name = name
    name = docx_bookmark_normalize(name)
    link.set(qn("w:anchor"), name)
    debg("manip:para:link: " & name & ":" & instr)
    para.dump()


proc style_add_init(name: string, fn: fn_style): void =  # {{{1
    debg("sytle:add:init: " & name)
    glb.funcs_style_init[name] = fn


proc get*(cls: StylesObj, doc: Document, name: string): string =  # {{{1
        if name in cls.allocated:
            return name
        if name not_in glb.funcs_style_init:
            if name in doc.styles:
                return name
            var msg = "not " & name & " in : "
            for key in glb.funcs_style_init.keys():
                msg &= ", " & key
            raise newException(ParseError, msg)
        let fn = glb.funcs_style_init[name]
        result = fn(cls, doc, name)
        Styles.allocated.add(name)


proc init_heading(self: StylesObj, doc: Document, name: string  # {{{1
                  ): string =  # {{{1
    var st: Style
    if not doc.styles.contains(name):
        st = doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
        st.base_style = "Heading 1"
    doc.styles[name].font.color.rgb = RGBColor(r: 0, g: 0, b: 0)
    return name


proc init_quote(self: StylesObj, doc: Document, name: string): string =  # {{{1
    let style = doc.styles[name]
    block:
        style.font.name = "SourceCodePro"
        style.font.size = Pt(8)
    style.font.italic = false
    let fmt = style.paragraph_format
    block:
        fmt.line_spacing = Pt(9)
    fmt.left_indent = Mm(10)
    fmt.right_indent = fmt.left_indent
    block:
        return name


proc quote*(self: StylesObj, para: Paragraph): void =  # {{{1
    discard
    #[
        pPr = para._p.get_or_add_pPr()
        pBdr = OxmlElement('w:pBdr')
        pPr.append(pBdr)
        for val in ["left", "right", "top", "bottom"]:
            b = OxmlElement('w:' + val)
            b.set(qn('w:val'), 'thinThickLargeGap')
            b.set(qn('w:sz'), '2')
            b.set(qn('w:space'), '4')
            b.set(qn('w:color'), '000000')
            pBdr.append(b)
    ]#
#[

    @style("CodeChars")  # {{{1
    def init_codechars(self, doc: Document, name: Text) -> Text:
        fmt = doc.styles.add_style(name, WD_STYLE_TYPE.CHARACTER)
        fmt.font.name = "SourceCodePro"
        fmt.font.size = Pt(8)
        fmt.font.highlight_color = WD_COLOR_INDEX.YELLOW
        return name

    @style("katex")  # {{{1
    def init_katex(self, doc: Document, name: Text) -> Text:
        doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
        return name

    @style("Caption")  # {{{1
    def init_caption(self, doc: Document, name: Text) -> Text:
        fmt = doc.styles['Caption'].paragraph_format
        fmt.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
        return name

]#
proc init_image(self: StylesObj, doc: Document, name: string): string =  # {{{1
    ##[
        "[@P14-1-11] style for single images"
    ]##
    if name in doc.styles: return name
    let
        style = doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
    block:
        style.base_style = doc.styles["Normal"]
    style.paragraph_format.alignment = WD_PARAGRAPH_ALIGNMENT.PA_CENTER
    block:
        return name


proc init_list(self: StylesObj, doc: Document, name: string): string =  # {{{1
        # list items indent
    var (org, n) = parse_trailing_numbers(name)
    var style, style_org: Style
    block:
        if name == org:
            if name in doc.styles:
                return name
            style = doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
        elif name in doc.styles:
            style = doc.styles[name]
        else:
            style = doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
            style.base_style = org
    let fmt = style.paragraph_format
    block:
        fmt.left_indent = Mm(12 + 12 * n)
        fmt.first_line_indent = Mm(-5)
        # [@P11-1-1] reduce extra spaces after paragraph
        fmt.space_after = Mm(1)
    fmt.line_spacing = Length(1)
    block:
        fmt.line_spacing_rule = WD_LINE_SPACING.AT_LEAST

        #[
        """ failed to set
        ppr= i.element.get_or_add_pPr()
        ind = OxmlElement("w:ind")
        ppr.append(ind)
        ind.set(qn("w:left"), "%d" % Mm(25 + 20 * n))      # - <---hanging---|
        ind.set(qn("w:hanging"), "%d" % Mm(10 + 20 * n))   # ------left----->|
        """
        ]#
        return name
#[

    @style("TOC Contents")
    def init_toc_contents(self, doc: Document, name: Text) -> Text:  # {{{1
        doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
        return name

    def init_toc(self, doc: Document, name: Text) -> Text:  # {{{1
        # [@P5-1-11] line spacing of TOC
        sname, n = parse_trailing_numbers(name)
        sname = Styles.get(doc, sname)  # TOC Contents 1 -> TOC Contents

        style = doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
        fmt = style.paragraph_format
        fmt.left_indent = Mm(15 + 15 * (n - 1))
        if n == 0:
            style.base_style = doc.styles["Normal"]
            fmt.right_indent = Mm(0)
        else:
            style.base_style = doc.styles[sname]

        fmt = style.paragraph_format
        fmt.space_after = Mm(1)
        fmt.line_spacing = 1.0
        fmt.line_spacing_rule = WD_LINE_SPACING.AT_LEAST
        return name

    for i in range(1, 10):
        (style("TOC Contents %d" % i))(init_toc)

    @style("Stamps")  # {{{1
    def init_stamps(self, doc: Document, name: Text) -> Text:
        # styles for stamps
        style = doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
        style.font.size = Pt(8)
        return name

]#
proc init_cell_header(self: StylesObj, doc: Document, name: string  # {{{1
                      ): string =
    #[
        "[@P13-2-11] style for header cells"
    ]#
    let
        style = doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
    style.base_style = "Normal"
    style.paragraph_format.alignment = WD_PARAGRAPH_ALIGNMENT.PA_CENTER
    block:
        return name


proc init_cell_normal(self: StylesObj, doc: Document, name: string  # {{{1
                      ): string =
    #[
        "[@P13-2-12] style for cells"
    ]#
    let
        style = doc.styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
    style.base_style = "Normal"
    block:
        return name
#[

    @style("Subtitle")  # {{{1
    def init_subtitle(self, doc: Document, name: Text) -> Text:
        style = doc.styles[name]
        style.paragraph_format.alignment = WD_PARAGRAPH_ALIGNMENT.LEFT
        style.font.size = Pt(10.5)
        style.font.color.rgb = RGBColor(0, 0, 0)
        return name

    @style("Title")  # {{{1
    def init_title(self, doc: Document, name: Text) -> Text:
        style = doc.styles[name]
        style.paragraph_format.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
        style.font.size = Pt(20)
        style.font.color.rgb = RGBColor(0, 0, 0)
        ppr = style.element.get_or_add_pPr()   # remove border
        seq = ppr.xpath("w:pBdr")
        if len(seq) > 0:
            ppr.remove(seq[0])
        return name
]#
proc init*(offline: bool): void =  # {{{1
    for i in 1..10:
        style_add_init("Heading " & $i, init_heading)
    style_add_init("Quote", init_quote)
    style_add_init("Image", init_image)
    style_add_init("List Number", init_list)
    style_add_init("List Bullet", init_list)
    for i in 2..10:
        style_add_init("List Number " & $i, init_list)
        style_add_init("List Bullet " & $i, init_list)

    style_add_init("CellHeader", init_cell_header)
    style_add_init("CellNormal", init_cell_normal)
#[


def main(args: List[Text]) -> int:  # {{{1
    fname = args[1]
    size = image_width_and_height(fname)
    print("%s->%s" % (fname, size))
    size2 = tuple(dot_to_mm(i) for i in size)
    print("%s->%s" % (fname, size2))
    argx = dot_to_page(size2[0], size2[1])
    print("%s->%s" % (fname, argx))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

]#
# {{{1 end of file
# vi: ft=nim:fdm=marker
