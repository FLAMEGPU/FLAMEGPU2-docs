# FLAMEGPU2 User Guide

This repository contains the content and build process for generating the FLAMEGPU2 user guide.

When building, it can optionally be linked to the main FLAMEGPU2 source repository to include doxygen generated API documentation.

## Requirements
* [CMake](https://cmake.org/)
* [Python3]
*Python Packages:*
  * [Sphinx](http://www.sphinx-doc.org/en/master/) >= 2.0
  * [Breathe](https://breathe.readthedocs.io/en/latest/) >= 4.13.0
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
python3 -m pip install -r requirements.txt 
```

### Using Conda (windows)

```
conda create --name FLAMEGPU2_userguide python=3
conda activate FLAMEGPU2_userguide
pip install -r requirements.txt
```

## Building
CMake is used to generate a build script for your specific platform, this requires a supported build system.

On Linux `make` will normally be available, on Windows Visual Studio is the usual option, however if this is not installed [Ninja](https://ninja-build.org/) is a smaller lightweight alternative.

The following command will generate build files:

```
mkdir -p build && cd build
cmake .. 
```

You can optionally specify the location of the FLAMEGPU2 source repository:

```
mkdir -p build && cd build
cmake .. -DFLAMEGPU2_ROOT="<absolute path to FLAMEGPU2>"
```

If you lack a build system, executing `windows.bat` inside the directory `cmake` provides an alternative. However, this still requires executing CMake if api documentation is required.