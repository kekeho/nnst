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
    
    test "proc scan_port_range":
        const url = "google.com"
        const valid_port_http = 80
        const valid_port_https = 443
        const invalid_port = 323

        let list = scan_port_range(url, [50, 500], timeout_msec=4000)
        
        assert list[valid_port_http - 50] == true
        assert list[valid_port_https - 50] == true
        assert list[invalid_port - 50] == false

