# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 ubuntu:22.04 AS build

# Install build dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        python3 clang build-essential git curl pkg-config zlib1g-dev

# Install wasi-sdk
RUN mkdir -p /opt/wasi-sdk && \
    curl -sSfL https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-16/wasi-sdk-16.0-linux.tar.gz | \
    tar Cxz /opt/wasi-sdk --strip-components=1

# Install wasmtime
RUN curl https://wasmtime.dev/install.sh -sSf | WASMTIME_HOME=/usr/local bash

# Install zlib in wasi-sdk
# See https://github.com/python/cpython/issues/93819#issuecomment-1384541880
RUN curl -sSfL https://www.zlib.net/zlib-1.2.13.tar.xz | \
    tar CJx /opt && \
    cd /opt/zlib-1.2.13/ && \
    CC=/opt/wasi-sdk/bin/clang RANLIB=/opt/wasi-sdk/bin/ranlib ./configure --prefix= && \
    make install \
        prefix=/opt/wasi-sdk/share/wasi-sysroot \
        libdir=/opt/wasi-sdk/share/wasi-sysroot/lib/wasm32-wasi \
        pkgconfigdir=/opt/wasi-sdk/share/wasi-sysroot/lib/pkgconfig

# Get cpython's source
RUN mkdir -p /src/cpython && \
    curl -sSfL https://github.com/python/cpython/archive/refs/heads/main.tar.gz | \
        tar Cxz /src/cpython --strip-components=1

# Build cpython for wasi
RUN cd /src/cpython && \
    ./Tools/wasm/wasm_build.py wasi && \
    /opt/wasi-sdk/bin/llvm-strip builddir/wasi/python.wasm && \
    make -C builddir/wasi wasm_stdlib

# Copy the built artifacts to a known location
RUN mkdir -p /src/out && \
    cd /src/cpython/builddir/wasi && \
    cp -R python.wasm usr /src/out

# Generate the actual WebAssembly image
FROM scratch
COPY --from=build /src/out/ /
ENTRYPOINT [ "/python.wasm" ]
