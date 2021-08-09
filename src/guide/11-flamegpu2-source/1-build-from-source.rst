Building FLAMEGPU from Source
=============================

Building FLAME GPU 2.x from source requires a C++ 17 host compiler, a CUDA toolkit 11.x installation, and CMake >= 3.18.

FLAME GPU can then be built from source by configuring CMake into a build directory, and invoking your systems build process through CMake. 

I.e. to build the Release configuration from source under a linux system from the command line:

.. code-block:: bash

    git clone git@github.com:FLAMEGPU/FLAMEGPU2.git
    cd FLAMEGPU2
    mkdir -p build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    cmake --build . --target all -j 8

For full instructions on how to build FLAME GPU from source, please see the `FLAME GPU 2 Readme <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/README.md>`__.