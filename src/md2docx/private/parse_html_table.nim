##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import algorithm
import strutils
import tables

import logging
import parse_html


iterator sorted_by_keys*[A, B](self: TableRef[A, B],  # {{{1
                               fn: proc(a, b: A): int): tuple[key: A, val: B] =
    assert isNil(self) == false
    var keys: seq[A]
    for k in self.keys():
        keys.add(k)
    for k in sorted(keys, fn):
        yield (k, self[k])


proc cmp_rc*(a, b: tuple[r, c: int]): int =
    if a.r > b.r: return 1
    if a.r < b.r: return -1
    if a.c > b.c: return 1
    if a.c < b.c: return -1
    return 0


proc element_is_whitespace(self: Tag): bool =  # {{{1
    if len(self.name) > 0:                 return false
    if len(self.inner_text().strip()) > 0: return false
    return true


proc parse_table_row(tags: seq[Tag]): seq[Tag] =  # {{{1
    result = @[]
    for cell in tags:
        if cell.name not_in ["th", "td"]:
            if element_is_whitespace(cell): continue
            warn("extract:table:tr: ignored a direct element: " & cell.name)
            continue
        result.add(cell)


proc parse_table_rows(self: var seq[seq[Tag]], rows: seq[Tag],  # {{{1
                      name: string): void =
    ##[ include tr.
    ]##
    for tag in rows:
        if tag.name != "tr":
            if element_is_whitespace(tag): continue
            warn("extract:table:rows: ignored a direct element: " & tag.name)
            continue
        var row = parse_table_row(tag.children)
        row.insert(tag, 0)
        self.add(row)


proc parse_table_return*(tree: seq[seq[Tag]]  # {{{1
                         ): seq[tuple[r, c: int, t: Tag]] =
    ##[ .. todo:: shimoda: rowspan, colspan...
    ]##
    result = @[]
    for r, row in tree:
        result.add((r, -1, row[0]))
        for c, cell in row[1..^1]:
            verb("extract:table:return: " & $r & "," & $c)
            result.add((r, c, cell))
    return result


proc parse_table_tree*(elem: Tag  # {{{1
                       ): seq[tuple[r, c: int, t: Tag]] =
    var tmp: seq[seq[Tag]]
    for tag in elem.children:
        if tag.name in ["thead", "tbody", "foot"]:
            info("structure: table: enter " & tag.name)
            tmp.parse_table_rows(tag.children, tag.name)
            continue
        if tag.name == "tr":
            warn("structgure: table: enter row in " & elem.name)
            var row = parse_table_row(tag.children)
            tmp.add(row)
            continue
        if element_is_whitespace(tag): continue
        warn("extract:table: ignored a direct element: " & tag.name)
    return parse_table_return(tmp)


#[
proc table_update_rowcolspan*(tree: seq[tuple[r, c: int, t: Tag]]  # {{{1
                              ): seq[tuple[r, c: int, t: Tag]] =
    ## [@P13-1-13] alignment cell potisions
    proc update(self: var seq[int], src: seq[int]): void =
        for i in src:
            self.add(i)

    debg("extract:table:rcspan: enter1")
    var
        rowspans: seq[seq[int]]
        ret = newTable[tuple[r, c: int], Tag]()
        (r, c) = (-1, 0)
    debg("extract:table:rcspan: enter2")
    for tup in tree:
        debg("extract:table:rcspan: enter3")
        let (row, col, elem) = tup
        if col == -1:  # elem is row
            rowspans = if len(rowspans) > 0: rowspans[1..^1] else: @[@[0]]
        (r, c) = (row, col)
        if len(rowspans) < 1:
            c = 1
        else:
            while c in rowspans[0]:
                c += 1
        var x, y: int
        (x, y) = elem.attrs_to_ints("colspan", "rowspan")
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
]#
# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
