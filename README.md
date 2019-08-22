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
nimble test
```

or you can use docker

```sh
docker build -t nnst-test -f Dockerfile_test
docker run -t nnst-test
```