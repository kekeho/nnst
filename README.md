# NNST

NNST: Network Scan Tools

## Status

Master: [![Build Status](https://travis-ci.org/kekeho/nnst.svg?branch=master)](https://travis-ci.org/kekeho/nnst)

## Features

### Port scan

Scan unix port (parallel), and check port is open.

- WARNING: now only for TCP.

### Port forward

Port forwarding over TCP | Websocket

- WARNING:
  - now only for TCP forwarding
  - Not secure! You should use secure protocol over this

## Usage

```sh

   _  ___  ____________
  / |/ / |/ / __/_  __/
 /    /    /\ \  / /
/_/|_/_/|_/___/ /_/

NNST: Network Scan Tools
Copyright: Hiroki Takemura (kekeho) All Rights Reserved.

Usage:
    nnst portscan [-t=<timeout>] <address> <ports>...
    nnst portscan [-t=<timeout>] <address> -r <start_port> <end_port>
    nnst portforward server [ws | tcp] <address> <server_port>
    nnst portforward client [ws | tcp] <address> <server_port> <from_address> <from_port> <to_port>


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

```

## Build

### Dependencies to build

- nim >= 0.20.2
- nimble

### Build command

```sh
nimble build
```

### Install

```sh
nimble install
```

## Test

```sh
docker-compose -f docker-compose-test.yml build  # Build test containers

docker-compose -f docker-compose-test.yml up  # Start test
```
