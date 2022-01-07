Worked Example
==============

This worked example walks through the process of implementing a simple biological cell simulation, beginning with an empty FLAMEGPU2 project.

To follow along this worked example you will want to first follow the `Quickstart`_ guide, which takes you through setting up FLAMEGPU2 on your system and creating an empty project.

Code for this example is provided in a git repository `here <https://github.com/FLAMEGPU/FLAMEGPU2-worked-example>`__. Each commit in the git history of the repository corresponds to a step of the worked example, allowing you to view the full code at any point.

The worked example can be followed in both C++ and Python. Full source code for each can respectively be found in the ``src`` and `py_src`` directories of the repository linked above.


The Model
---------

The model implemented is a simplified biological model. Two cell types are represented by spherical agents which exist in continuous space. These cells are able to grow, divide and die. In order to achieve this, whilst maintaining a reasonable density, cells are also able to move according to the location of their neighbours.


Guide Structure
---------------

