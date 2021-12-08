# Package

version       = "2.0.0"
author        = "shimoda"
description   = "convert mardkown to docx"
license       = "MPL2"
srcDir        = "src"
bin           = @["mk2docx"]


# Dependencies for Debian10
requires "nim >= 0.19.4"
requires "zip >= 0.3.1"

