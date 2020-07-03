# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
import argparse as ap
import logging
import os
from typing import (Text, )


class Options:
    def __init__(self) -> None:  # {{{1
        self.fname_in = ""
        self.fname_out = ""

        self.level_debug = logging.INFO

        self.remove_temporaries = True
        self.force_offline = False

        self.f_setup_pagedjs = False
        self.f_check_pagedjs = False
        self.f_test_pagedjs = False

        self.classes_ignore_p = [
                "before-dl-table", "none"]

        self.backends_bs4 = ('lxml', 'html.parser')
        self.backend_bs4 = self.backends_bs4[0]

    @classmethod  # copy_from {{{1
    def copy_from(cls, nm: ap.Namespace) -> 'Options':
        ret = Options()

        ret.level_debug = nm.verbose
        ret.remove_temporaries = not nm.keep_temporaries
        ret.force_offline = nm.offline

        ret.f_setup_pagedjs = nm.setup_paged_js
        ret.f_check_pagedjs = nm.check_paged_js
        ret.f_test_pagedjs = nm.test_paged_js
        if nm.input is not None and len(nm.input) > 0:
            ret.fname_in = nm.input

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
    # ret.add_argument("--override", action="store_true")
    ret.add_argument("--keep-temporaries", default=False, action="store_true")
    ret.add_argument("--offline", default=None, action="store_true")
    ret.add_argument("input", nargs="?", type=Text)

    ret.add_argument("--verbose", default=30, type=int, choices=range(1, 51),
                     metavar="[1-50]", help="specify verbose message level, "
                     "DEBUG(10),INFO(20),WARNING(30),ERROR(40),FATAL(50)")
    ret.add_argument("--setup-paged-js", action="store_true")
    ret.add_argument("--check-paged-js", action="store_true")
    ret.add_argument("--test-paged-js", action="store_true")
    return ret


def parse() -> Options:
    global current

    parser = make_parser()
    nm = parser.parse_args()
    current = Options.copy_from(nm)
    return current


current = Options()

# vi: ft=python:fdm=marker
