# Copyright (c) 2019 hiroki
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT


import unittest
import ../lib/portscan

suite "lib/portscan test":
    test "proc scan_port":
        const timeout = 2500

        const valid_url = "google.com"
        const valid_port = 80
        const invalid_url = "dasfawoeitnyoaieawer.dafer2rfae"
        const invalid_port = 32013

        assert scan_port(valid_url, valid_port, timeout) == true
        assert scan_port(valid_url, invalid_port, timeout) == false
        assert scan_port(invalid_url, valid_port, timeout) == false
