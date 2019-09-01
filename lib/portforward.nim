# Copyright (c) 2019 Hiroki.T
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import asyncnet
import asyncdispatch
import json
import strutils
import os

var shutdown_sock: AsyncSocket
proc gen_shutdown_process(sock: AsyncSocket): proc =
    # Close socket
    shutdown_sock = sock
    return proc() {.noconv.} = shutdown_sock.close(); echo "Bye ;D"; quit(0)


proc dest_to_local(local, dest: AsyncSocket) {.async.} =
    # Send TCP data from dest to local
    while true:
        var buffer: array[1, char]
        let dest_recv_len = await dest.recvInto(buffer.unsafeAddr, 1)
        if dest_recv_len > 0:
            await local.send(buffer.unsafeAddr, dest_recv_len)
        else:
            echo "Connection closed! Broken tunnel :("
            return


proc local_to_dest(local, dest: AsyncSocket) {.async.} =
    # Send TCP data from local to dest
    while true:
        var buffer: array[1, char]
        let local_recv_len: int = await local.recvInto(buffer.unsafeAddr, 1)
        if local_recv_len > 0:
            await dest.send(buffer.unsafeAddr, local_recv_len)
        else:
            echo "Connection closed! Broken tunnel :("
            return


proc tunnel(local, dest: AsyncSocket) {.async.} =
    # TCP data tunnel
    asyncCheck dest_to_local(local, dest)
    asyncCheck local_to_dest(local, dest)
    

proc serverprocess(client: AsyncSocket, host_port: int) {.async.} =
    let host: AsyncSocket = newAsyncSocket()
    await host.connect("localhost", Port(host_port))
    echo "Forwarding $#" % [$host_port]
    asyncCheck tunnel(host, client)
    

proc server*(address: string, port: int) {.async.} =
    let sock: AsyncSocket = newAsyncSocket()
    sock.bindAddr(Port(port), address)
    sock.listen()

    setControlCHook(gen_shutdown_process(sock))
    while true:
        let client: AsyncSocket = await sock.accept()
        let port: string = await client.recvLine()
        asyncCheck serverprocess(client, port.parseInt)


proc client*(address: string, port, from_port, to_port: int) {.async.} =
    let host: AsyncSocket = newAsyncSocket()
    await host.connect(address, Port(port))
    await host.send($from_port & "\n")
    echo "Connected $#:$# => localhost:$#" % [address, $from_port, $to_port]
    
    let local: AsyncSocket = newAsyncSocket()
    local.bindAddr(Port(to_port), "localhost")
    local.listen()

    setControlCHook(gen_shutdown_process(local))
    while true:
        let client = await local.accept()
        asyncCheck tunnel(client, host)