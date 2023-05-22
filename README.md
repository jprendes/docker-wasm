# Running WebAssembly containers with Docker

This repo provides a simple method to try WebAssembly containers with Docker

# Usage

In bash run:

```bash
source <(curl -sSfL https://raw.githubusercontent.com/jprendes/docker-wasm/main/docker-wasm.sh)

# Run a hello world wasm container
docker-wasm run --rm \
    --platform=wasm32/wasi \
    --runtime=io.containerd.wasmtime.v1 \
    rumpl/hello-barcelona

# Run python in a wasm container
docker-wasm run --rm \
    --platform=wasm32/wasi \
    --runtime=io.containerd.wasmtime.v1 \
    jorgeprendes420/python-wasm \
    -c "import os; print(os.uname())"
```