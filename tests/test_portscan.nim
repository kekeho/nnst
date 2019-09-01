# Copyright (c) 2019 hiroki
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT


import unittest
include ../lib/portscan
import net
import os
import sequtils

suite "lib/portscan test":
    teardown:
        # clean check
        assert result_list.filter(x => x) == @[]

    test "proc scan_port":
        const timeout = 2500

        const valid_url = "test_server_portscan"
        const valid_port = 80
        const invalid_url = "dasfawoeitnyoaieawer.dafer2rfae"
        const invalid_port = 32013

        assert scan_port(valid_url, valid_port, timeout) == true
        assert scan_port(valid_url, invalid_port, timeout) == false
        assert scan_port(invalid_url, valid_port, timeout) == false
    
    test "proc scan_port (list)":
        const timeout = 2500

        const valid_url = "test_server_portscan"
        const valid_port_list = [80, 443]
        const invalid_port_list = [1, 2]
        const half_valid_port_list = [80, 9]  # [valid, invalid]

        assert scan_port(valid_url, valid_port_list, timeout) == [true, true]
        assert scan_port(valid_url, invalid_port_list, timeout) == [false, false]
        assert scan_port(valid_url, half_valid_port_list, timeout) == [true, false]
    
    test "proc scan_port (range)":
        const url = "test_server_portscan"
        const valid_port_http = 80
        const valid_port_https = 443
        const invalid_port = 323

        let list = scan_port(url, (50..500).toSeq, timeout_msec=4000)
        
        assert list[valid_port_http - 50] == true
        assert list[valid_port_https - 50] == true
        assert list[invalid_port - 50] == false
    
    # Shutdown test_server
    let sock = newSocket()
    sock.connect("test_server_portscan", Port(9999))