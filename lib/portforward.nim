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
            echo "Connection closed"
            return


proc local_to_dest(local, dest: AsyncSocket) {.async.} =
    # Send TCP data from local to dest
    while true:
        var buffer: array[1, char]
        let local_recv_len: int = await local.recvInto(buffer.unsafeAddr, 1)
        if local_recv_len > 0:
            await dest.send(buffer.unsafeAddr, local_recv_len)
        else:
            echo "Connection Closed"
            return


proc tunnel(local, dest: AsyncSocket) {.async.} =
    # TCP data tunnel
    asyncCheck dest_to_local(local, dest)
    asyncCheck local_to_dest(local, dest)
    

proc serverprocess(client: AsyncSocket, address: string, host_port: int) {.async.} =
    let host: AsyncSocket = newAsyncSocket()
    await host.connect(address, Port(host_port))
    echo "Forwarding $#" % [$host_port]
    asyncCheck tunnel(host, client)
    

proc server*(address: string, port: int) {.async.} =
    let sock: AsyncSocket = newAsyncSocket()
    sock.bindAddr(Port(port), address)
    sock.listen()

    setControlCHook(gen_shutdown_process(sock))
    while true:
        let client: AsyncSocket = await sock.accept()
        let address: string = await client.recvLine()
        let port: string = await client.recvLine()
        asyncCheck serverprocess(client, address,port.parseInt)


proc clientprocess(client: AsyncSocket, address: string, port: int, from_address: string, from_port, to_port: int) {.async.} =
    let host: AsyncSocket = newAsyncSocket()
    await host.connect(address, Port(port))
    await host.send($from_address & "\n")
    await host.send($from_port & "\n")
    echo "Connected $#:$# => localhost:$#" % [from_address, $from_port, $to_port]
    
    asyncCheck tunnel(client, host)


proc client*(address: string, port: int, from_address: string, from_port, to_port: int) {.async.} =
    let local: AsyncSocket = newAsyncSocket()
    local.bindAddr(Port(to_port), "localhost")
    local.listen()

    setControlCHook(gen_shutdown_process(local))
    while true:
        let client = await local.accept()
        asyncCheck clientprocess(client, address, port, from_address, from_port, to_port)