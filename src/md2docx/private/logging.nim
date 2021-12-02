##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##
import times

const
    ALL* = 60
    VERBOSE* = 50
    DEBUG* = 40
    INFO* = 30
    WARNING* = 20
    ERROR* = 10
    FATAL* = 0
    NOLOG* = -1
var level_base = INFO


proc putlog(msg: string): void =  # {{{1
    let dt = times.now()
    let pfx = dt.format("yy-MM-dd HH-mm-ss") & "." & dt.format("fff") & " "
    echo(pfx & msg)


proc verb*(msg: string): void =  # {{{1
    if level_base < VERBOSE: return
    putlog(":verbo: " & msg)


proc debg*(msg: string): void =  # {{{1
    if level_base < DEBUG: return
    putlog(":debug: " & msg)


proc info*(msg: string): void =  # {{{1
    if level_base < INFO: return
    putlog(":info : " & msg)


proc warn*(msg: string): void =  # {{{1
    if level_base < WARNING: return
    putlog(":warn : " & msg)


proc eror*(msg: string): void =  # {{{1
    if level_base < ERROR: return
    putlog(":error: " & msg)


proc ftal*(msg: string): void =  # {{{1
    if level_base < FATAL: return
    putlog(":fatal: " & msg)


proc basicConfig*(level: int): void =  # {{{1
    level_base = level


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
