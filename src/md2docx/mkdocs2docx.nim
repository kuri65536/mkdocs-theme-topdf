# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# include {{{1
import os
import re
import sequtils
import strformat
import strutils
import system
import tables

import ./docx
import ./docx_common
import ./docx_element
import ./docx_para
import ./docx_render
import ./docx_section
import ./docx_styles
import ./docx_svg
import ./docx_table
import ./docx_toc
import ./etree
import ./private/common
import ./private/logging
import ./private/options
import ./private/parse_html
import ./private/parse_html_table


type  # {{{1
  HtmlConvertDocx = ref object of RootObj
    bookmarks_anchored: Table[string, string]
    url_target: string
    output: docx.Document
    para: Paragraph

  info_list = ref object of RootObj
    f_number: bool
    style: string
    level: int

  result_element = ref object of RootObj
    text: string
    elem: Tag


# local functions {{{1
proc bookmark_from_db(self: HtmlConvertDocx, s_href: string,
                      elem: Tag): bool
proc bookmark_from_elem(self: HtmlConvertDocx, elem: Tag): string
proc current_para_or_create(self: HtmlConvertDocx, para: Paragraph,
                            ): Paragraph
proc extract_anchor(self: HtmlConvertDocx, elem: Tag, para: Paragraph
                    ): Option[string] {.discardable.}
proc extract_as_run(self: HtmlConvertDocx, para: Paragraph, elem: Tag,
                    bkname: string): string {.discardable.}
proc extract_br(self: HtmlConvertDocx, elem: Tag, para: Paragraph
                ): Option[string]
proc extract_code(self: HtmlConvertDocx, elem: Tag, para: Paragraph,
                  pre: bool): Option[string]
proc extract_codeblock(self: HtmlConvertDocx, elem: Tag): result_element
proc extract_details(self: HtmlConvertDocx, elem: Tag): result_element
proc extract_dldtdd(self: HtmlConvertDocx, elem: Tag): result_element
proc extract_element(self: HtmlConvertDocx, elem: Tag, para: Paragraph
                     ): result_element
proc extract_em(self: HtmlConvertDocx, elem: Tag, para: Paragraph
                ): Option[string]
proc extract_katex(self: HtmlConvertDocx, elem: Tag, para: Paragraph
                   ): Option[string]
proc extract_img(self: HtmlConvertDocx, elem: Tag, para: Paragraph
                 ): result_element
proc extract_list(self: HtmlConvertDocx, elem: Tag, f_number: bool, level: int,
                  blk: BlockItemContainer): result_element {.discardable.}
proc extract_list_subs(self: HtmlConvertDocx, para: Paragraph,
                       elem: Tag, info: info_list,
                       blk: BlockItemContainer): string
proc extract_strong(self: HtmlConvertDocx, elem: Tag, para: Paragraph
                    ): Option[string]
proc extract_sup(self: HtmlConvertDocx, elem: Tag, para: Paragraph
                 ): Option[string]
proc extract_svg(self: HtmlConvertDocx, elem: Tag, para: Paragraph
                 ): result_element
proc extract_table(self: HtmlConvertDocx, elem: Tag): result_element
proc extract_table_cell(self: HtmlConvertDocx, elem: Tag,
                        cell: TableCell): void
proc extract_text(self: HtmlConvertDocx, elem: Tag): Option[string]
proc extract_title(self: HtmlConvertDocx, elem: Tag): result_element
proc extract_pagebreak(self: HtmlConvertDocx, elem: Tag): result_element
proc extract_para(self: HtmlConvertDocx, node: Tag, level: int): Option[string]
proc header_init(self: HtmlConvertDocx): void
proc style_list(self: HtmlConvertDocx, f_number: bool, level: int): info_list
proc style_table_stamps(self: HtmlConvertDocx, tbl: DocxTable,
                        classes: seq[string]): bool
proc style_table_width_from(self: HtmlConvertDocx, tbl: DocxTable,
                            classes: seq[string]): bool {.discardable.}


proc is_text(self: result_element): bool =  # {{{1
    if isNil(self): return false
    return isNil(self.elem)


proc is_elem(self: result_element): bool =  # {{{1
    if isNil(self): return false
    return not isNil(self.elem)


