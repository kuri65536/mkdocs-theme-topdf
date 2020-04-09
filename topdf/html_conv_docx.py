# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# include {{{1
import logging
from logging import (debug as debg, info, warning as warn, )
from lxml import etree  # type: ignore
import os
from tempfile import NamedTemporaryFile as Temporary
from typing import (Dict, Iterable, List, Optional, Text, Tuple, Union, )

from bs4 import BeautifulSoup  # type: ignore
from bs4.element import Tag  # type: ignore

from docx import Document  # type: ignore
from docx.blkcntnr import BlockItemContainer  # type: ignore
from docx.enum.style import WD_STYLE_TYPE  # type: ignore
from docx.enum.text import (                  # type: ignore
        WD_ALIGN_PARAGRAPH, WD_BREAK,  # type: ignore
        )             # type: ignore
from docx.enum.table import WD_TABLE_ALIGNMENT  # type: ignore
from docx.oxml import OxmlElement  # type: ignore
from docx.oxml.ns import qn  # type: ignore
from docx.text.paragraph import Paragraph  # type: ignore
from docx.shared import Mm  # type: ignore
from docx.table import _Cell, Table  # type: ignore

try:
    from . import common
    from . import options
except ImportError:
    import common  # type: ignore
    import options  # type: ignore


if False:
    List


class _info_list:
    def __init__(self, f: bool, s: Text, l: int) -> None:
        self.f_number = f
        self.style = s
        self.level = l


