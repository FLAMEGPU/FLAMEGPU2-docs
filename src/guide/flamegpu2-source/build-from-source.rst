.. _building-flamegpu-from-source:

Building FLAME GPU from Source
==============================

Building FLAME GPU 2.x from source requires:

* `git <https://git-scm.com/>`_
* `CMake <https://cmake.org/download/>`_ ``>= 3.25.2``
* CUDA or ROCm installation with a compatible C++20 host-compiler and build system:

  .. list-table::
     :widths: 20 15 25 40
     :header-rows: 1

     * - Hardware
       - OS
       - GPU Toolkit
       - Supported Compilers / Toolchains
     * - **NVIDIA GPU**
       - Linux
       - `CUDA <https://developer.nvidia.com/cuda-downloads>`_ ``>= 12.4``
       - `GCC <https://gcc.gnu.org/>`_ `>= 11` with `make <https://www.gnu.org/software/make/>`_ or `Ninja <https://ninja-build.org/>`_
     * - **NVIDIA GPU**
       - Windows
       - `CUDA <https://developer.nvidia.com/cuda-downloads>`_ ``>= 12.4``
       - `MSVC 2022/2026 <https://visualstudio.microsoft.com/>`_
     * - **AMD GPU**
       - Linux
       - `ROCm/HIP <https://rocm.docs.amd.com/en/latest/>`_ ``>= 7.0``
       - ``amdclang++`` / ``hipcc`` with `make <https://www.gnu.org/software/make/>`_ or `Ninja <https://ninja-build.org/>`_
     * - **AMD GPU**
       - Windows
       - Not yet supported
       -

FLAME GPU can then be built from source by configuring CMake into a build directory, and invoking your systems build process through CMake. 

I.e. to build the Release configuration from source under a Linux system with an NVIDIA GPU from the command line:

.. code-block:: bash

    git clone git@github.com:FLAMEGPU/FLAMEGPU2.git
    cd FLAMEGPU2
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DFLAMEGPU_BACKEND=CUDA
    cmake --build build --target all -j 8

For full instructions on how to build FLAME GPU from source, please see the `FLAME GPU 2 README <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/README.md#building-flame-gpu>`__.
These details may vary between releases, so it recommended that you refer to the copy of ``README.md`` present in the root of the source directory which you are trying to build.

Related Links
-------------
* User Guide Page: :ref:`Quickstart<quickstart>`
