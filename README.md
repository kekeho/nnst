# NNST

NNST: Network Scan Tools

## Status

Master: [![Build Status](https://travis-ci.org/kekeho/nnst.svg?branch=master)](https://travis-ci.org/kekeho/nnst)

## Features

### Port scan

Scan unix port (parallel), and check port is open.

- WARNING: now only for TCP.

## Usage

```sh
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