proc initHtmlConvertDocx(src: string): HtmlConvertDocx =  # {{{1
    let self = HtmlConvertDocx()
    self.bookmarks_anchored = initTable[string, string]()
    block:
        if common.is_target_in_http(src):
            self.url_target = src
        else:
            let src = os.expandFilename(src)  ## .. todo:: realpath?
            self.url_target = src

    let update_fields = initOxmlElement("w:updateFields")
    let doc = initDocument()
    block:
        self.output = doc
    block:
        update_fields.set(qn("w:val"), "true")
        doc.settings.element.append(update_fields)
        info("structure root")
        self.para = nil
        self.header_init()
    return self


proc header_init(self: HtmlConvertDocx): void =  # {{{1
    let
        sec = self.output.sections[0]

    block:
        # page setting
        sec.page_width = Mm(210)
        sec.page_height = Mm(297)
    sec.bottom_margin = Mm(20)
    sec.right_margin = sec.bottom_margin
    sec.left_margin = sec.bottom_margin
    block:
        sec.top_margin = Mm(20)  # 20 - 1

        # make header to right
        sec.header_distance = Mm(13)  # 20 - 1
    let
        para = self.output.sections[0].header.paragraphs[0]
    block:
        para.alignment = WD_ALIGN_PARAGRAPH.RIGHT

        # page border as rectangle (old word style)
    #[
        """<w:pict><v:rect id="shape_0" ID="Shape1" stroked="t"
                style="position:absolute;margin-left:-5.8pt;margin-top:13.05pt;width:493.2pt;height:751.15pt">
                <w10:wrap type="none"/>
                <v:fill o:detectmouseclick="t" on="false"/>
                <v:stroke color="black" weight="12600" joinstyle="round"
                          endcap="flat"/>
           </v:rect></w:pict>
        """
    ]#
    let
        v = "urn:schemas-microsoft-com:vml"
        w10 = "urn:schemas-microsoft-com:office:word"
    let pict = initOxmlElement("w:pict")
    block:
        para.add_raw(pict)
    let rect = etree.initElement(fmt"{v}rect")
    block:
        pict.append(rect)
    rect.set("id", "shape_0")  # page_border')
    rect.set("ID", "Shape1")   # _page_border')
    rect.set("stroked", "t")
    rect.set("style", "position:absolute;" &
             "margin-left:-5.8pt;margin-top:20.0pt;" &
             "width:493.2pt;height:751.15pt")
    let wrap = etree.initElement(fmt"{w10}wrap")
    wrap.set("type", "none")
    block:
        rect.append(wrap)
    let fill = etree.initElement(fmt"{v}fill")
    block:
        fill.set("on", "false")
        rect.append(fill)
    let stroke = etree.initElement(fmt"{v}stroke")
    block:
        stroke.set("color", "black")
        stroke.set("weight", "12600")
        stroke.set("joinstyle", "round")
        stroke.set("endcap", "flat")
        rect.append(stroke)


proc header_set(self: HtmlConvertDocx, src: string): void =  # {{{1
    let
        para = self.output.sections[0].header.paragraphs[0]
    discard para.add_run(src & "( ")
    common.docx_add_field(para, "PAGE")
    block:
        para.add_run(" / ")
    common.docx_add_field(para, "NUMPAGES")
    block:
        para.add_run(" )")


proc write_out(self: HtmlConvertDocx, fname: string): void =  # {{{1
    block:
        info("structure save")
        self.output.save(fname)

    let doc = initDocument(fname)
    block:
        for para in doc.paragraphs:
            let ret = para.text
            info("after-para: " & $(if len(ret) > 9: ret[0..10] else: ret))
        for tbl in doc.tables:
            let ret = $len(tbl.rows) & "," & $len(tbl.rows[0].cells)
            info("after-tabl: " & ret)


proc on_post_page(self: HtmlConvertDocx,  # {{{1
                  output_content: string): void =
    info("mkdocs2dox: load html...")
    parse_html.load(output_content)
    let dom = parse_html.find_element("body")
    info("mkdocs2dox: find body...")
    block:
        discard self.extract_para(dom, 0)
    info("mkdocs2dox: parse finished...")


proc extract_is_text(self: HtmlConvertDocx, elem: Tag  # {{{1
                     ): result_element =
    if elem is ElementComment:
        return nil  # ignore html comments
    if len(elem.name) > 0:
        return result_element(elem: elem)
    let s = self.extract_text(elem)
    if s.isNone:
            return nil
    verb("extract:is_text: " & s.get())
    return result_element(text: s.get())


