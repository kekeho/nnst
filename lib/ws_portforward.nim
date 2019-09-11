# Copyright (c) 2019 hiroki
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import asynchttpserver
import asyncdispatch
import websocket
import asyncnet
import json
import strutils


proc dest_to_local(local: AsyncSocket, dest: AsyncWebSocket) {.async.} =
    while true:
        try:
            let (opcode, data) = await dest.readData()
            
            case opcode
            of Opcode.Binary:
                await local.send(data)
            of Opcode.Close:
                echo "Connection closed"
                asyncCheck dest.close()
                local.close()
                return
            else:
                return
        except:
            echo getCurrentExceptionMsg()
            return


proc local_to_dest(local: AsyncSocket, dest: AsyncWebSocket) {.async.} =
    while true:
        let data: string = await local.recv(1)
        if data.len > 0:
            await dest.sendBinary(data)
        else:
            return


proc tunnel(local: AsyncSocket, dest: AsyncWebSocket) {.async.} =
    asyncCheck local_to_dest(local, dest)
    asyncCheck dest_to_local(local, dest)


proc server_process(request: Request) {.async.} =
    let (ws, error) = await verifyWebsocketRequest(request, "nnstprotocol")

    if ws.isNil:
        # Error
        echo "Websocket negotiation failed " & error
        await request.respond(Http400, "Websocket negotiation failed " & error)
        request.client.close()
        return

    echo "New connection"
    try:
        let (opcode, data) = await ws.readData()
        case opcode
        of Opcode.Text:
            let config_json = parseJson(data)
            echo config_json
            let from_port: int = config_json["from_port"].getInt()
            let from_address: string = config_json["from_address"].getStr()

            let host: AsyncSocket = newAsyncSocket()
            await host.connect(from_address, Port(from_port))
            echo "Forwarding $#" % [$from_port]
            asyncCheck tunnel(host, ws)

        else:
            waitFor ws.close()
            return
    except:
        echo getCurrentExceptionMsg()
        return


proc server*(address: string, port: int) {.async.} =
    let server: AsyncHttpServer = newAsyncHttpServer()
    waitFor server.serve(Port(port), server_process, address)


proc client_process(local: AsyncSocket, address: string, port: int, from_address: string, from_port: int) {.async.} =
    let dest: AsyncWebSocket = waitFor newAsyncWebsocketClient(address, Port(port), path = "/", protocols = @["nnstprotocol"])
    
    let config = """
{
    "from_address": "$#",
    "from_port": $#
}
""" % [from_address, $from_port]
    await dest.sendText(config)

    asyncCheck tunnel(local, dest)


proc client*(address: string, port: int, from_address: string, from_port, to_port: int) {.async.} =
    let local: AsyncSocket = newAsyncSocket()
    local.bindAddr(Port(to_port), "localhost")
    local.listen()

    while true:
        let client = await local.accept()
        asyncCheck clientprocess(client, address, port, from_address, from_port)

