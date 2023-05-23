#!/bin/bash

source ../docker-wasm.sh

# Build the python wasm container image
docker-wasm buildx build --provenance=false --platform=wasi/wasm32 -t hello-wasm .

# Run the container, running a tiny python script
docker-wasm run --rm \
        --platform=wasi/wasm32 \
        --runtime=io.containerd.wasmtime.v1 \
        hello-wasm
