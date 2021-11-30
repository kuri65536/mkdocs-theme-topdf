##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import streams
import strutils

import zip/zipfiles

import docx


method render(self: RunnerItem, s: Stream): void {.base.} =  # {{{1
    discard


method render(self: Runner, s: Stream): void =  # {{{1
    const tag = "w:r"
    s.write("<" & tag & ">")
    s.write("")
    s.write("</" & tag & ">")


method render(self: SectionItem, s: Stream): void {.base.} =  # {{{1
    const tag = "w:tbl"
    s.write("<" & tag & ">")
    #[
    for item in self.rows:
        item.render(s)
    ]#
    s.write("</" & tag & ">")


method render(self: DocxTable, s: Stream): void =  # {{{1
    s.write("")


method render(self: Paragraph, s: Stream): void =  # {{{1
    const tag = "w:p"
    s.write("<" & tag & ">")
    for item in self.items:
        item.render(s)
    s.write("</" & tag & ">")


proc save_render(self: Document): Stream =  # {{{1
    result = newStringStream()

    for sec in self.sections:
        for item in sec.items:
            item.render(result)


proc save_from_tmpl(z: var ZipArchive, fname: string): void =  # {{{1
    var ztmp: ZipArchive
    discard ztmp.open("tests/template.docx", fmRead)
    defer: ztmp.close()

    echo("save:tmpl: from template => " & fname)
    var fs = ztmp.getStream(fname)
    # defer: fs.close()  # duplicated in `getStream()`
    z.addFile(fname, fs)


proc save*(self: Document, filename: string): void =  # {{{1
    var z: ZipArchive
    if not z.open(filename, fmWrite):
        echo("can't open: " & filename)
        return
    echo("save:open: " & filename)

    ## a typical docx file includes these files.
    save_from_tmpl(z, "[Content_Types].xml")
    save_from_tmpl(z, "_rels/.rels")
    save_from_tmpl(z, "customXml/item1.xml")
    save_from_tmpl(z, "customXml/itemProps1.xml")
    save_from_tmpl(z, "customXml/_rels/item1.xml.rels")
    save_from_tmpl(z, "docProps/app.xml")
    save_from_tmpl(z, "docProps/core.xml")
    save_from_tmpl(z, "docProps/thumbnail.jpeg")
    save_from_tmpl(z, "word/fontTable.xml")
    save_from_tmpl(z, "word/numbering.xml")
    save_from_tmpl(z, "word/header1.xml")
    save_from_tmpl(z, "word/settings.xml")
    save_from_tmpl(z, "word/stylesWithEffects.xml")
    save_from_tmpl(z, "word/theme/theme1.xml")
    save_from_tmpl(z, "word/webSettings.xml")

    var fs = self.save_render()
    echo("save:render: dump to zip (document.xml)")
    z.addFile("word/document.xml", fs)
    echo("save:render: close..." & filename)
    z.close()


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
