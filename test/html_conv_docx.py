# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import sys
from typing import (Dict, Optional, Text, )

from bs4 import BeautifulSoup  # type: ignore
from bs4.element import Tag  # type: ignore

from docx import Document  # type: ignore


class HtmlConvertDocx(object):  # {{{1
    def __init__(self) -> None:  # {{{1
        self.output = doc = Document()
        doc

    def on_post_page(self, output_content: Text, config: Dict[Text, Text],
                     **kwardgs: Text) -> Text:  # {{{1
        soup = BeautifulSoup(output_content, 'html.parser')
        dom = soup.find("body")
        self.extract_para(dom)
        return output_content

    def extract_element(self, elem: Tag) -> Optional[Text]:  # {{{1
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
        return self.extract_para(elem)

    def extract_text(self, elem: Tag) -> Text:
        return Text(elem.string)

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
                tbl.rows[n_row].cells[i].text = cell.string or ""
        return None

    def extract_dldtdd(self, elem: Tag) -> None:
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

        tbl = self.output.add_table(rows=n_row, cols=n_col)
        n_row, i = -1, 0
        for tag in elem.children:
            if tag.name not in ("dt", "dd"):
                continue
            if tag.name == "dt":
                n_row, i = n_row + 1, 0
                tbl.rows[n_row].cells[i].text = tag.string or ""
                continue
            i += 1
            tbl.rows[n_row].cells[i].text = tag.string or ""
        return None

    def extract_list(self, elem: Tag, f_number: bool) -> None:
        import pdb; pdb.set_trace()
        return None

    def extract_details(self, elem: Tag) -> None:
        import pdb; pdb.set_trace()
        return None

    def extract_svg(self, elem: Tag) -> None:
        import pdb; pdb.set_trace()
        return None

    def extract_title(self, elem: Tag) -> None:
        import pdb; pdb.set_trace()
        return None

    def extract_codeblock(self, elem: Tag) -> None:
        import pdb; pdb.set_trace()
        return None

    def extract_para(self, node: Tag) -> None:
        para = self.output.add_paragraph('')
        for elem in node.children:
            ret = self.extract_element(elem)
            if ret is not None:
                para.text += ret
            else:
                para = self.output.add_paragraph('')


def main() -> int:  # {{{1
    opts = sys.argv[1:]
    data = open(opts[0]).read()
    prog = HtmlConvertDocx()
    prog.on_post_page(data, {})
    return 0


if __name__ == "__main__":  # {{{1
    main()

# vi: ft=python
