.. _building-flamegpu-from-source:

Building FLAME GPU from Source
==============================

Building FLAME GPU 2.x from source requires a C++ 17 host compiler, a CUDA toolkit 11.x installation, and CMake >= 3.18.

FLAME GPU can then be built from source by configuring CMake into a build directory, and invoking your systems build process through CMake. 

I.e. to build the Release configuration from source under a Linux system from the command line:

.. code-block:: bash

    git clone git@github.com:FLAMEGPU/FLAMEGPU2.git
    cd FLAMEGPU2
    mkdir -p build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    cmake --build . --target all -j 8

For full instructions on how to build FLAME GPU from source, please see the `FLAME GPU 2 ReadMe <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/README.md#building-flame-gpu>`__.
These details may vary between releases, so it recommended that you refer to the copy of ``README.md`` present in the root of the source directory which you are trying to build.

Related Links
-------------
* User Guide Page: :ref:`Quickstart<quickstart>`