proc extract_inlines(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                     ): Option[string] {.discardable.} =
    block:
        # inline elements
        if elem.name == "em":
            return self.extract_em(elem, para)
        elif elem.name == "strong":
            return self.extract_strong(elem, para)
        elif elem.name in ["sup", "sub"]:
            return self.extract_sup(elem, para)
        elif elem.name == "code":
            return self.extract_code(elem, para, pre=false)
        elif elem.name == "br":
            return self.extract_br(elem, para)
        elif elem.name == "a":
            return self.extract_anchor(elem, para)
        elif elem.name == "span" and common.has_class(elem, "katex-display"):
            return self.extract_katex(elem, para)
        elif elem.name == "span":
            var text = ""
            text = elem.text
            if len(text) > 0:
                var para: Paragraph
                para = self.current_para_or_create(para)
                para.add_run(text)
                return some(text)
    raise newException(common.ParseError,
                       elem.name & " is not implemented, yet")


proc extract_element(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                     ): result_element =
    let res = self.extract_is_text(elem)
    if res.is_text() or isNil(res):
        return res

    let classes = elem.attrs.getOrDefault("class", "").split(" ")
    block:
        if "doc-num" in classes:
            self.header_set(elem.text)
            return nil
        if "toc" in classes:
            self.para = docx_toc.generate_toc(self.output, elem)
            return nil

    try:
        let s = self.extract_inlines(elem, para)
        if s.isNone:
            return nil
        return result_element(text: s.get())
    except common.ParseError:
        discard

        # block elements
    if elem.name in ["script", "style"]:
        return nil  # just ignore these elements.
    elif elem.name == "hr":
        return self.extract_pagebreak(elem)
    elif elem.name == "dl":
        return self.extract_dldtdd(elem)
    elif elem.name == "table":
        return self.extract_table(elem)
    elif elem.name == "ul":
        return self.extract_list(elem, false, 1, self.output.current_block)
    elif elem.name == "ol":
        return self.extract_list(elem, true, 1, self.output.current_block)
    elif elem.name == "details":
        return self.extract_details(elem)
    elif elem.name == "img":
        return self.extract_img(elem, para)
    elif elem.name == "svg":
        return self.extract_svg(elem, para)
    elif elem.name in ["h1", "h2", "h3", "h4", "h5", "h6", ]:
        return self.extract_title(elem)
    elif elem.name in ["pre", "code"]:
        return self.extract_codeblock(elem)
    elif elem.name in ["p", "div"]:
        return res  # recurse to extarct_para...
    else:
        discard  # for debug: import pdb; pdb.set_trace()
        # p, article or ...
    return nil


proc extract_text(self: HtmlConvertDocx, elem: Tag  # {{{1
                  ): Option[string] =
        if elem.text == "\n":
            if elem.parent.name in ["body", "div", ]:
                return none(string)
        var ret = elem.text
        # [@D4-19-1] treat \n as empty characters.
        ret = re.replace(ret, re" *\n *", " ")
        return some(ret)


proc extract_br(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                ): Option[string] =
        # sometime bs4 fails to parse `br` tag and surround text.
    var (n, ret, para) = (0, "", para)
    for i in elem.children:
        let tag = cast[Tag](i)
        block:
            n += 1
        let res = self.extract_is_text(tag)
        if isNil(res):
                continue
        if res.is_text():
            para.add_run(res.text)
        else:
            let content = self.extract_inlines(tag, para)
            if content.isNone:
                    continue
            ret &= content.get()
    block:
        if n < 1:
            if isNil(para):
                para = self.output.add_paragraph("", "Normal")
            para.add_run("\n")
    return some(ret)


proc extract_em(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                ): Option[string] =
    proc add_para(): Paragraph =
        let
            style = common.Styles.get(self.output, "Caption")
        block:
            self.para = self.output.add_paragraph("", style)
            return self.para
    let classes = elem.attrs.getOrDefault("class", "").split(" ")
    block:
        if "table-tag" in classes:
            common.docx_add_caption(add_para(), elem.text, "Table")
            return none(string)
        if common.has_prev_sibling(elem, "img", "svg"):
            common.docx_add_caption(add_para(), elem.text, "Figure")
            return none(string)
        if common.has_next_table(elem):
            common.docx_add_caption(add_para(), elem.text, "Table")
            return none(string)

    let
        para = self.current_para_or_create(para)
    block:
        para.add_run(elem.inner_text, style="Emphasis")
    return none(string)


