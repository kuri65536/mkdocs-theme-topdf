# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
from logging import warning as warn
from lxml import etree  # type: ignore
import os
from tempfile import NamedTemporaryFile as Temporary
from typing import (Callable, IO, Optional, Text, )

from bs4.element import Tag  # type: ignore

from docx.image import image
from docx.oxml import OxmlElement  # type: ignore

try:
    from . import common
except ImportError:
    import common  # type: ignore

default_factory: Optional[Callable[[IO], Text]] = None


"""sample1.docx {{{1
<w:body><w:p w:rsidR="004E4BE5"
w:rsidRDefault="00A63E3C"><w:bookmarkStart w:id="0"
w:name="_GoBack"/><w:r><w:rPr><w:noProof/></w:rPr>

<w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">
<wp:extent cx="952500" cy="952500"/>
<wp:effectExtent l="0" t="0" r="0" b="0"/>
<wp:docPr id="1" name="Picture 1"/>

<wp:cNvGraphicFramePr>
<a:graphicFrameLocks
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
    noChangeAspect="1"/>
</wp:cNvGraphicFramePr>

<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
<a:graphicData
    uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
<pic:pic
    xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
<pic:nvPicPr>
    <pic:cNvPr id="1" name="aaa.svg"/>
    <pic:cNvPicPr/>
</pic:nvPicPr>

<pic:blipFill>
<a:blip r:embed="rId6">
<a:extLst>
<a:ext uri="{28A0092B-C50C-407E-A947-70E740481C1C}">
<a14:useLocalDpi
    xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main"
    val="0"/>
</a:ext>
<a:ext uri="{96DAC541-7B7A-43D3-8B79-37D633B846F1}">
<asvg:svgBlip
    xmlns:asvg="http://schemas.microsoft.com/office/drawing/2016/SVG/main"
    r:embed="rId7"/>
</a:ext>
</a:extLst>
</a:blip>
<a:stretch><a:fillRect/></a:stretch>
</pic:blipFill>

<pic:spPr><a:xfrm><a:off x="0" y="0"/>
<a:ext cx="952500" cy="952500"/></a:xfrm>
<a:prstGeom
    prst="rect"><a:avLst/></a:prstGeom>
</pic:spPr>
</pic:pic>
</a:graphicData>
</a:graphic>
</wp:inline>
</w:drawing>
"""


"""sample2.docx {{{1
<w:body><w:p><w:r><w:t xml:space="preserve">abc
</w:t></w:r><w:r>

<w:drawing><wp:inline
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
    xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
<wp:extent cx="914400" cy="914400"/>
<wp:docPr id="1" name="Picture 1"/>

<wp:cNvGraphicFramePr>
<a:graphicFrameLocks noChangeAspect="1"/>
</wp:cNvGraphicFramePr>

<a:graphic>
<a:graphicData
    uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
<pic:pic>
<pic:nvPicPr>
    <pic:cNvPr id="0" name="tmpqy6h0xrj.svg"/>
    <pic:cNvPicPr/>
</pic:nvPicPr>

<pic:blipFill>
<a:blip r:embed="rId10"/>
<a:stretch><a:fillRect/></a:stretch>
</pic:blipFill>

<pic:spPr>
<a:xfrm><a:off x="0" y="0"/><a:ext cx="914400" cy="914400"/></a:xfrm>
<a:prstGeom
    prst="rect"/></pic:spPr></pic:pic></a:graphicData></a:graphic>
</wp:inline>
</w:drawing>
"""


def dump_file(elem: Tag, dname: Text) -> Text:  # {{{1
    # [@P10-1-12] export a svg to an external file.
    dname, fname = "tmp", ""
    if not os.path.exists(dname):
        os.mkdir(dname)
    with Temporary(mode="wt", dir=dname, suffix=".svg", delete=False
                   ) as fp:
        fname = fp.name
        fp.write(Text(elem).replace("\n", ""))
    common.glb.seq_files.append(fname)
    return fname


