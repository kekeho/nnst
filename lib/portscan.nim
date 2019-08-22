# Copyright (c) 2019 Hiroki.T
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import net
import unittest

proc scan_port*(address: string, port: int, timeout_msec: int): bool =
    let sock = newSocket()
    try:
        sock.connect(address, Port(port), timeout_msec)
    except TimeoutError, OSError:
        # OSError => "Name or service not known"
        return false
    
    return true
