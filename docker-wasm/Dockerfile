# syntax=docker/dockerfile:1
FROM docker:dind AS build

# Install dependencies
RUN apk update && \
    apk add --no-interactive \
        curl clang g++

# Install Rust
RUN curl -sSf https://sh.rustup.rs | \
    env RUSTUP_HOME=/opt/rust CARGO_HOME=/usr sh -s -- -y --no-modify-path && \
    rustup default stable

# Install the wasmtime containerd-shim
RUN cargo install \
    --git https://github.com/containerd/runwasi.git \
    containerd-shim-wasmtime \
    --bin containerd-shim-wasmtime-v1 \
    --root /usr/local

# Keep only the built containerd-shim-wasmtime-v1
FROM docker:latest

COPY --from=build /usr/local/bin/containerd-shim-wasmtime-v1 /usr/local/bin/containerd-shim-wasmtime-v1

# Configure Docker to use containerd
RUN mkdir -p /etc/docker && \
    echo '{ "features": { "containerd-snapshotter": true } }' > /etc/docker/daemon.json