def compose_asvg(pic: Tag) -> None:  # {{{1
    # [@P10-1-13] compose OOXML for SVG.
    embed = '{%s}embed' % (
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
    url = "http://schemas.microsoft.com/office/drawing/2016/SVG/main"
    url14 = "http://schemas.microsoft.com/office/drawing/2010/main"
    etree.register_namespace("asvg", url)
    etree.register_namespace("a14", url14)

    ablip = pic._inline[-1][-1][-1][1][0]
    elst = OxmlElement('a:extLst')
    ablip.append(elst)
    embed_id = ablip.attrib.get(embed, "")
    del(ablip.attrib[embed])

    aext = OxmlElement('a:ext')
    elst.append(aext)
    aext.set("uri", "{28A0092B-C50C-407E-A947-70E740481C1C}")
    ldpi = etree.Element('{%s}useLocalDpi' % url14)
    aext.append(ldpi)
    ldpi.set("val", "0")

    aext = OxmlElement('a:ext')
    elst.append(aext)
    aext.set("uri", "{96DAC541-7B7A-43D3-8B79-37D633B846F1}")

    asvg = etree.Element('{%s}svgBlip' % url)
    aext.append(asvg)
    asvg.set(embed, embed_id)


class Svg(image.BaseImageHeader):  # {{{1
    @classmethod
    def from_stream(cls, stream):
        """Return a |Svg| instance having header properties parsed from image
             in *stream*."""
        # [@P10-1-16]
        info = _SvgParser.parse(stream)

        return cls(info.px_width, info.px_height,
                   info.horz_dpi, info.vert_dpi)

    @property
    def content_type(self):
        return "image/svg"


class _SvgParser(object):
    @classmethod
    def parse(cls, stream):
        """Return a |_SvgParser| instance containing the header properties
            parsed from the SVG image in *stream*."""
        # [@P10-1-14] parse header with lightweight method.
        ret = cls()
        ret.horz_dpi = ret.vert_dpi = 96  # from SVG 2 specification.

        w, h = None, None
        context = etree.iterparse(stream, events=("start", ), tag=("svg", ))
        for event, elem in context:
            w = cls.parse_px(elem.attrib.get("width", ""))
            h = cls.parse_px(elem.attrib.get("height", ""))
            elem.clear()
        msg = "svg: %s not specified, assumed to 100"
        if w is None and h is None:
            warn(msg % "width and height")
            ret.px_width, ret.px_height = 100, 100
        elif w is None:
            warn(msg % "width")
            ret.px_width, ret.px_height = 100, h
        elif h is None:
            warn(msg % "height")
            ret.px_width, ret.px_height = h, 100
        else:
            ret.px_width, ret.px_height = w, h
        return ret

    def parse_px(src: Text) -> Optional[int]:
        # [@P10-1-15] parse length for width and height.
        def parse_len(src: Text) -> Optional[float]:
            try:
                ret = float(src)
                return ret
            except ValueError:
                pass
            return None

        if len(src) < 1:
            return None
        if src == "auto":
            warn("svg: size is auto, ignored.")
            return None
        for sfx, cnv in (("cm", 96 / 2.54),  # these from SVG specification
                         ("mm", 96 / 25.4),
                         ("Q", 96 / 25.4 / 4),
                         ("in", 96),  # inches
                         ("pc", 96 / 6),  # picas
                         ("pt", 96 / 72),
                         ("px", 1)):
            if not src.endswith(sfx):
                continue
            ret = parse_len(src[:-len(sfx)])
            if ret is None:
                continue
            return int(0.5 + ret * cnv)
        ret = parse_len(src)
        if ret is None:
            return None
        return int(0.5 + ret)


def _ImageHeaderFactory(stream):  # {{{1
    # [@P10-1-12] judge svg headers and relay to the default factory.
    stream.seek(0)
    buf = stream.read(32)
    if "<svg".encode("latin") in buf:
        stream.seek(0)
        return Svg.from_stream(stream)
    return default_factory(stream)


def monkey():  # {{{1
    # [@P10-1-11] register svg images to the docx header factory.
    global default_factory
    if default_factory is not None:
        return
    default_factory = image._ImageHeaderFactory
    image._ImageHeaderFactory = _ImageHeaderFactory


if __name__ == "__main__":
    pass
# vi: ft=python:fdm=marker
