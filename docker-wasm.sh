#!/bin/bash

function docker-wasm-start {
    if ! docker image inspect docker-wasm > /dev/null 2>&1; then
        if [ -f ./docker-wasm/build.sh ]; then
            ./docker-wasm/build.sh
        else
            docker pull jorgeprendes420/docker-wasm
            docker tag jorgeprendes420/docker-wasm docker-wasm
        fi
    fi

    if ! docker container inspect docker-wasm > /dev/null 2>&1; then
        # Run a wasm-capable docker
        docker run --rm -d \
            --privileged \
            -v /var/run/docker-wasm:/var/run/docker-wasm \
            --name docker-wasm \
            docker-wasm \
            /bin/sh -c \
                "addgroup -g $(getent group docker | cut -d: -f3) docker && dind dockerd --host unix:///var/run/docker-wasm/docker.sock" \
            > /dev/null
        
        # Give docker time to start
        sleep 1
    fi

    if ! docker context inspect docker-wasm > /dev/null 2>&1; then
        # Create a context for the wasm-capable docker
        docker context create docker-wasm \
            --description "Docker + WebAssembly" \
            --docker "host=unix:///var/run/docker-wasm/docker.sock" \
            > /dev/null
    fi
}

function docker-wasm-stop {
    docker context   rm -f docker-wasm > /dev/null
    docker container rm -f docker-wasm > /dev/null
}

function docker-wasm {

docker-wasm-start
    docker --context=docker-wasm "$@"
}

docker-wasm-start
