##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import os
import posix
import streams
import strutils
import tables

import zip/zipfiles

import docx
import docx_common
import docx_para
import docx_render/docx_render_docx
import docx_render/docx_render_table
import docx_runner
import docx_section
import private/logging


method render(self: RunnerItem, s: Stream): void {.base.} =  # {{{1
    discard


method render(self: Runner, s: Stream): void =  # {{{1
    const tag = "w:r"
    s.write("<" & tag & ">")
    s.write("")
    s.write("</" & tag & ">")


method render(self: SectionItem, s: Stream): void {.base.} =  # {{{1
    eror("render: ???")


method render(self: DocxTable, s: Stream): void =  # {{{1
    const tag = "w:tbl"
    s.write("<" & tag & ">")
    warn("save:render: " & tag)
    self.render_table(s)
    s.write("</" & tag & ">")


method render(self: Paragraph, s: Stream): void =  # {{{1
    const tag = "w:p"
    warn("save:render: para")
    s.write("<" & tag & ">")
    for item in self.items:
        item.render(s)
    s.write("</" & tag & ">")


proc save_render(self: Document): Stream =  # {{{1
    result = newStringStream()

    warn("save:render: root => " & $len(self.sections))
    save_prefix(result)
    for sec in self.sections:
        warn("save:render: section => " & $len(sec.items))
        for item in sec.items:
            item.render(result)
    save_suffix(result)
    result.setPosition(0)


proc save_from_templates(z: var ZipArchive, filename: string): bool =  # {{{1
    const fname_tmp = "tests/template.docx"

    ## a typical docx file includes these files.
    var ztmp: ZipArchive
    if not ztmp.open(fname_tmp, fmRead):
        ftal("can't open: " & fname_tmp)
        return true

    var tbl = initTable[string, tuple[f: File, n: string]]()
    for i in ["[Content_Types].xml",
              "_rels/.rels",
              "customXml/item1.xml",
              "customXml/itemProps1.xml",
              "customXml/_rels/item1.xml.rels",
              "docProps/app.xml",
              "docProps/core.xml",
              "docProps/thumbnail.jpeg",
              "word/fontTable.xml",
              "word/numbering.xml",
              "word/header1.xml",
              "word/settings.xml",
              "word/stylesWithEffects.xml",
              "word/theme/theme1.xml",
              "word/webSettings.xml", ]:
        info("save:tmpl: read => " & i)
        var tmp = ".docx_render.XXXXXX"
        var hnd = mkstemp(tmp)
        var f: File
        if not f.open(hnd, fmReadWriteExisting):
            ftal("can't open: " & $hnd & "->" & $tmp)
            return true
        tbl[i] = (f, tmp)
        ztmp.extractFile(i, newFileStream(f))
        # defer: fs.close()  # duplicated in `getStream()`
        # save_from_tmpl(z, i, fs)
    ztmp.close()

    proc clear(): void =
        for i, tup in tbl.pairs():
            tup.f.close()

    if not z.open(filename, fmWrite):
        ftal("can't open: " & filename)
        clear()
        return true
    info("save:open: " & filename)

    for i, tup in tbl.pairs():
        var (f, fname) = tup
        debg("save:tmpl: from template => " & i)
        f.setFilePos(0)
        z.addFile(i, newFileStream(tup.f))
        discard os.tryRemoveFile(fname)
    return false


proc save*(self: Document, filename: string): void =  # {{{1
    var z: ZipArchive
    if save_from_templates(z, filename):
        return

    var fs = self.save_render()
    info("save:render: dump to zip (document.xml)")
    z.addFile("word/document.xml", fs)
    info("save:render: close..." & filename)
    z.close()


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