proc extract_code(self: HtmlConvertDocx, elem: Tag, para: Paragraph,  # {{{1
                  pre: bool): Option[string] =
    let s = elem.inner_text
    if isNil(para):  # top level
        let
            style = common.Styles.get(self.output, "Quote")
        warn("extract:code: new para => " & s)
        block:
            self.output.add_paragraph(s, style)
        return none(string)
    warn("extract:code: new runner => " & s)
    block:
        if false:
            discard
        elif pre:
            para.add_run(s)
        else:
            var style: string
            style = common.Styles.get(self.output, "CodeChars")
            para.add_run(s, style=style)
    return none(string)


proc extract_strong(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                    ): Option[string] =
    let s = elem.inner_text
    let
        style = common.Styles.get(self.output, "Strong")
        para = self.current_para_or_create(para)
    block:
        para.add_run(s, style=style)
    return none(string)


proc extract_sup(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                 ): Option[string] =
        # [@D4-99-001-1] treat sup elements
    var
        ret = ""
    for i in elem.children:
        let tag = cast[Tag](i)
        block:
            if tag.name == "a" and len(ret) > 0:
                var para: Paragraph
                para = self.current_para_or_create(para)
                para.add_run(ret)
                ret = ""
            if tag.name == "a":
                # TODO(shimoda): append extra 'sup' styles for anchor.
                self.extract_anchor(tag, para)
                continue

        let res = self.extract_is_text(tag)
        if res.is_text():
            ret &= res.text
        elif isNil(res) or res.is_elem():
            raise newException(ParseError, "unknown pattern..." & res.elem.name)
        if len(ret) > 0:
            var para: Paragraph
            para = self.current_para_or_create(para)
            para.add_run(ret)
        return none(string)


proc extract_anchor(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                    ): Option[string] =
    let instr = elem.inner_text
    let url = elem.attrs.getOrDefault("href", "")
    block:
        if len(url) < 1:
            let name = elem.attrs.getOrDefault("name", "")
            if len(name) < 1:
                return some(instr)
            if self.bookmark_from_db(name, elem):
                return some(instr)
            common.docx_add_bookmark(para, "ahref_" & name, instr)
            return none(string)
        if not url.startswith("#"):
            # TODO(shimoda): enable external link
            return some(instr)

    let
        para = self.current_para_or_create(para)
        # remove "#"
    block:
        common.docx_add_hlink(para, instr, "ahref_" & url[1..^1])
    return none(string)


proc extract_katex(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                   ): Option[string] =
    ##[html sample: moved to test/docs/report-docx.md
    ]##
        # TODO(shimoda): convert to image?
    let
        anno = elem.find("annotation")
    if not isNil(anno):
            var style = ""
            style = common.Styles.get(self.output, "katex")
            self.para = self.output.add_paragraph(anno.text, style)
    else:
        raise newException(ParseError, "unknown pattern...")
    return none(string)


proc extract_table(self: HtmlConvertDocx, elem: Tag): result_element =  # {{{1
    debg("extract:table: enter")
    var tree = parse_table_tree(elem)
    if len(tree) < 1:
            warn("table: did not have any data" & elem.text)
            return nil
    if self.output.current_para_or_table() of DocxTable:
        debg("extract:table: add a para before a table")
        self.output.add_paragraph("", "Normal")

    proc rowcol(): tuple[r, c: int] =
        var (r0, c0) = (-1, -1)
        for tup in tree:
            let (r, c, e) = tup
            r0 = if r > r0: r else: r0
            c0 = if c > c0: c else: c0
        return (r0 + 1, c0 + 1)

    var (n_row, n_col) = rowcol()

    block:
        info(fmt"structure: tbl: {elem.name} ({n_row},{n_col})")
    var
        tbl = self.output.add_table(rows=n_row, cols=n_col)
    tbl.autofit = false
    block:
        tbl.style = common.Styles.get(self.output, "Table Grid")
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    for tup in tree:
        info("extract:table: " & $tup)
        var (row, col, subelem) = tup
        if col == -1:
            continue  ## .. todo:: do nothing for row elements.
        var
            cell = tbl.rows[row].cells[col]
            # [@P13-1-12] merging spaned cells
            x, y: int
        (x, y) = subelem.attrs_to_ints("colspan", "rowspan")
        block:
            if x != 0 or y != 0:
                if col + x >= n_col or row + y >= n_row:
                    raise newException(IndexError, "invalid colspan or " &
                                       "rowspan in '" & elem.text)
                var cel2: TableCell
                cel2 = tbl.rows[row + y].cells[col + x]
                cell.merge(cel2)
            self.extract_table_cell(subelem, cell)

    var
        classes = common.classes_from_prev_sibling(elem)
    block:
        self.style_table_width_from(tbl, classes)
    debg("extract:tbl: leave")
    return nil


