# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import argparse as ap
import os
from typing import (Text, )


class Options:
    def __init__(self) -> None:  # {{{1
        self.fname_in = ""
        self.fname_out = ""

    @classmethod  # copy_from {{{1
    def copy_from(cls, nm: ap.Namespace) -> 'Options':
        ret = Options()

        ret.fname_in = nm.input[0]
        ret.fname_out = nm.output

        if ret.fname_out == "":
            fname = ""
            for i in range(999):
                if i > 0:
                    fname = ret.fname_in + "-%d.docx" % i
                else:
                    fname = ret.fname_in + ".docx"
                if not os.path.exists(fname):
                    break
            else:
                raise Exception("can not create output file")
            ret.fname_out = fname
        return ret


def make_parser() -> ap.ArgumentParser:
    ret = ap.ArgumentParser()
    ret.add_argument("-o", "--output", default="", type=Text)
    ret.add_argument("input", nargs=1, type=Text)
    return ret


def parse() -> Options:
    parser = make_parser()
    nm = parser.parse_args()
    return Options.copy_from(nm)

# vi: ft=python:fdm=marker
