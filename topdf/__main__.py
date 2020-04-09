#! env python3
'''
Copyright (c) 2019, shimoda as kuri65536 _dot_ hot mail _dot_ com
                    ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.
'''
import os
import subprocess as sp
import sys
from typing import Text

try:
    from . import options
    from . import html_conv_docx
except:
    import options  # type: ignore
    import html_conv_docx  # type: ignore


if True:
    cmd_pagedjs = "./node_modules/.bin/pagedjs-cli"

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


def main() -> int:  # {{{1
    opts = options.parse()
    if opts.f_setup_pagedjs:
        return setup_pagedjs()
    elif opts.f_check_pagedjs:
        return check_pagedjs()
    elif opts.f_test_pagedjs:
        return test_pagedjs()
    elif len(opts.fname_in) > 0:
        return int(html_conv_docx.main(opts))
    options.make_parser().print_help()
    return 1


if __name__ == "__main__":  # {{{1
    ret = main()
    sys.exit(ret)
# vi: ft=python:fdm=marker