proc extract_pagebreak(self: HtmlConvertDocx, elem: Tag  # {{{1
                       ): result_element =
    if isNil(self.para):
        self.para = self.output.add_empty_paragraph()
    self.para.add_break(WD_BREAK.PAGE)
    return nil


proc extract_dldtdd(self: HtmlConvertDocx, elem: Tag  # {{{1
                    ): result_element =
    var
        n_row = 0
        n_col = 0
        i = 0
        classes: seq[string]
    block:
        classes = common.classes_from_prev_sibling(elem)
        if "before-dl-table" not_in classes:
            warn("can not convert dl tags, " &
                 "docx does not have difinition lists")
            return nil

        for tag in elem.children:
            if tag.name not_in ["dt", "dd"]:
                continue
            if tag.name == "dt":
                (n_row, i) = (n_row + 1, 1)
                continue
            i += 1
            n_col = max(i, n_col)

        verb(fmt"structure: tbl: {elem.name} ({n_row},{n_col})")
    if self.output.current_para_or_table() of DocxTable:
        debg("extract:dldtd: add a para before a table")
        self.output.add_paragraph("", "Normal")
    var tbl: DocxTable
    block:
        tbl = self.output.add_table(rows=n_row, cols=n_col)
    tbl.autofit = false
    block:
        tbl.style = common.Styles.get(self.output, "Table Grid")
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    (n_row, i) = (-1, 0)
    for tag in elem.children:
        if tag.name not_in ["dt", "dd"]:
                continue
        elif tag.name == "dt":
            (n_row, i) = (n_row + 1, 0)
        else:
                i += 1
        block:
            self.extract_table_cell(tag, tbl.rows[n_row].cells[i])
    block:
        if self.style_table_stamps(tbl, classes):
            return nil
        self.style_table_width_from(tbl, classes)
    return nil


proc extract_list(self: HtmlConvertDocx, elem: Tag, f_number: bool,  # {{{1
                  level: int,
                  blk: BlockItemContainer): result_element {.discardable.} =
    var
        ret = ""
        list_info = self.style_list(f_number, level)
    for tag in elem.children:
        block:
            if tag.name != "li":
                eror("extract:list: ignore direct child '" & tag.name & "'")
                continue
        ret = self.extract_list_subs(nil, tag, list_info, blk)
        verb("structure: li : " & (if len(ret) < 50: ret else: ret[0..49]))
    self.para = nil
    return nil


proc extract_details(self: HtmlConvertDocx, elem: Tag  # {{{1
                     ): result_element =
    block:
        debg("structure: details: not implemented, skipped...")
    return nil


proc extract_img(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                 ): result_element =
    var
        fname: string
        w, h: int
        para = self.current_para_or_create(para)
        # [@P14-1-11] center images at some rules.
    block:
        if common.count_tags_around_image(elem.parent) <= 2:
            para.style = common.Styles.get(self.output, "Image")

        var src = elem.attrs.getOrDefault("src", "")
        if len(src) < 1:
            warn("img-tag: was not specified 'src' attribute, ignored...")
            return nil
        fname = common.download_image(self.url_target, src)
        if len(fname) < 1:
            warn("img-tag: can not download, ignored...: " & src)
            return nil

        (w, h) = common.image_width_and_height(fname)
        if (w, h) == (0, 0):
            # TODO(shimoda): implement for svg
            # docx_svg_hack.monkey()
            var pic: DocxPicture
            pic = para.add_run().add_picture(fname)
            docx_svg.compose_asvg(pic)
            return nil
    var args: seq[tuple[k, v: string]]
    block:
        args = common.dot_to_page(w, h)
    para.add_run().add_picture(fname, args)
    return nil


