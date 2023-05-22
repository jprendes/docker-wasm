FROM ubuntu:22.04 AS build

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl iptables ca-certificates clang

# Install Rust
RUN curl -sSf https://sh.rustup.rs | \
    env RUSTUP_HOME=/opt/rust CARGO_HOME=/usr sh -s -- -y --no-modify-path && \
    rustup default stable

# Install Docker v 24.0.0
RUN curl -sSf https://download.docker.com/linux/static/stable/x86_64/docker-24.0.0.tgz | \
    tar Cxz /usr/local/bin --strip-components=1

# Install buildx for building images
RUN mkdir -p /usr/local/lib/docker/cli-plugins && \
    curl -sSfL https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-amd64 \
        -o /usr/local/lib/docker/cli-plugins/docker-buildx && \
    chmod a+x /usr/local/lib/docker/cli-plugins/docker-buildx

# Install the wasmtime containerd-shim
RUN cargo install \
    --git https://github.com/containerd/runwasi.git \
    containerd-shim-wasmtime \
    --bin containerd-shim-wasmtime-v1 \
    --root /usr/local

# Keep only the extrictly necessary files
# We don't need clang / rust/ curl anymore
FROM ubuntu:22.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        iptables ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local /usr/local

# Configure Docker to use containerd
RUN mkdir -p /etc/docker && \
    echo '{ "features": { "containerd-snapshotter": true } }' > /etc/docker/daemon.json
