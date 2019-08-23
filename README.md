# NNST

NNST: Network Scan Tool  

## Status
Master: [![Build Status](https://travis-ci.org/kekeho/nnst.svg?branch=master)](https://travis-ci.org/kekeho/nnst)

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