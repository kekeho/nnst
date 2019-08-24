# Copyright (c) 2019 Hiroki.T
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import net
import sequtils
import sugar
import threadpool
import os


proc set_poolsize(size: int): void =
    # Set poolsize as threads_num (not floating)
    setMaxPoolSize(size)
    setMinPoolSize(size)


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
proc scan_port_threadprocess(address: string, port: int, timeout_msec: int) {.thread.} =
    let scan_result = address.scan_port(port, timeout_msec)
    result_list[port] = scan_result


proc init_result(port_list: openArray[int]): void =
    for p in port_list:
        result_list[p] = false


proc scan_port*(address: string, port_list: openArray[int], timeout_msec=2500, threads_num=256): seq[bool] =
    set_poolsize(threads_num)

    for p in port_list:
        # Spawn thread
        spawn scan_port_threadprocess(address, p, timeout_msec=timeout_msec)
    
    sync()

    result = port_list.map(p => result_list[p])
    
    # finalize (all clear result_list var)
    init_result(port_list)
