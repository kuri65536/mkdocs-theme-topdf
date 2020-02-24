# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import logging
from logging import (debug as debg, info, )  # warning as warn, )
import sys
from typing import (Dict, Optional, Text, Union, )

from bs4 import BeautifulSoup  # type: ignore
from bs4.element import Tag  # type: ignore

from docx import Document  # type: ignore


class HtmlConvertDocx(object):  # {{{1
    def __init__(self) -> None:  # {{{1
        self.output = doc = Document()
        info("structure root")
        self.para = doc.add_paragraph('')

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
        elif elem.name == "dl":
            return self.extract_dldtdd(elem)
        elif elem.name == "ul":
            return self.extract_list(elem, False)
        elif elem.name == "ol":
            return self.extract_list(elem, True)
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

    def extract_table(self, elem: Tag) -> None:
        # TODO(shimoda): complex table...
        n_row = n_col = 0
        for tag in elem.children:
            if tag.name != "tr":
                continue
            n_row += 1
            i = 0
            for cell in tag.children:
                if tag.name not in ("th", "td", ):
                    continue
                i += 1
                n_col = max(i, n_col)
        debg("table-%d,%d" % (n_row, n_col))

        info("structure table: %s" % elem.name)
        tbl = self.output.add_table(rows=n_row, cols=n_col)
        n_row = -1
        for tag in elem.children:
            if tag.name != "tr":
                continue
            n_row += 1
            i = -1
            for cell in tag.children:
                if tag.name not in ("th", "td", ):
                    continue
                debg("table-%d,%d: %s" % (n_row, i, cell.string))
                tbl.rows[n_row].cells[i].text = cell.string or ""
        return None

    def extract_dldtdd(self, elem: Tag) -> Optional[Text]:
        # TODO(shimoda): complex table...
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
            if tag.name == "dt":
                n_row, i = n_row + 1, 0
                debg("dt-%d,%d: %s" % (n_row, i, Text(tag.string)))
                tbl.rows[n_row].cells[i].text = Text(tag.string)
                continue
            i += 1
            debg("dd-%d,%d: %s" % (n_row, i, tag.string))
            tbl.rows[n_row].cells[i].text = Text(tag.string)
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
        para = self.para
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
