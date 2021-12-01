##[
License::
  Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
]##

const
    ALL* = 60
    VERBOSE* = 50
    DEBUG* = 40
    INFO* = 30
    WARNING* = 20
    ERROR* = 10
    FATAL* = 0
var level_base = INFO


proc debg*(msg: string): void =  # {{{1
    if level_base < DEBUG: return
    echo(msg)


proc info*(msg: string): void =  # {{{1
    if level_base < INFO: return
    echo(msg)


proc warn*(msg: string): void =  # {{{1
    if level_base < WARNING: return
    echo(msg)


proc basicConfig*(level: int): void =  # {{{1
    level_base = level


# vi: ft=nim:ts=4:sw=4:tw=80:fdm=marker