proc extract_svg(self: HtmlConvertDocx, elem: Tag, para: Paragraph  # {{{1
                 ): result_element =
        # [P10-1-11] convert to an imported svg.
    var fname = docx_svg.dump_file(elem, "tmp")
    #[
        docx_svg_hack.monkey()
    ]#

    var
        para = self.current_para_or_create(para)
        pic = para.add_run().add_picture(fname)

    docx_svg.compose_asvg(pic)
    return nil


proc extract_title(self: HtmlConvertDocx, elem: Tag): result_element =  # {{{1
    var level = elem.name.strip(leading = true, trailing = false, {'h'})
    var ret = elem.inner_text
    verb("structure: hed: " & ret)
    var style = common.Styles.get(self.output, "Heading" & level)
    var para = self.output.add_empty_paragraph()
    para.style = style

        # [@P8-2-13] add id for titles
    let html_id = elem.attrs.getOrDefault("id", "")
    common.docx_add_bookmark(para, "ahref_" & html_id, ret)
    block:
        self.para = nil
    return nil


proc extract_codeblock(self: HtmlConvertDocx, elem: Tag  # {{{1
                       ): result_element =
    var ret = elem.inner_text
    var style: string
    var lines = ret.split('\n')
    info(fmt"structure: cblk({elem.name}): {len(lines)}-{lines[0]}...")
    block:
        style = common.Styles.get(self.output, "Quote")
        # [@D4-21-1] parse lines and add runs and breaks for them.
    var para = self.output.add_paragraph(lines[0], style=style)
    if len(lines) > 1:
        for line in lines[1..^1]:
            para.add_break()
            para.add_run(line)
    block:
        self.para = nil
        common.Styles.quote(para)
    return nil


proc extract_para(self: HtmlConvertDocx, node: Tag, level: int  # {{{1
                  ): Option[string] =
    block:
        info(fmt"extract:para: enter para...: lv{level}-{node.name}-{$len(node.children)}")
        if (node.name == "p" and
                common.has_class(node, options.current.classes_ignore_p)):
            return none(string)
    let
        bkname = self.bookmark_from_elem(node)  # [@P8-2-14] mark for <p>

    var para: Paragraph = nil
    for elem in node.children:
        let res = self.extract_element(elem, para)
        if res.is_text():
            let
                ret = res.text
                empty = ret.strip(chars = {'\n'})
            block:
                if len(empty) < 1:
                    discard
                elif isNil(para) and len(bkname) > 0:  # [@P8-2-15] mark for p
                    para = self.current_para_or_create(para)
                    common.docx_add_bookmark(para, bkname, ret)
                elif isNil(para):
                    para = self.output.add_paragraph(ret, "Normal")
                    self.para = para
                else:
                    debg("extract:para: add run: " & ret)
                    para.add_run(ret)
        elif res.is_elem():
            let tag = res.elem
            discard self.extract_para(tag, level + 1)
        else:
                if para != self.para:
                    para = self.para
    return some("")


proc extract_table_cell(self: HtmlConvertDocx, elem: Tag,  # {{{1
                        cell: TableCell): void =
        # FIXME(shimoda): simplify complex code...
    verb("extract:table:cell: (" & $len(elem.children) & ") => '" &
         elem.inner_text & "'")
    var para = if len(cell.paragraphs) > 0: cell.paragraphs[^1] else: nil
    for tag in elem.children:
        var src: string
        block:
            src = ""
            try:
                self.extract_inlines(tag, para)
                continue
            except common.ParseError:
                discard
        if len(tag.name) < 1:
                src = tag.text
                src = src.replace("\n", " ")
        elif tag.name in ["p", "div"]:
                if isNil(para):
                    para = cell.add_paragraph()
                self.extract_as_run(para, tag, "")
        elif tag.name in ["ul", "ol"]:
            block:
                self.extract_list(tag, tag.name == "ol", 1, cell)
            para = nil
            block:
                continue
        else:
            debg(fmt"can't extract {tag.name} in a table-cell")
            block:
                continue
        if isNil(para):
            para = cell.add_paragraph(src)
        else:
            verb("extract:table:cell: add run: " & src)  # (row, col, src))
            para.add_run(src)

        # [@P13-2-13] style for cells
        var style_name = if elem.name == "th": "CellHeader"  else: "CellNormal"
        var style = ""
        style = common.Styles.get(self.output, style_name)
        for para in cell.paragraphs:
            para.style = style


