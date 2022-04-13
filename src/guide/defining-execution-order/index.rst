.. _Execution Order:
Defining Execution Order
========================
Before a model can be executed, it's necessary to define the order in which the various agent and host functions will be executed.
FLAME GPU 2 has two approaches which can be used for this; either specifying the dependencies between functions, or manually assigning functions to layers (as found in FLAME GPU 1).

Additionally, FLAME GPU 2 introduces submodels. These are a new concept allowing self contained iterative algorithms, such as parallel conflict resolution, to be represented as a nested model.

This chapter has been broken up into several sections:

.. toctree::
   :maxdepth: 1
   
   dependency-graph.rst
   layers.rst
   exit-conditions.rst
   submodels.rst