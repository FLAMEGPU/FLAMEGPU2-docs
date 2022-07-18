# FLAME GPU 2 User Guide

[![build](https://github.com/FLAMEGPU/FLAMEGPU2-docs/actions/workflows/build.yml/badge.svg)](https://github.com/FLAMEGPU/FLAMEGPU2-docs/actions/workflows/build.yml)
[![publish](https://github.com/FLAMEGPU/FLAMEGPU2-docs/actions/workflows/publish.yml/badge.svg)](https://github.com/FLAMEGPU/FLAMEGPU2-docs/actions/workflows/publish.yml)

This repository contains the content and build process for generating the FLAMEGPU2 user guide.

When building, it can optionally be linked to the main FLAMEGPU2 source repository to include doxygen generated API documentation.

The FLAME GPU 2 userguide and API docs can be found at [docs.flamegpu.com](https://docs.flamegpu.com).

## Requirements

* [CMake](https://cmake.org/)
* [Python3](https://www.python.org/downloads/) `>= 3.7`
* [Graphviz](https://graphviz.org/)
* Python Packages (see `requirements.txt`):
  * [Sphinx](http://www.sphinx-doc.org/en/master/)
  * [Breathe](https://breathe.readthedocs.io/en/latest/)
  * [Exhale](https://exhale.readthedocs.io/en/latest/)
  * [sphinx_rtd_theme](https://sphinx-rtd-theme.readthedocs.io/en/stable/)

### Optional Requirements

* [FLAMEGPU2 Source](https://github.com/FLAMEGPU/FLAMEGPU2_dev): Required for building api documentation
* [Doxygen](http://www.doxygen.nl/): Required for building api documentation

## Installing Python Requirements

### Using `venv` (linux)

```bash
mkdir -p -m 700 ~/.venvs
python3 -m venv ~/.venvs/FLAMEGPU2_userguide
source ~/.venvs/FLAMEGPU2_userguide/bin/activate
python3 -m pip install -Ur requirements.txt 
```

### Using Conda (windows)

```bash
conda create --name FLAMEGPU2_userguide python=3
conda activate FLAMEGPU2_userguide
pip install -Ur requirements.txt
```

## Building

CMake is used to generate a build script for your specific platform, this requires a supported build system.

On Linux `make` will normally be available, on Windows Visual Studio is the usual option, however if this is not installed [Ninja](https://ninja-build.org/) is a smaller lightweight alternative.

The following command will generate build files:

```bash
mkdir -p build && cd build
cmake .. 
cmake --build .
```

You can optionally specify the location of the FLAMEGPU2 source repository:

```bash
mkdir -p build && cd build
cmake .. -DFLAMEGPU_ROOT="<absolute path to FLAMEGPU2>"
```

If you lack a build system, executing `windows.bat` inside the directory `cmake` provides an alternative. However, this still requires executing CMake if api documentation is required.

## Publishing

The GitHub actions workflow [publish](https://github.com/FLAMEGPU/FLAMEGPU2-docs/actions/workflows/publish.yml) builds the documentation from the `master` branch and pushes the generated html to the `gh-pages` branch.
This is then hosted at [docs.flamegpu.com](https://docs.flamegpu.com).

This includes the API documentation, generated based on the contents of [FLAMEGPU/FLAMEGPU2](https://github.com/FLAMEGPU/FLAMEGPU2) at build time
If the API has been updated but the user guide has not, the workflow can be manually triggered by users with the correct github permissions using the `Run workflow` button on the `publish` page.
It may be worth manually running the `build` workflow first to make sure it can be built.