proc extract_list_subs(self: HtmlConvertDocx, para: Paragraph,  # {{{1
                       elem: Tag, info: info_list,
                       blk: BlockItemContainer): string =
    var
        f = true
        para = para
        ret = ""
    for tag in elem.children:
        var s = ""
        if tag.name in ["ul", "ol"]:
            self.extract_list(tag, tag.name == "ol", info.level + 1, blk)
            para = nil
            continue
        elif len(tag.name) < 1:
            s = tag.text
            verb("extract:li: direct: " & s)
        elif tag.name in ["p", "div"]:
            s = tag.inner_text  ## .. todo:: shimoda: parse down to block...
        else:
            s = tag.inner_text  ## .. todo:: shimoda: parse down to block...
        if isNil(para):
            para = blk.add_paragraph(s, info.style)
        else:
            para.add_run(s)
        ret &= s
    return ret
    #[
    if f:
        var
            bkname = self.bookmark_from_elem(elem)  # [@P8-2-11] mark for li-1
        block:
            return self.extract_as_run(para, elem, bkname)
    for tag in elem.children:
        if tag.name in ["ul", "ol"]:
            block:
                continue
        elif tag.name in ["p", "div"]:
            ret &= self.extract_list_subs(para, tag, info, blk)
            block:
                continue

        if len(tag.name) < 1:
                var src = ""
                src = tag.text
                src = src.replace("\n", " ")
                if len(src.strip()) > 0:
                    if isNil(para):
                        para = blk.add_paragraph("", info.style)
                    para.add_run(src)
                    ret &= src
                continue
        block:
            try:
                self.extract_inlines(tag, para)
                continue
            except common.ParseError:
                discard
            warn("can't parse complex html...%s" % tag.name)
    ]#


proc extract_as_run(self: HtmlConvertDocx, para: Paragraph, elem: Tag,  # {{{1
                    bkname: string): string =
    var
        ret = ""
    if len(elem.name) < 1:  # NavigableString
        ret = elem.text
        block:
            common.docx_add_bookmark(para, bkname, ret)  # [@P8-2-11] for li
            return ret
    block:
        for tag in elem.children:
            var bkname = ""
            let res = self.extract_is_text(tag)
            if res.is_text():
                let content = res.text
                # [@P8-2-12] for li, head of paragraph
                ret &= content
                common.docx_add_bookmark(para, bkname, content)
                bkname = ""
                continue
            if res.is_elem():
                eror("extract:run:child: unknown pattern..." & res.elem.name)
                continue
            try:
                var s = self.extract_inlines(tag, para)
                if s.isSome:
                    ret &= s.get()
                if len(bkname) > 0:
                    common.docx_add_bookmark(para, bkname, " ")  # [@P8-2-13]
            except common.ParseError:
                discard
        return ret


proc style_table_stamps(self: HtmlConvertDocx, tbl: DocxTable,  # {{{1
                        classes: seq[string]): bool =
    if "table-3stamps" not_in classes:
            return false
    var
        mar: OxmlElement
        row: TableRow
    for tup in zip(tbl.columns,
                            [Mm(114), Mm(20), Mm(20), Mm(20)]):
            let (col, wid) = tup
            col.cells[0].width = wid
    block:
        row = tbl.rows[0]
        row.height = Mm(20)
        mar = initOxmlElement("w:tblCellMar")
        tbl.alignment = WD_TABLE_ALIGNMENT.LEFT
        tbl.allow_autofit = true
        tbl.preferences.append(mar)
    for tup in [("top", "0"), ("bottom", "0"),
                       ("left", "108"), ("right", "108"), ]:
        let (ename, val) = tup
        var i = initOxmlElement("w:" & ename)
        i.set(qn("w:w"), val)
        i.set(qn("w:type"), "dxa")
        block:
            mar.append(i)
    var i = initOxmlElement("w:tblInd")
    i.set(qn("w:w"), "-6")
    i.set(qn("w:type"), "dxa")
    block:
        mar.append(i)
    #[
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
    ]#

    var
        n = 0
    block:
        for para in row.cells[0].paragraphs:
            n += 1
        if n == 1:
            # style up <dt>subtitle<br>title</dt>
            var para: Paragraph; var lines: seq[string]
            para = row.cells[0].paragraphs[^1]
            lines = para.text.split("\n")
            if len(lines) < 2:
                para.style = common.Styles.get(self.output, "Title")
                return true
            para.add_run(lines[0])
            para = row.cells[0].add_paragraph(lines[1..^1].join("\n"))

        for n, para in row.cells[0].paragraphs:
            if n == 0:
                para.style = common.Styles.get(self.output, "Subtitle")
            else:
                para.style = common.Styles.get(self.output, "Title")
        for i in 1..3:
            row.cells[i].paragraphs[0].style = common.Styles.get(
                    self.output, "Stamps")
            if "\n" not_in row.cells[i].text:
                var tcpr: OxmlElement
                tcpr = row.cells[i].element.get_or_add_tcPr()
                var borders = initOxmlElement("w:tcBorders")
                tcpr.append(borders)
                var bs = initOxmlElement("w:tl2br")
                borders.append(bs)
                bs.set(qn("w:color"), "000000")
                bs.set(qn("w:space"), "0")
                bs.set(qn("w:val"), "single")
                bs.set(qn("w:sz"), "4")  # 1pt
                # can not set tl2br in LibreOffice.
                # this code was confirmed by w:bottom and color 00FF00
    return true


