Creating a Project
==================

The recommended method for creating new FLAMEGPU2 projects is cloning the example template repository. This automatically pulls in the FLAMEGPU2 library
and is set up using our recommended project structure. The example includes a simple model which can be removed or modified to create your own model.

Cloning the Example template
----------------------------

If you don't already have ``git`` installed and on your path, follow the instructions TODO: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

Run the following command from the command line to clone the example template:

.. code-block::

  git clone git@github.com:FLAMEGPU/FLAMEGPU2-example-template.git

Building the Model
------------------ 

Navigate into the project directory:

.. code-block::
   
  cd FLAMEGPU2-example-template

Run the following commands to build the model with visualisation enabled:

.. code-block::
  
  mkdir -p build && cd build
  cmake -DVISUALISATION=ON .. 
  make -j8

The option ``-j8`` enables parallel compilation using up to 8 threads, this is recommended to improve build times. If the build fails, your PC may not have enough
RAM to support building with multiple threads. Try reducing ``-j8`` to ``-j4``, ``-j2`` or omitting it entirely to build on a single thread.

TODO: Add windows build instructions