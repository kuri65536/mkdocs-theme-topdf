# Copyright (c) 2020, Shimoda <kuri65536 at hotmail dot com>
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
from logging import (error as eror, warning as warn, )
import os
from tempfile import NamedTemporaryFile as Temporary
from typing import (Text, )


try:
    import requests
    f_not_online = False
except ImportError:
    f_not_online = True


class ParseError(Exception):  # {{{1
    pass


def is_online_mode() -> bool:  # {{{1
    import socket
    socket.setdefaulttimeout(1.0)
    try:
        socket.gethostbyname("www.python.org")
        return True
    except:
        pass
    return False


def init() -> None:  # {{{1
    global f_not_online
    if f_not_online:
        warn("img-tag: package 'requests' required, "
             "online images will be ignored...")
        return

    if is_online_mode():
        f_not_online = False
    else:
        warn("img-tag: now in off-line mode, "
             "online images will be ignored...")
        f_not_online = True


def is_target_in_http(url: Text) -> bool:  # {{{1
    if url.startswith("http://"):
        return True
    elif url.startswith("https://"):
        return True
    return False


def download_image(url_doc: Text, src: Text) -> Text:  # {{{1
    # absolute
    if src.startswith("http://"):
        fname = download_image_run(src)
    elif src.startswith("https://"):
        fname = download_image_run(src)
    elif src.startswith("file://"):
        fname = src[7:]  # just remove prefix
    elif "://" in src:
        eror("img-tag: url was not recognized, ignored...: " + src)
        return ""
    else:  # relative
        if is_target_in_http(url_doc):
            src = download_image_unified_http(url_doc, src)
            fname = download_image_run(src)
        else:
            dname = os.path.dirname(url_doc)
            fname = os.path.join(dname, src)
            fname = os.path.realpath(fname)

    if os.path.exists(fname):
        return fname
    warn("img-tag: file is not found: " + fname)
    return ""


def download_image_run(url: Text) -> Text:  # {{{1
    if f_not_online:
        eror("img-tag: now offline, ignored: " + url)
        return ""

    sfx = url.split("?")[0]   # remove the request string.
    sfx = sfx.split(".")[-1]  # remove prefix.
    if sfx.lower() not in ("jpg", "png", "svg", "tiff", "tif", "gif"):
        eror("img-tag: unsupported format: " + sfx)
        return ""

    resp = requests.get(url)
    if (resp.status_code / 100) != 2:
        return ""  # failed to download

    dname, fname = "tmp", ""
    if not os.path.exists(dname):
        os.mkdir(dname)
    with Temporary(mode="w+b", dir=dname, suffix=sfx, delete=False
                   ) as fp:
        fname = fp.name
        fp.write(resp.content)
    return fname


def download_image_unified_http(url: Text, src: Text) -> Text:  # {{{1
    # TODO(shimoda): check target url and manipulate url of images.
    if url.endswith("/"):
        return url + src
    seq = url.split("/")
    seq = seq[:-1]
    seq.append(src)
    return "/".join(seq)


# {{{1 end of file
# vi: ft=python:fdm=marker