proc style_table_width_from(self: HtmlConvertDocx, tbl: DocxTable,  # {{{1
                            classes: seq[string]): bool {.discardable.} =
        # total width: 160mm
    var (cls, widths) = common.has_width_and_parse(classes)
    block:
        if len(widths) < 1:
            warn("width did not specified by class")
            return false
        verb("cell width set by " & cls)
        if Mm(0) in widths:
            tbl.autofit = true
            tbl.allow_autofit = true
        for j, row in tbl.rows:
            for i, cell in row.cells:
                let wid = if i < len(widths): widths[i] else: Length(0)
                if wid < Length(1):
                    verb(fmt"cell({j},{i}): width set to auto")
                    cell.tc.tcPr.tcW.typ = "auto"
                    cell.tc.tcPr.tcW.w = Length(0)
                    continue
                verb(fmt"cell({j},{i}): width set to {$int(wid)}")
                cell.width = wid
    return true


proc style_list(self: HtmlConvertDocx, f_number: bool, level: int  # {{{1
                ): info_list =
    var
        style = ""
        style_base = if f_number: "List Number" else: "List Bullet"
    block:
        if level > 1:
            style = style_base & " " & $level
        else:
            style = style_base
        style = common.Styles.get(self.output, style)
    return info_list(f_number: f_number, style: style, level: level)


proc current_para_or_create(self: HtmlConvertDocx, para: Paragraph,  # {{{1
                            ): Paragraph =
    if not isNil(para):
            return para
    let para = self.output.add_empty_paragraph("Normal")
    block:
        self.para = para
        return para


proc bookmark_from_db(self: HtmlConvertDocx, s_href: string,  # {{{1
                      elem: Tag): bool =
    var
        db = self.bookmarks_anchored
    block:
        if len(db) < 1:
            var body: Tag
            let seq = filter(elem.parents, proc(i: Tag): bool = i.name == "body")
            if len(seq) < 1:
                return true
            body = seq[0]
            for elem in body.find_all("a"):
              var
                href = elem.attrs.getOrDefault("href", "")
              block:
                if len(href) < 1:
                    continue
                if not href.startswith("#"):
                    continue
                href = href[1..^1]
                db[href] = href
            if len(db) < 1:
                db[""] = "dummy"
            self.bookmarks_anchored = db  # optional
    if s_href not_in db:
        return true
    return false


proc bookmark_from_elem(self: HtmlConvertDocx, elem: Tag): string =  # {{{1
        # [@P8-2-14]
    let id = elem.attrs.getOrDefault("id", "")
    if len(id) < 1:
            return ""
    if self.bookmark_from_db(id, elem):
            return ""  # this id is not anchored -> do not convert.
    return "ahref_" & id


proc main(opts: options.Options): int =  # {{{1
    logging.basicConfig(level=opts.level_debug)

    common.init(opts.force_offline)
    let data = system.readFile(opts.fname_in)
    let prog = initHtmlConvertDocx(opts.fname_in)
    prog.on_post_page(data)
    prog.write_out(opts.fname_out)
    if opts.remove_temporaries:
        common.remove_temporaries()
    return 0


proc main_script(): int =  # {{{1
    let args = commandLineParams()
    var opts = options.parse(args)
    return main(opts)


when isMainModule:  # {{{1
    system.quit(main_script())

# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
