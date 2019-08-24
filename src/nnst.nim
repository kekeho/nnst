# Copyright (c) 2019 Hiroki.T
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import ../lib/portscan
import docopt
import sequtils
import strutils
import sugar

const VERSION = "0.1.0"
const doc = """　
   _  ___  ____________
  / |/ / |/ / __/_  __/
 /    /    /\ \  / /
/_/|_/_/|_/___/ /_/

NNST: Network Scan Tools

Usage:
    nnst portscan [-t=<timeout>] <address> <ports>...
    nnst portscan [-t=<timeout>] <address> -r <start_port> <end_port>

Command:
    portscan: Check port(s) open
        WARNING: now, only for TCP


Options:
    address                     Target address (hostname, domain or IP)
    ports                       Target port list
    -t --timeout=<timeout>      Set timeout [ms] (default=2500)

    -r --range                  Range mode
    <start_port>, <end_port>    Set scan range

    -h --help                   Show this help
    -v --version                Show version info
"""

let args = docopt(doc, version=VERSION)

if args["portscan"]:
    let address: string = $args["<address>"]

    var timeout: int
    try:
        timeout = parseInt($args["--timeout"])
    except ValueError:
        timeout = -1

    var ports: seq[int]

    if args["--range"]:
        ports = ((parseInt $(args["<start_port>"]))..(parseInt $(args["<end_port>"]))).toSeq
    elif args["<ports>"].kind == vkList:
        ports = @(args["<ports>"]).map(parseInt)
    else:
        ports = @[($args["<ports>"]).parseInt]
    
    var scan_result: seq[bool]
    if timeout >= 0:
        scan_result = scan_port(address, ports, timeout)
    else:
        scan_result = scan_port(address, ports)

    for i, p in ports:
        echo "${port}: ${result}" % ["port", $p, "result", $scan_result[i]]