class HtmlConvertDocx(object):  # {{{1
    def __init__(self, src: Text) -> None:  # {{{1
        self.bookmark_id = 0
        if common.is_target_in_http(src):
            self.url_target = src
        else:
            src = os.path.realpath(src)
            self.url_target = src

        doc = Document()
        self.output = doc
        update_fields = OxmlElement("w:updateFields")
        update_fields.set(qn("w:val"), "true")
        doc.settings.element.append(update_fields)
        info("structure root")
        self.para: Optional[Paragraph] = None  # doc.add_paragraph('')
        self.header_init()

    def header_init(self) -> None:  # {{{1
        sec = self.output.sections[0]

        # page setting
        sec.page_width = Mm(210)
        sec.page_height = Mm(297)
        sec.left_margin = sec.right_margin = sec.bottom_margin = Mm(20)
        sec.top_margin = Mm(20)  # 20 - 1

        # make header to right
        sec.header_distance = Mm(13)  # 20 - 1
        para = self.output.sections[0].header.paragraphs[0]
        para.alignment = WD_ALIGN_PARAGRAPH.RIGHT

        # page border as rectangle (old word style)
        """<w:pict><v:rect id="shape_0" ID="Shape1" stroked="t"
                style="position:absolute;margin-left:-5.8pt;margin-top:13.05pt;width:493.2pt;height:751.15pt">
                <w10:wrap type="none"/>
                <v:fill o:detectmouseclick="t" on="false"/>
                <v:stroke color="black" weight="12600" joinstyle="round"
                          endcap="flat"/>
           </v:rect></w:pict>
        """
        v = "urn:schemas-microsoft-com:vml"
        w10 = "urn:schemas-microsoft-com:office:word"
        r = para._p.add_r()
        pict = OxmlElement('w:pict')
        r.append(pict)
        rect = etree.Element("{%s}rect" % v)
        pict.append(rect)
        rect.set('id', 'shape_0')  # page_border')
        rect.set('ID', 'Shape1')   # _page_border')
        rect.set('stroked', 't')
        rect.set('style', 'position:absolute;'
                 'margin-left:-5.8pt;margin-top:20.0pt;'
                 'width:493.2pt;height:751.15pt')
        wrap = etree.Element('{%s}wrap' % w10)
        wrap.set('type', "none")
        rect.append(wrap)
        fill = etree.Element('{%s}fill' % v)
        fill.set('on', "false")
        rect.append(fill)
        stroke = etree.Element('{%s}stroke' % v)
        stroke.set('color', "black")
        stroke.set('weight', "12600")
        stroke.set('joinstyle', "round")
        stroke.set('endcap', "flat")
        rect.append(stroke)

    def header_set(self, src: Text) -> None:  # {{{1
        para = self.output.sections[0].header.paragraphs[0]
        para.add_run(src + "( ")
        common.docx_add_field(para, "PAGE", None)
        para.add_run(" / ")
        common.docx_add_field(para, "NUMPAGES", None)
        para.add_run(" )")

    def write_out(self, fname: Text) -> None:
        info("structure save")
        self.output.save(fname)

        doc = Document(fname)
        for para in doc.paragraphs:
            ret = Text(para.text)
            info("after-para: " + (ret[0:10] if len(ret) > 9 else ret))
        for tbl in doc.tables:
            ret = "%d,%d" % (len(tbl.rows), len(tbl.rows[0].cells))
            info("after-tabl: " + (ret))

    def on_post_page(self, output_content: Text, config: Dict[Text, Text],
                     **kwardgs: Text) -> Text:  # {{{1
        soup = BeautifulSoup(output_content, 'html.parser')
        dom = soup.find("body")
        self.extract_para(dom, 0)
        return output_content

    def extract_is_text(self, elem: Tag) -> Union[None, Text, Tag]:  # {{{1
        if elem.name is not None:
            return elem
        elif "element.Comment" in Text(type(elem)):
            return None  # ignore html comments
        return self.extract_text(elem)

    def extract_inlines(self, elem: Tag, para: Paragraph  # {{{1
                        ) -> Optional[Text]:
        # inline elements
        if elem.name == "em":
            return self.extract_em(elem, para)
        elif elem.name == "strong":
            return self.extract_strong(elem, para)
        elif elem.name == "code":
            return self.extract_code(elem, para, pre=False)
        elif elem.name == "br":
            return self.extract_br(elem, para)
        elif elem.name == "a":
            return self.extract_anchor(elem, para)
        raise common.ParseError("%s is not implemented, yet" % elem.name)

    def extract_element(self, elem: Tag, para: Paragraph  # {{{1
                        ) -> Union[None, Text, Tag]:
        is_text = self.extract_is_text(elem)
        if (is_text is None) or isinstance(is_text, Text):
            return is_text

        classes = elem.attrs.get("class", [])
        if "doc-num" in classes:
            self.header_set(elem.string)
            return None
        if "toc" in classes:
            para = self.output.add_paragraph()
            common.docx_add_field(para, r'TOC \o "1-9" \h', None, True)
            para = self.para = self.output.add_paragraph()
            return None

        try:
            return self.extract_inlines(elem, para)
        except common.ParseError:
            pass

        # block elements
        if elem.name in ("script", "style"):
            return None  # just ignore these elements.
        elif elem.name == "hr":
            return self.extract_pagebreak(elem)
        elif elem.name == "dl":
            return self.extract_dldtdd(elem)
        elif elem.name == "ul":
            return self.extract_list(elem, False, 1, self.output)
        elif elem.name == "ol":
            return self.extract_list(elem, True, 1, self.output)
        elif elem.name == "table":
            return self.extract_table(elem)
        elif elem.name == "details":
            return self.extract_details(elem)
        elif elem.name == "img":
            return self.extract_img(elem, para)
        elif elem.name == "svg":
            return self.extract_svg(elem, para)
        elif elem.name in ("h1", "h2", "h3", "h4", "h5", "h6", ):
            return self.extract_title(elem)
        elif elem.name in ("pre", "code"):
            return self.extract_codeblock(elem)
        elif elem.name in ("p", "div"):
            pass
        else:
            pass  # for debug: import pdb; pdb.set_trace()
        # p, article or ...
        return elem

    def extract_text(self, elem: Tag) -> Optional[Text]:  # {{{1
        if elem.string == "\n":
            if elem.parent.name in ("body", "div", ):
                return None
        ret = Text(elem.string)
        debg(ret.strip())
        return ret

    def extract_br(self, elem: Tag, para: Paragraph) -> Text:  # {{{1
        # sometime bs4 fails to parse `br` tag and surround text.
        n, ret = 0, ""
        for tag in elem.children:
            n += 1
            content = self.extract_is_text(tag)
            if content is None:
                continue
            if isinstance(content, Text):
                para.add_run(content)
            else:
                content = self.extract_inlines(tag, para)
                if not isinstance(content, Text):
                    continue
            ret += content
        if n < 1:
            if para is None:
                para = self.output.add_paragraph()
            para.add_run("\n")
        return ret

    def extract_em(self, elem: Tag, para: Paragraph) -> Optional[Text]:  # {{{1
        def add_para() -> Paragraph:
            style = common.docx_style(self.output, "Caption")
            self.para = self.output.add_paragraph("", style)
            return self.para
        classes = elem.attrs.get("class", [])
        if "table-tag" in classes:
            common.docx_add_caption(add_para(), elem.text, "Table")
            return None
        if common.has_prev_sibling(elem, "img", "svg"):
            common.docx_add_caption(add_para(), elem.text, "Figure")
            return None
        if common.has_next_table(elem):
            common.docx_add_caption(add_para(), elem.text, "Table")
            return None

        # TODO(shimoda): style for the top-level emphasis
        if para is None:
            self.para = self.output.add_paragraph()
        para.add_run(elem.text, style="Emphasis")
        return None

    def extract_code(self, elem: Tag, para: Paragraph, pre: bool  # {{{1
                     ) -> Optional[Text]:
        s = Text(elem.text)
        if para is None:  # top level
            self.output.add_paragraph(s)  # TODO(shimoda): Code block
        elif pre:
            para.add_run(s)
        else:
            style = common.docx_style(self.output, "CodeChars")
            para.add_run(s, style=style)
        return None

    def extract_strong(self, elem: Tag, para: Paragraph  # {{{1
                       ) -> Optional[Text]:
        s = Text(elem.text)
        if para is None:  # top level
            self.output.add_paragraph(s)  # TODO(shimoda): strong block
        else:
            style = common.docx_style(self.output, "Strong")
            para.add_run(s, style=style)
        return None

    def extract_anchor(self, elem: Tag, para: Paragraph  # {{{1
                       ) -> Optional[Text]:
        url = elem.attrs.get("href", "")
        if len(url) < 1:
            # TODO(shimoda): check `name` attribute for link target.
            return Text(elem.text)
        if not url.startswith("#"):
            # TODO(shimoda): enable external link
            return Text(elem.text)

        link = OxmlElement("w:hyperlink")
        if para is None:
            para = self.para = self.output.add_paragraph()
        para._p.append(link)
        run = OxmlElement("w:r")
        link.append(run)
        text = OxmlElement("w:t")
        run.append(text)

        link.set(qn("w:anchor"), "ahref_" + url[1:])
        text.text = Text(elem.text)
        return None

    def extract_table_tree(self, elem: Tag, row: int  # {{{1
                           ) -> Dict[Tuple[int, int], Tag]:
        def num_row(dct: Dict[Tuple[int, int], Tag]) -> int:
            ret = -1
            for (row, col) in dct.keys():
                ret = max(ret, row)
            return ret + 1

        ret: Dict[Tuple[int, int], Tag] = {}
        f_row = False
        for tag in elem.children:
            if tag.name is None:
                continue
            if tag.name == "thead":
                info("structure: tbl: enter thead")
                ret = self.extract_table_tree(tag, 0)
                continue
            if tag.name == "tbody":
                info("structure: tbl: enter tbody")
                ret2 = self.extract_table_tree(tag, num_row(ret))
                ret.update(ret2)
                continue
            if tag.name == "tfoot":
                warn("structure: tbl: enter tfoot")
                ret2 = self.extract_table_tree(tag, num_row(ret))
                ret.update(ret2)
                continue
            if tag.name != "tr":
                warn("table tree: %s in table" % tag.name)
                continue
            f_row, col, row = True, 0, (row + 1 if f_row else row)
            for cell in tag.children:
                if cell.name is None:
                    continue
                if cell.name not in ("th", "td", ):
                    warn("table tree: %s in tr" % cell.name)
                    continue
                ret[row, col] = cell
                col += 1
        return ret

    def extract_table(self, elem: Tag) -> Optional[Text]:  # {{{1
        # TODO(shimoda): rowspan, colspan, table in table or styled-cell etc...
        dct = self.extract_table_tree(elem, 0)
        if len(dct) < 1:
            warn("table: did not have any data" + Text(elem.string))
            return None
        n_row = max([tup[0] for tup in dct.keys()]) + 1
        n_col = max([tup[1] for tup in dct.keys()]) + 1

        info("structure: tbl: %s (%d,%d)" % (elem.name, n_row, n_col))
        tbl = self.output.add_table(rows=n_row, cols=n_col)
        tbl.autofit = False
        tbl.style = common.docx_style(self.output, "Table Grid")
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        for (row, col), elem in sorted(dct.items(), key=lambda x: x[0]):
            cell = tbl.rows[row].cells[col]
            self.extract_table_cell(elem, cell)
        return None

    def extract_pagebreak(self, elem: Tag) -> Optional[Text]:  # {{{1
        if self.para is None:
            self.para = self.output.add_paragraph()
        self.para.add_run().add_break(WD_BREAK.PAGE)
        return None

    def extract_dldtdd(self, elem: Tag) -> Optional[Text]:  # {{{1
        classes = common.classes_from_prev_sibling(elem)
        if "before-dl-table" not in classes:
            warn("can not convert dl tags, "
                 "docx does not have difinition lists")
            return None

        n_row = n_col = i = 0
        for tag in elem.children:
            if tag.name not in ("dt", "dd"):
                continue
            if tag.name == "dt":
                n_row, i = n_row + 1, 1
                continue
            i += 1
            n_col = max(i, n_col)

        info("structure: tbl: %s (%d,%d)" % (elem.name, n_row, n_col))
        tbl = self.output.add_table(rows=n_row, cols=n_col)
        tbl.autofit = False
        tbl.style = common.docx_style(self.output, "Table Grid")
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        n_row, i = -1, 0
        for tag in elem.children:
            if tag.name not in ("dt", "dd"):
                continue
            elif tag.name == "dt":
                n_row, i = n_row + 1, 0
            else:
                i += 1
            self.extract_table_cell(tag, tbl.rows[n_row].cells[i])
        if self.style_table_stamps(tbl, classes):
            return None
        self.style_table_width_from(tbl, classes)
        return None

    def extract_list(self, elem: Tag, f_number: bool,  # {{{1
                     level: int, blk: BlockItemContainer) -> Optional[Text]:
        list_info = self.style_list(f_number, level)
        for tag in elem.children:
            if tag.name != "li":
                continue
            ret = self.extract_list_subs(None, tag, list_info, blk)
            info("structure: li : " + ret if len(ret) < 50 else ret[:50])
        self.para = None
        return None

    def extract_details(self, elem: Tag) -> Optional[Text]:
        debg("structure: details: not implemented, skipped...")
        return None

    def extract_img(self, elem: Tag, para: Paragraph  # {{{1
                    ) -> Optional[Text]:
        if para is None:
            para = self.para = self.output.add_paragraph()
        src = elem.attrs.get("src", "")
        if len(src) < 1:
            warn("img-tag: was not specified 'src' attribute, ignored...")
            return None
        fname = common.download_image(self.url_target, src)
        if len(fname) < 1:
            warn("img-tag: can not download, ignored...: " + src)
            return None

        # FIXME(shimoda): sizing is to more flexible.
        w, h = common.image_width_and_height(fname)
        args = common.dot_to_page(w, h)
        para.add_run().add_picture(fname, **args)
        return None

    def extract_svg(self, elem: Tag, para: Paragraph  # {{{1
                    ) -> Optional[Text]:
        if para is None:
            para = self.para = self.output.add_paragraph()
        dname, fname = "tmp", ""
        if not os.path.exists(dname):
            os.mkdir(dname)
        with Temporary(mode="wt", dir=dname, suffix=".svg", delete=False
                       ) as fp:
            fname = fp.name
            fp.write(Text(elem))
        common.glb.seq_files.append(fname)
        info("structure: svg: is not supported by python-docx, %s" % fname)
        # TODO(shimoda): import as xml.
        # para.add_run().add_picture(fname, **args)
        return None

    def extract_title(self, elem: Tag) -> Optional[Text]:  # {{{1
        level = int(elem.name.lstrip("h"))
        ret = Text(elem.text)
        info("structure: hed: " + ret)
        style = common.docx_style(self.output, "Heading " + Text(level))
        para = self.output.add_paragraph("", style=style)

        html_id = elem.attrs.get("id", "")
        if len(html_id) > 0:
            bs = OxmlElement("w:bookmarkStart")
            be = OxmlElement("w:bookmarkEnd")
            para._p.append(bs)
            para._p.append(be)
            bs.set(qn("w:id"), "%d" % self.bookmark_id)
            be.set(qn("w:id"), "%d" % self.bookmark_id)
            bs.set(qn("w:name"), "ahref_" + html_id)
            self.bookmark_id += 1

        para.add_run(ret)
        self.para = None
        return None

    def extract_codeblock(self, elem: Tag) -> Optional[Text]:  # {{{1
        ret = Text(elem.string)
        info("structure: pre: " + ret.splitlines()[0])
        style = common.docx_style(self.output, "Quote")
        para = self.output.add_paragraph(ret, style=style)
        self.para = None
        common.Styles.quote(para)
        return None

    def extract_para(self, node: Tag, level: int) -> Optional[Text]:  # {{{1
        info("enter para...: %d-%s" % (level, node.name))
        if node.name == "p" and common.has_class(node, "before-dl-table"):
            return None
        para = None
        for elem in node.children:
            ret = self.extract_element(elem, para)
            if isinstance(ret, Text):
                empty = ret.strip("\n")
                if len(empty) < 1:
                    pass
                elif para is None:
                    self.para = para = self.output.add_paragraph(ret)
                else:
                    para.add_run(ret)
            elif ret is not None:
                self.extract_para(elem, level + 1)
            else:
                if para != self.para:
                    para = self.para
        return None

    def extract_table_cell(self, elem: Tag, cell: _Cell) -> None:  # {{{1
        # FIXME(shimoda): simplify complex code...
        para: Optional[Paragraph] = cell.paragraphs[-1]
        for tag in elem.children:
            src = ""
            try:
                self.extract_inlines(tag, para)
                continue
            except common.ParseError:
                pass
            if tag.name is None:
                src = tag.string
                src = src.replace("\n", " ")
            elif tag.name in ("p", "div"):
                if para is None:
                    para = cell.add_paragraph()
                self.extract_as_run(para, tag)
            elif tag.name in ("ul", "ol"):
                self.extract_list(tag, tag.name == "ol", 1, cell)
                para = None
                continue
            else:
                debg("can't extract %s in a table-cell" % tag.name)
                continue
            if para is None:
                para = cell.add_paragraph()
            info("table: %s" % src)  # (row, col, src))
            para.add_run(src)

    def extract_list_subs(self, para: Optional[Paragraph], elem: Tag,  # {{{1
                          info: _info_list, blk: BlockItemContainer) -> Text:
        ret = ""
        for tag in elem.children:
            if tag.name in ("p", "div", "ul", "ol"):
                break
        else:
            if para is None:
                para = blk.add_paragraph("", info.style)
            return self.extract_as_run(para, elem)
        for tag in elem.children:
            if tag.name in ("ul", "ol"):
                self.extract_list(tag, tag.name == "ol", info.level + 1, blk)
                para = None
                continue
            elif tag.name in ("p", "div"):
                ret += self.extract_list_subs(para, tag, info, blk)
                continue

            try:
                self.extract_inlines(tag, para)
                continue
            except:
                pass
            if tag.name is None:
                src = tag.string
                src = src.replace("\n", " ")
                if len(src.strip()) > 0:
                    if para is None:
                        para = blk.add_paragraph("", info.style)
                    para.add_run(src)
                    ret += src
            else:
                warn("can't parse complex html...%s" % tag.name)
        return ret

    def extract_as_run(self, para: Paragraph, elem: Tag) -> Text:  # {{{1
        ret = ""
        if elem.name is None:  # NavigableString
            ret = Text(elem.string)
            para.add_run(ret)
            return ret
        for tag in elem.children:
            content = self.extract_is_text(tag)
            if isinstance(content, Text):
                ret += content
                para.add_run(content)
                continue
            if content is None:
                continue
            try:
                s = self.extract_inlines(
                        tag, para)
                if isinstance(s, Text):
                    ret += s
            except common.ParseError:
                pass
        return ret

    def style_table_stamps(self, tbl: Table,  # {{{1
                           classes: Iterable[Text]
                           ) -> bool:
        if "table-3stamps" not in classes:
            return False
        for col, wid in zip(tbl.columns,
                            [Mm(114), Mm(20), Mm(20), Mm(20)]):
            col.width = wid
        row = tbl.rows[0]
        row.height = Mm(20)
        mar = OxmlElement('w:tblCellMar')
        tbl.alignment = WD_TABLE_ALIGNMENT.LEFT
        tbl._tblPr.append(mar)
        for ename, val in (('top', '0'), ('bottom', '0'),
                           ('left', '108'), ('right', '108'), ):
            i = OxmlElement('w:' + ename)
            i.set(qn('w:w'), val)
            i.set(qn('w:type'), 'dxa')
            mar.append(i)
        i = OxmlElement('w:tblInd')
        i.set(qn('w:w'), "-6")
        i.set(qn('w:type'), 'dxa')
        mar.append(i)
        """
            <w:tbl><w:tblPr>
              <w:tblStyle w:val="TableGrid"/>
              <w:tblW w:w="9870" w:type="dxa"/>
              <w:jc w:val="left"/>
              <w:tblInd w:w="-6" w:type="dxa"/>
              <w:tblCellMar>
                <w:top w:w="0" w:type="dxa"/>
                <w:left w:w="108" w:type="dxa"/>
                <w:bottom w:w="0" w:type="dxa"/>
                <w:right w:w="108" w:type="dxa"/>
              </w:tblCellMar>
              <w:tblLook w:lastRow="0"
                  w:firstRow="1" w:lastColumn="0" w:firstColumn="1"
                  ...
        """

        n = 0
        for para in row.cells[0].paragraphs:
            n += 1
        if n == 1:
            # style up <dt>subtitle<br>title</dt>
            para = row.cells[0].paragraphs[-1]
            lines = para.text.split("\n")
            if len(lines) < 2:
                para.style = common.docx_style(self.output, "Title")
                return True
            para.text = lines[0]
            para = row.cells[0].add_paragraph("\n".join(lines[1:]))

        for n, para in enumerate(row.cells[0].paragraphs):
            if n == 0:
                para.style = common.docx_style(self.output, "Subtitle")
            else:
                para.style = common.docx_style(self.output, "Title")
        for i in range(1, 4):
            row.cells[i].paragraphs[0].style = common.docx_style(
                    self.output, "Stamps")
        return True

    def style_table_width_from(self, tbl: Table,  # {{{1
                               classes: Iterable[Text]
                               ) -> bool:
        ret = {"table2-8": [Mm(32), Mm(138)],
               "table3-7": [Mm(48), Mm(112)],
               "table4-6": [Mm(64), Mm(96)],
               "table5-5": [Mm(80), Mm(80)],
               "table2-2-6": [Mm(32), Mm(32), Mm(96)],
               "table2-3-5": [Mm(32), Mm(48), Mm(80)],
               "table2-4-4": [Mm(32), Mm(64), Mm(64)],
               "table2-5-3": [Mm(32), Mm(80), Mm(48)],
               "table2-6-2": [Mm(32), Mm(96), Mm(32)],
               "table3-3-3": [Mm(53), Mm(53), Mm(53)],
               "table2-2-2-4": [Mm(32), Mm(32), Mm(32), Mm(64)],
               }

        widths: List[Mm] = []
        for class_ in classes:
            if class_ in ret:
                widths = ret[class_]
                break
        else:
            warn("width did not specified by class")
            return False
        for col, wid in zip(tbl.columns, widths):
            col.width = wid
        return True

    def style_exists_or_add_list(self, doc: Document, lvl: int,  # {{{1
                                 tgt: Text, src: Text) -> None:
        if tgt in doc.styles:
            return
        sty = doc.styles.add_style(tgt, WD_STYLE_TYPE.PARAGRAPH)
        sty.base_style = doc.styles[src]
        sty.paragraph_format.left_indent = Mm(15 + 10 * (lvl - 1))

    def style_list(self, f_number: bool, level: int) -> _info_list:  # {{{1
        style_base = "List Number" if f_number else "List Bullet"
        if level > 1:
            style = style_base + " %d" % level
        else:
            style = style_base
        style = common.docx_style(self.output, style)
        self.style_exists_or_add_list(self.output, level, style, style_base)
        return _info_list(f_number, style, level)


def main(opts: options.Options) -> int:  # {{{1
    logging.basicConfig(level=opts.level_debug)

    common.init(opts.force_offline)
    data = open(opts.fname_in).read()
    prog = HtmlConvertDocx(opts.fname_in)
    prog.on_post_page(data, {})
    prog.write_out(opts.fname_out)
    if opts.remove_temporaries:
        common.remove_temporaries()
    return 0


if __name__ == "__main__":  # {{{1
    opts = options.parse()
    main(opts)

# vi: ft=python:fdm=marker
