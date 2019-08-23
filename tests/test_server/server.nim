import net
import threadpool
import strutils


proc shutdown(): void =
    quit(0)


proc server_threadprocess(port: int) {.thread.} =
    let sock = newSocket()
    sock.bindAddr(Port(port))
    sock.listen()

    var client: Socket
    var address: string

    while true:
        sock.acceptAddr(client, address)
        echo "Port $#: Access accepted from $#" % [$port, address]
        
        if port == 9999:
            shutdown()

        sock.send("ping ;D")


when isMainModule:
    const port_list = [80, 443, 9999]
    for p in port_list:
        spawn server_threadprocess(p)
    sync()
