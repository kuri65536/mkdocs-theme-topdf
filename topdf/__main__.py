#! env python3
'''
Copyright (c) 2019, shimoda as kuri65536 _dot_ hot mail _dot_ com
                    ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.
'''
from argparse import ArgumentParser
import logging
import os
import subprocess as sp
import sys
from typing import List, Text


class options(object):  # {{{1
    cmd_pagedjs = "./node_modules/.bin/pagedjs-cli"

    def __init__(self) -> None:  # {{{1
        # self.fname_html = ""
        # self.fname_pdf = ""
        self.f_setup = False
        self.f_check = False
        self.f_test = False

    @classmethod  # parser {{{1
    def parser(cls) -> ArgumentParser:
        arg = ArgumentParser()
        # arg.add_argument("-o", "--output", default="")
        # arg.add_argument("--override", action="store_true")
        arg.add_argument("--setup", action="store_true")
        arg.add_argument("--check", action="store_true")
        arg.add_argument("--test", action="store_true")
        # arg.add_argument("input_html", type=Text, nargs="?")
        return arg

    @classmethod  # help {{{1
    def help(cls) -> int:
        arg = cls.parser()
        arg.print_help()
        return 1

    @classmethod  # parse {{{1
    def parse(cls, args: List[Text]) -> 'options':
        logging.basicConfig(level=logging.DEBUG)
        ret = options()
        opts = ret.parser().parse_args(args)
        # ret.fname_pdf = opts.output
        # ret.fname_html = opts.input_html
        ret.f_setup = opts.setup
        ret.f_check = opts.check
        ret.f_test = opts.test
        """
        # if len(ret.fname_pdf) > 0:
            # TODO(shimoda): auto numbering
            # src = ret.fname_pdf
            # ret.fname_pdf = cmn.number_output(opts.override, src, sfx)
            return ret
        src = ret.fname_html
        if len(src) < 1:
            src = ret.fname_html
        if len(src) < 1:
            ret.fname_pdf = "/dev/stdout"
        else:
            # TODO(shimoda): auto numbering
            pass
            # ret.fname_pdf = cmn.number_output(opts.override, src, sfx)
        """
        return ret


def setup_pagedjs() -> int:  # {{{1
    ret = os.system("npm install pagedjs-cli")
    return ret


def check_pagedjs() -> int:  # {{{1
    cmd = options.cmd_pagedjs
    if not os.path.isfile(cmd):
        print("ng...paged.js not found: " + cmd)
        return 1
    try:
        res = sp.check_output([cmd, "--version"])
    except Exception as ex:
        print("ng...paged.js can not run: " + Text(ex))
        return 2
    res = res.decode("utf-8")
    print("ok...paged.js output: " + res)
    print("use paged.js with: " + cmd)
    return 0


def test_pagedjs() -> int:  # {{{1
    ret = check_pagedjs()
    if ret != 0:
        return 1
    html = "site/report-3stamps/index.html"
    if not os.path.isfile(html):
        py = os.path.dirname(sys.executable)
        mkdocs = os.path.join(py, "mkdocs")
        os.system(mkdocs + " build")
    if not os.path.isfile(html):
        return 2
    cmd = (options.cmd_pagedjs + " --outline-tags h1,h2,h3,h4,h5,h6" +
           " -o report-3stamps.pdf " + html)
    print("run paged.js: " + cmd)
    ret = os.system(cmd)
    if ret != 0:
        return 2
    return 0


def main(args: List[str]) -> int:  # {{{1
    opts = options.parse(args)
    if opts.f_setup:
        return setup_pagedjs()
    elif opts.f_check:
        return check_pagedjs()
    elif opts.f_test:
        return test_pagedjs()
    return options.help()


if __name__ == "__main__":  # {{{1
    ret = main(sys.argv[1:])
    sys.exit(ret)
# vi: ft=python:fdm=marker
