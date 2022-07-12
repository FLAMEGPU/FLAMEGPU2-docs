.. _Host Functions and Conditions:

Host Functions & Conditions
===========================
Not all model behaviours can be achieved with :ref:`agent functions<Agent Functions>`. Some behaviours need to operate over at a level above agents, host functions provide this functionality. If you need to perform a reduction over an agent population, sort agents or update environment properties a host function can deliver.

Host functions, as suggested by their name, execute on the host rather than the GPU. As such, they have access to the whole simulation state via the :class:`HostAPI<flamegpu::HostAPI>`, however there is an inherent latency to copying data between host and device. So it is often preferable to minimise agent interactions from host functions as much as feasible.

In prior versions of FLAME GPU, host functions were restricted to executing as initialisation functions (once before the simulation), exit functions (once after the simulation) or step functions (once at the end of each step). FLAME GPU 2 now additionally allows host functions to execute among agent functions during a step.

Host conditions are host functions with a return value. Currently, their usage is limited to a model's exit conditions, for example if a model can fully resolve before the number of time steps specified. All content that refers to host functions in this chapter applies to host conditions too.

This chapter has been broken up into several sections:

.. toctree::
   :maxdepth: 1
   
   defining-host-functions.rst
   interacting-with-environment.rst   
   agent-operations.rst   
   random-numbers.rst
   miscellaneous.rst

.. note::
  Currently **custom** reductions and transformations of agent variables are not supported via the Python API.
