# Copyright (c) 2019 Hiroki.T
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import net
import sequtils
import sugar
import threadpool
import os

proc scan_port*(address: string, port: int, timeout_msec=2500): bool =
    let sock = newSocket()
    try:
        sock.connect(address, Port(port), timeout_msec)
        result = true
    except TimeoutError, OSError:
        # OSError => "Name or service not known"
        result = false
    finally:
        sock.close()


var result_list: array[65535+1, bool]
proc scan_port_range_threadprocess(address: string, port: int, timeout_msec: int) {.thread.} =
    let scan_result = address.scan_port(port, timeout_msec)
    result_list[port] = scan_result


proc scan_port_range*(address: string, port_range: array[2, int], timeout_msec=2500, threads_num=256): seq[bool] =
    # Set poolsize as threads_num (not floating)
    setMaxPoolSize(threads_num)
    setMinPoolSize(threads_num)

    for p in port_range[0]..port_range[1]:
        # Spawn thread
        spawn scan_port_range_threadprocess(address, p, timeout_msec=timeout_msec)
        
    sync()  # waiting all threads...

    result = result_list[port_range[0]..port_range[1]]

    # finalize (all clear result_list var)
    for p in port_range[0]..port_range[1]:
        result_list[p] = false
