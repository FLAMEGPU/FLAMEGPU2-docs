Quickstart
==========

This document lists the minimal steps to install or build FLAME GPU 2, create a new model and run a simulation.

Details are provided for the :ref:`CUDA C++ <q-cudacpp-quickstart>` and :ref:`Python 3 <q-python-quickstart>` interfaces


Prerequisites
-------------

Regardless of which programming interface you wish to use there are some common requirements:

* Windows or Linux (with glibc ``>= 2.17``)
* `CUDA Toolkit <https://developer.nvidia.com/cuda-downloads>`__ >= 11.0 and a `Compute Capability <https://developer.nvidia.com/cuda-downloads>`__ >= 3.5 NVIDIA GPU

Installing python binary wheels requires:

* `Python <https://www.python.org/>`__ ``>= 3.6``

   * ``pip``

Building CUDA C++ from source: 

* `git <https://git-scm.com/>`__
* `CMake <https://cmake.org/download/>`__ ``>= 3.18``
* C++17 capable C++ compiler (host), compatible with the installed CUDA version

  * `Microsoft Visual Studio 2019 <https://visualstudio.microsoft.com/>`__ (Windows)
  * `make <https://www.gnu.org/software/make/>`__ and `GCC <https://gcc.gnu.org/>`__ `>= 7` (Linux)

If you need to build python bindings from source you will also require:

* `swig <http://www.swig.org/>`__ ``>= 4.0.2``
  
  * Swig ``4.x`` will be automatically downloaded by CMake if not available (if possible)


.. _q-cudacpp-quickstart:

CUDA C++
--------

Installation
^^^^^^^^^^^^

The CUDA C++ interface is not currently available as a pre-built binary distribution, or configured for central installation at this time. 

Please refer to :ref:`q-building-from-source-cudacpp` section.

.. _q-building-from-source-cudacpp:


Creating a new project
^^^^^^^^^^^^^^^^^^^^^^

The simplest way to create a new project is to use the provide template repository on GitHub: 

https://github.com/FLAMEGPU/FLAMEGPU2-example-template

This includes a ``CMakeLists.txt`` file, which sets a binary target named ``example``, which depends on the core ``FLAMEGPU/FLAMEGPU2`` repository, and will build it from source if required.

You can either:

* Use GitHubs's ``Use this template`` feature to create a copy of the template repository on your account
* Download a copy of the template repository as a zip via ``Download zip``
* Clone the template repository via ``git clone git@github.com:FLAMEGPU/FLAMEGPU2-example-template.git``

See the template project's ``README.md`` for more information.

Compiling your project
^^^^^^^^^^^^^^^^^^^^^^

FLAME GPU 2 projects using the CUDA C++ interface uses CMake with out-of-source builds. This is a 3 step process:

1. Create a build directory for an out of tree build
2. Configure CMake into the build directory, using the CMake CLI or GUI
   
   * Specify CMake configuration options such as the compute capabilities to target at this stage

3. Build compilation targets using the configured build system


For example, to build the ``example`` target of the template repository, for Compute Capability 6.0 GPUs in the Release configuration, using 8 threads under Linux:

.. code-block:: bash

   mkdir build && cd build
   cmake .. -DCUDA_ARCH=61 -DCMAKE_BUILD_TYPE=Release
   cmake --build . --target example -j 8

For more information on CMake Configuration options please see the `template repository README.md <https://github.com/FLAMEGPU/FLAMEGPU2-example-template#building-with-cmake>`__.


Running your project
^^^^^^^^^^^^^^^^^^^^

Once compiled, the executable will be placed into the ``bin/<config>/`` directory within your build directory. Execute with `--help` for CLI argument information

.. code-block:: bash

   cd build
   ./bin/Release/example --help


.. _q-python-quickstart:

Python 3
--------

The Python 3 interface for FLAME GPU 2 is available via pre-compiled binary wheels for some platforms, or can be built from source via CMake. 

.. _q-python_installation:

Installation
^^^^^^^^^^^^

Pre-built binary wheels are available for Windows and Linux on x86_64 platforms for:

* Python ``3.6`` to Python ``3.9``
* ``CUDA 11.0`` or ``CUDA 11.2+`` installations
* CUDA Compute Capability ``>= 3.5`` GPUs.
* With and without Visualisation support

If you do not meet these requirements, please see :ref:`q-python-building-from-source`.

To install the binary wheel for your combination of software requirements:

* Download the appropriate python wheel from the `latest GitHub Release <https://github.com/FLAMEGPU/FLAMEGPU2/releases/latest>`__
  
  * See the release notes of the specific release for details of which file corresponds to which release

* Optionally create a new python ``venv`` or conda environment to install the ``.whl`` in to

  .. code-block:: bash

      # If using a python venv:
     python3 -m venv venv
     source venv/bin/activate/bash

* Install the downloaded ``.whl`` file into your python environment via pip

  .. code-block:: bash

     python3 -m pip install filename.whl

.. _q-python-building-from-source:

Building from source
^^^^^^^^^^^^^^^^^^^^

FLAME GPU 2 uses CMake with out-of-source builds. This is a 3 step process:

1. Create a build directory for an out of tree build
2. Configure CMake into the build directory, using the CMake CLI or GUI
   
   * Specify CMake configuration options such as the compute capabilities to target at this stage

3. Build compilation targets using the configured build system

To build the python bindings, the ``BUILD_SWIG_PYTHON`` CMake option must be set to ``ON``, and the ``pyflamegpu`` target must be compiled. The generated python binary wheel can then be installed into your python environment of choice via `pip`

For example, to build and install python bindings into a new venv, for Compute Capability 6.0 GPUs in the Release configuration, using 8 threads under Linux:


.. code-block:: bash

   # Create and activate your venv
   python3 -m venv venv
   source venv/bin/activate

   # Build the python bindings, producing a .whl
   mkdir build && cd build
   cmake .. -DCUDA_ARCH=61 -DBUILD_SWIG_PYTHON=ON -DCMAKE_BUILD_TYPE=Release
   cmake --build . --target pyflamegpu -j 8

   # Install the wheel via pip
   python3 -m pip install lib/Release/python/venv/dist/*.whl


Creating a new project
^^^^^^^^^^^^^^^^^^^^^^

The simplest way to create a new project is to use the provide template repository on GitHub: 

https://github.com/FLAMEGPU/FLAMEGPU2-python-example-template

You can either:

* Use GitHubs's ``Use this template`` feature to create a copy of the template repository on your account
* Download a copy of the template repository as a zip via ``Download zip``
* Clone the template repository via 
  
  .. code-block:: bash

     git clone git@github.com:FLAMEGPU/FLAMEGPU2-python-example-template.git

Alternatively, as python models do not require a complex build system such as CMake simply creating a new python source file which includes ``import pyflamegpu`` would be sufficient


Then edit the python file as desired.

Running your project
^^^^^^^^^^^^^^^^^^^^

To run your python-based model:

* Activate the python environment which has ``pyflamegpu`` installed

  .. code-block:: bash

     # Assuming a python venv was created in the current directory, named venv
     source venv/bin/bash/activate

* Run your models ``.py`` file using your python 3 interpreter

  .. code-block:: bash

     # Assuming the main python file for your model is called model.py
     # Use --help for Usage instructions
     python3 model.py --help
