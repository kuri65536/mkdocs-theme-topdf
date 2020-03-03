# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import logging
from logging import (debug as debg, info, warning as warn, )
import sys
from typing import (Dict, Optional, Text, Tuple, Union, )

from bs4 import BeautifulSoup  # type: ignore
from bs4.element import Tag  # type: ignore

from docx import Document  # type: ignore
from docx.shared import Mm  # type: ignore


class HtmlConvertDocx(object):  # {{{1
    def __init__(self) -> None:  # {{{1
        self.output = doc = Document()
        info("structure root")
        self.para = doc.add_paragraph('')
        self.header_init()

    def header_init(self) -> None:  # {{{1
        # TODO(shimoda): set page border
        sec = self.output.sections[0]
        sec.left_margin = sec.right_margin = Mm(20)
        sec.top_margin = sec.bottom_margin = Mm(20)

    def header_set(self, src: Text) -> None:  # {{{1
        # TODO(shimoda): set to align right.
        para = self.output.sections[0].header.paragraphs[0]
        # TODO(shimoda): append ( page / num_pages )
        para.text = src + "( nn / nn )"

    def write_out(self) -> None:
        info("structure save")
        fname = 'temp.docx'
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

    def extract_element(self, elem: Tag) -> Union[None, Text, Tag]:  # {{{1
        if elem.name is None:
            return self.extract_text(elem)

        if "doc-num" in elem.attrs.get("class", []):
            self.header_set(elem.string)
            return None

        if elem.name == "dl":
            return self.extract_dldtdd(elem)
        elif elem.name == "ul":
            return self.extract_list(elem, False)
        elif elem.name == "ol":
            return self.extract_list(elem, True)
        elif elem.name == "table":
            return self.extract_table(elem)
        elif elem.name == "details":
            return self.extract_details(elem)
        elif elem.name == "svg":
            return self.extract_svg(elem)
        elif elem.name in ("h1", "h2", "h3", "h4", "h5", "h6", ):
            return self.extract_title(elem)
        elif elem.name in ("pre", "code"):
            return self.extract_codeblock(elem)
        # p, article or ...
        return elem

    def extract_text(self, elem: Tag) -> Text:
        ret = Text(elem.string)
        debg(ret.strip())
        return ret

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
                warn("structure: tbl: enter thead")
                ret = self.extract_table_tree(tag, 0)
                continue
            if tag.name == "tbody":
                warn("structure: tbl: enter tbody")
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

    def extract_table(self, elem: Tag) -> Optional[Text]:
        # TODO(shimoda): rowspan, colspan, table in table or styled-cell etc...
        dct = self.extract_table_tree(elem, 0)
        if len(dct) < 1:
            warn("table: did not have any data" + Text(elem.string))
            return None
        n_row = max([tup[0] for tup in dct.keys()]) + 1
        n_col = max([tup[1] for tup in dct.keys()]) + 1

        info("structure: tbl: %s (%d,%d)" % (elem.name, n_row, n_col))
        tbl = self.output.add_table(rows=n_row, cols=n_col)
        for (row, col), cell in sorted(dct.items(), key=lambda x: x[0]):
            src = self.extract_table_cell(cell)
            info("table-%d,%d: %s" % (row, col, src))
            tbl.rows[row].cells[col].text = src
        return None

    def extract_dldtdd(self, elem: Tag) -> Optional[Text]:
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
        n_row, i = -1, 0
        for tag in elem.children:
            if tag.name not in ("dt", "dd"):
                continue
            src = self.extract_table_cell(tag)
            if tag.name == "dt":
                n_row, i = n_row + 1, 0
                debg("dt-%d,%d: %s" % (n_row, i, src))
                tbl.rows[n_row].cells[i].text = src
                continue
            i += 1
            debg("dd-%d,%d: %s" % (n_row, i, src))
            tbl.rows[n_row].cells[i].text = src
        return None

    def extract_list(self, elem: Tag, f_number: bool) -> Optional[Text]:
        style = "List Number" if f_number else "List Bullet"
        for tag in elem.children:
            if tag.name != "li":
                continue
            ret = Text(tag.text)
            info("structure: li : " + ret.splitlines()[0])
            self.output.add_paragraph(ret, style=style)
        return None

    def extract_details(self, elem: Tag) -> Optional[Text]:
        debg("structure: details: not implemented, skipped...")
        return None

    def extract_svg(self, elem: Tag) -> Optional[Text]:
        info("structure: svg: not implemented, skipped...")
        # TODO(shimoda): impl
        # 1. write_out_svg
        # fp = open("temp.svg", "w")
        # fp.close()
        # self.output.add_picture("temp.svg")
        return None

    def extract_title(self, elem: Tag) -> Optional[Text]:
        level = int(elem.name.lstrip("h"))
        ret = Text(elem.text)
        info("structure: hed: " + ret)
        self.output.add_heading(ret, level=level)
        return None

    def extract_codeblock(self, elem: Tag) -> Optional[Text]:
        # TODO(shimoda): append styles.
        ret = Text(elem.string)
        info("structure: pre: " + ret.splitlines()[0])
        self.output.add_paragraph(ret, style="Quote")
        return None

    def extract_para(self, node: Tag, level: int) -> Optional[Text]:
        debg("enter para...: %d-%s" % (level, node.name))
        # para = self.para
        for elem in node.children:
            ret = self.extract_element(elem)
            if isinstance(ret, Text):
                pass
                # para.text += ret
            elif ret is not None:
                self.extract_para(elem, level + 1)
            # else:
            #     para = self.output.add_paragraph('')
        return None

    def extract_table_cell(self, node: Tag) -> Text:
        ret = ""
        for elem in node:
            if elem.name is None:
                ret += elem.string
            elif elem.name == "br":
                ret += "\n"
            else:
                debg("can't extract %s in a table-cell" % elem.name)
        return ret


def main() -> int:  # {{{1
    logging.basicConfig(level=logging.INFO)

    opts = sys.argv[1:]
    data = open(opts[0]).read()
    prog = HtmlConvertDocx()
    prog.on_post_page(data, {})
    prog.write_out()
    return 0


if __name__ == "__main__":  # {{{1
    main()

# vi: ft=python
