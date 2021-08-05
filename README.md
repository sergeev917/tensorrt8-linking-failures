Steps to reproduce
==================

1. Download `cuda-repo-ubuntu1804-11-4-local_11.4.1-470.57.02-1_amd64.deb`
into the `vendor` subdirectory.

2. Download `cudnn-11.4-linux-x64-v8.2.2.26.tgz` into the `vendor` subdirectory.

3. Download `TensorRT-8.0.1.6.Ubuntu-20.04.aarch64-gnu.cuda-11.3.cudnn8.2.tar.gz`
into the `vendor` subdirectory.

4. Run `./build_and_run.sh`. The script will build a docker image and run it.
The expected result of the running part looks like:

```
[...]
#14 [test_case_1 1/1] RUN g++     -o /tmp/test.so -fPIC -shared lib.cc     -Wno-deprecated-declarations     -I ./include     lib/libnvinfer_static.a     lib/libcudnn_static.a     lib/libcublasLt_static.a     lib/libcublas_static.a     lib/libcudart_static.a     lib/libculibos.a     lib/libnvrtc.so     lib/libcuda.so     lib/libnvidia-ml.so     -lrt     -lpthread     -ldl
#14 sha256:ef7092bc705320327608bf9c66bb8a3575fde6e1a294305271f5a3214090d961
#14 11.92 /usr/bin/ld: lib/libcublasLt_static.a(_1_1_cask.safe.cpp.o): relocation R_X86_64_PC32 against undefined hidden symbol `DW.ref._ZTISt12out_of_range' can not be used when making a shared object
#14 11.92 /usr/bin/ld: final link failed: Bad value
#14 11.92 collect2: error: ld returned 1 exit status
[...]
#14 [test_case_2 1/1] RUN g++     -o /tmp/test.so -fPIC -shared lib.cc     -Wno-deprecated-declarations     -I ./include     -Wl,-whole-archive     lib/libnvinfer_static.a     lib/libcudnn_static.a     lib/libcublasLt_static.a     lib/libcublas_static.a     lib/libcudart_static.a     lib/libculibos.a     -Wl,-no-whole-archive     lib/libnvrtc.so     lib/libcuda.so     lib/libnvidia-ml.so     -lrt     -lpthread     -ldl
#14 sha256:e7a34db0e33e53922298cf21d8d478eae3f81b8b30b8aaa33f917a6866022697
#14 16.97 lib/libcublasLt_static.a(_1_1_cask_plugin.cpp.o):(.bss+0x0): multiple definition of `customCudaList'
#14 16.97 lib/libnvinfer_static.a(cask_plugin.cpp.o):(.bss+0x0): first defined here
#14 16.98 collect2: error: ld returned 1 exit status
```
