# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
from logging import (error as eror, warning as warn, )
import os
import sys
from tempfile import NamedTemporaryFile as Temporary
from typing import (Dict, Iterable, List, Optional, Text, Tuple, )

from docx.oxml import OxmlElement  # type: ignore
from docx.oxml.ns import qn  # type: ignore
from docx.shared import Mm  # type: ignore
from docx.text.paragraph import Paragraph  # type: ignore
from bs4.element import Tag  # type: ignore
import get_image_size  # type: ignore


try:
    import requests
    f_not_online = False
except ImportError:
    f_not_online = True


if False:
    List


class glb:  # {{{1
    numbers_of_captions: Dict[Text, int] = {}


class ParseError(Exception):  # {{{1
    pass


def has_class(tag: Tag, name: Text) -> bool:  # {{{1
    if tag.name is None:
        return False
    ret: List[Text] = tag.attrs.get("class", [])
    return name in ret


def has_prev_sibling(target: Tag, *tags: Text) -> bool:  # {{{1
    for elem in target.previous_siblings:
        if elem.name is None:
            continue
        if elem.name in tags:
            return True
        break
    return False


def has_next_table(target: Tag) -> bool:  # {{{1
    for elem in target.next_siblings:
        if elem.name is None:
            continue
        if elem.name == "table":
            return True
        break
    parent = target.parent
    if parent is None:
        return False
    for elem in parent.next_siblings:
        if elem.name is None:
            continue
        if elem.name == "p":
            cls = elem.attrs.get("class", [])
            if "before-dl-table" in cls:
                return True
        break
    return False


def classes_from_prev_sibling(target: Tag) -> Iterable[Text]:  # {{{1
    for elem in target.previous_siblings:
        if elem.name is None:
            continue
        ret: List[Text] = elem.attrs.get("class", [])
        return ret + []
    return []


def is_online_mode() -> bool:  # {{{1
    import socket
    socket.setdefaulttimeout(1.0)
    try:
        socket.gethostbyname("www.python.org")
        return True
    except:
        pass
    return False


def init() -> None:  # {{{1
    global f_not_online
    if f_not_online:
        warn("img-tag: package 'requests' required, "
             "online images will be ignored...")
        return

    if is_online_mode():
        f_not_online = False
    else:
        warn("img-tag: now in off-line mode, "
             "online images will be ignored...")
        f_not_online = True


def is_target_in_http(url: Text) -> bool:  # {{{1
    if url.startswith("http://"):
        return True
    elif url.startswith("https://"):
        return True
    return False


def download_image(url_doc: Text, src: Text) -> Text:  # {{{1
    # absolute
    if src.startswith("http://"):
        fname = download_image_run(src)
    elif src.startswith("https://"):
        fname = download_image_run(src)
    elif src.startswith("file://"):
        fname = src[7:]  # just remove prefix
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
    return fname


def download_image_unified_http(url: Text, src: Text) -> Text:  # {{{1
    # TODO(shimoda): check target url and manipulate url of images.
    if url.endswith("/"):
        return url + src
    seq = url.split("/")
    seq = seq[:-1]
    seq.append(src)
    return "/".join(seq)


def image_width_and_height(src: Text) -> Tuple[int, int]:  # {{{1
    try:
        return get_image_size.get_image_size(src)  # type: ignore
    except get_image_size.UnknownImageFormat:
        pass
    return (-1, -1)


def dot_to_mm(n: int) -> int:  # {{{1
    inch = n / 72         # dpi -> inch
    mm = Mm(inch * 25.4)  # inch -> Mm
    return mm  # type: ignore


def dot_to_page(w: int, h: int) -> Dict[Text, int]:  # {{{1
    if dot_to_mm(w) > Mm(210 - 40):
        args = {"width": Mm(210 - 40)}
        if dot_to_mm(h) > Mm(279 - 40):
            if h > w:
                args = {"height": Mm(279 - 40)}
    elif dot_to_mm(h) > Mm(279 - 40):
        args = {"height": Mm(279 - 40)}
    else:
        args = {}
    return args


def docx_add_field(para: Paragraph, instr: Text, now: Optional[Text]  # {{{1
                   ) -> None:
    r = para.add_run("")._r
    fld = OxmlElement('w:fldChar')
    fld.set(qn('w:fldCharType'), "begin")
    r.append(fld)

    r = para.add_run("")._r
    cmd = OxmlElement('w:instrText')
    cmd.text = instr
    r.append(cmd)

    r = para.add_run("")._r
    fld = OxmlElement('w:fldChar')
    fld.set(qn('w:fldCharType'), "separate")
    r.append(fld)

    if now is not None:
        para.add_run(now)

    r = para.add_run("")._r
    fld = OxmlElement('w:fldChar')
    fld.set(qn('w:fldCharType'), "end")
    r.append(fld)


def docx_add_caption(para: Paragraph, title: Text, caption: Text  # {{{1
                     ) -> None:
    """
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
    """
    if caption not in glb.numbers_of_captions:
        glb.numbers_of_captions[caption] = 1
    else:
        glb.numbers_of_captions[caption] += 1
    n = glb.numbers_of_captions[caption]

    # TODO(shimoda): surround figure by frame
    para.add_run(caption + " ")  # r:vanish??
    docx_add_field(para, r"SEQ %s \* ARABIC" % caption, "%d" % n)
    para.add_run(". " + title)


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

# {{{1 end of file
# vi: ft=python:fdm=marker
