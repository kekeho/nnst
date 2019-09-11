# Package

version       = "0.1.0"
author        = "Hiroki.T"
description   = "NNST: Network Scan Tools"
license       = "MIT"
srcDir        = "src"
bin           = @["nnst"]

# Dependencies

requires "nim >= 0.20.2"
requires "docopt >= 0.6.8"
requires "websocket >= 0.4.0"
