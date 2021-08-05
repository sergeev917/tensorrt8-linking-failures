# syntax = docker/dockerfile:1.0-experimental
FROM ubuntu:18.04 as base
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq -o=Dpkg::Use-Pty=0 update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        g++ \
        vim
WORKDIR /w
RUN --mount=type=bind,source=vendor,target=/w/vendor \
    sha1sum --strict --check vendor/checksums && \
    mkdir -p /w/include /w/lib /w/debs && \
    dpkg-deb --fsys-tarfile vendor/cuda-repo-ubuntu1804-11-4-local_11.4.1-470.57.02-1_amd64.deb | \
    tar --directory=/w/debs --strip-components=3 --wildcards --verbose \
        --extract './var/cuda-repo-ubuntu1804-11-4-local/*.deb' && \
    dpkg-deb --fsys-tarfile debs/cuda-driver-dev-11-4_11.4.108-1_amd64.deb | \
    tar --directory=/w/lib --strip-components=8 --wildcards --verbose \
        --extract './usr/local/cuda-11.4/targets/x86_64-linux/lib/stubs/*.so' && \
    dpkg-deb --fsys-tarfile debs/cuda-nvml-dev-11-4_11.4.43-1_amd64.deb | \
    tar --directory=/w/lib --strip-components=8 --wildcards --verbose \
        --extract './usr/local/cuda-11.4/targets/x86_64-linux/lib/stubs/*.so' && \
    dpkg-deb --fsys-tarfile debs/cuda-nvrtc-dev-11-4_11.4.100-1_amd64.deb | \
    tar --directory=/w/lib --strip-components=8 --wildcards --verbose \
        --extract './usr/local/cuda-11.4/targets/x86_64-linux/lib/stubs/*.so' && \
    dpkg-deb --fsys-tarfile debs/libcublas-dev-11-4_11.5.4.8-1_amd64.deb | \
    tar --directory=/w/lib --strip-components=7 --wildcards --verbose \
        --extract './usr/local/cuda-11.4/targets/x86_64-linux/lib/*.a' && \
    dpkg-deb --fsys-tarfile debs/cuda-cudart-dev-11-4_11.4.108-1_amd64.deb | \
    tar --directory=/w/lib --strip-components=7 --wildcards --verbose \
        --extract './usr/local/cuda-11.4/targets/x86_64-linux/lib/*.a' && \
    tar --directory=/w/lib --strip-components=2 --wildcards --verbose \
        --extract 'cuda/lib64/*.a' --gzip < vendor/cudnn-11.4-linux-x64-v8.2.2.26.tgz && \
    tar --directory=/w/lib --strip-components=4 --wildcards --verbose \
        --extract 'TensorRT-8.0.1.6/targets/x86_64-linux-gnu/lib/*.a' \
        --gzip < vendor/TensorRT-8.0.1.6.Linux.x86_64-gnu.cuda-11.3.cudnn8.2.tar.gz && \
    tar --directory=/w/include --strip-components=2 --wildcards --verbose \
        --extract 'TensorRT-8.0.1.6/include/*' \
        --gzip < vendor/TensorRT-8.0.1.6.Linux.x86_64-gnu.cuda-11.3.cudnn8.2.tar.gz && \
    rm -rf debs
COPY lib.cc /w/

FROM base as test_case_1
RUN g++ \
    -o /tmp/test.so -fPIC -shared lib.cc \
    -Wno-deprecated-declarations \
    -I ./include \
    lib/libnvinfer_static.a \
    lib/libcudnn_static.a \
    lib/libcublasLt_static.a \
    lib/libcublas_static.a \
    lib/libcudart_static.a \
    lib/libculibos.a \
    lib/libnvrtc.so \
    lib/libcuda.so \
    lib/libnvidia-ml.so \
    -lrt \
    -lpthread \
    -ldl

FROM base as test_case_2
RUN g++ \
    -o /tmp/test.so -fPIC -shared lib.cc \
    -Wno-deprecated-declarations \
    -I ./include \
    -Wl,-whole-archive \
    lib/libnvinfer_static.a \
    lib/libcudnn_static.a \
    lib/libcublasLt_static.a \
    lib/libcublas_static.a \
    lib/libcudart_static.a \
    lib/libculibos.a \
    -Wl,-no-whole-archive \
    lib/libnvrtc.so \
    lib/libcuda.so \
    lib/libnvidia-ml.so \
    -lrt \
    -lpthread \
    -ldl
