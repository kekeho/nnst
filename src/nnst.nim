# Copyright (c) 2019 Hiroki.T
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import ../lib/portscan
import ../lib/portforward
import docopt
import sequtils
import strutils
import sugar
import asyncdispatch

const VERSION = "0.1.0"
const doc = """　
   _  ___  ____________
  / |/ / |/ / __/_  __/
 /    /    /\ \  / /
/_/|_/_/|_/___/ /_/

NNST: Network Scan Tools
Copyright: Hiroki Takemura (kekeho) All Rights Reserved.

Usage:
    nnst portscan [-t=<timeout>] <address> <ports>...
    nnst portscan [-t=<timeout>] <address> -r <start_port> <end_port>
    nnst portforward server <address> <server_port>
    nnst portforward client <address> <server_port> <from_address> <from_port> <to_port>


Command:
    portscan: Check port(s) open
        WARNING: now, only for TCP
    portforward: Port forwarding (You should run nnst both of server & client)


Options:
    address                             Target address (hostname, domain or IP)
    ports                               Target port list
    server_port                         Port which listening `nnst portforward` in server
    
    from_address, from_port, to_port    Port forward <from_address>(See from <address>):<from_port> => localhost:<to_port>

    -t --timeout=<timeout>              Set timeout [ms] (default=2500)

    -r --range                          Range mode
    <start_port>, <end_port>            Set scan range

    -h --help                           Show this help
    -v --version                        Show version info
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

elif args["portforward"]:
    if args["server"]:
        let address: string = $args["<address>"]
        let port: int = ($args["<server_port>"]).parseInt

        asyncCheck server(address, port)
        runForever()
    
    elif args["client"]:
        let address: string = $args["<address>"]
        let dest_port = ($args["<server_port>"]).parseInt
        let forward_from_address = $args["<from_address>"]
        let forward_from_port = ($args["<from_port>"]).parseInt
        let forward_to_port = ($args["<to_port>"]).parseInt

        asyncCheck client(address, dest_port, forward_from_address, forward_from_port, forward_to_port)
        runForever()

