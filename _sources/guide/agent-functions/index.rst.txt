.. _Agent Functions:

Agent Functions
===============

As FLAME GPU is an agent-based modelling framework, agent functions are central to describing a model. Most behaviours within your model will be implemented using agent functions.

Each agent has one or more agent functions, which allow agents to interact with the environment and other agents. Additionally, agent functions can be conditionally executed based on agent states and properties.

Each agent function in FLAME GPU 2 is associated with a particular agent type and is represented by an :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` object. This object describes the name of the function, the agent state in which it should be active, and any state transitions it should apply to the agent. 

The implementation code for the behaviour (the actual agent function) can be specified in three alternative ways;

* As a globally scoped (CUDA) C++ function, labelled with the :c:macro:`FLAMEGPU_AGENT_FUNCTION` macro
* As a C++ function labelled with the :c:macro:`FLAMEGPU_AGENT_FUNCTION` macro but written as a string (supported in either a C++ or Python 3)
* As a global scoped Python 3 function annotated as ``@pyflamegpu.agent_function`` which will be transpiled to equivalent C++ and which is compiled at runtime

This chapter has been broken up into several sections:

.. toctree::
   :maxdepth: 1
   
   defining-agent-functions.rst
   modifying-agent-variables.rst   
   interacting-with-environment.rst   
   agent-communication.rst
   agent-birth-death.rst
   random-numbers.rst
   agent-state-transitions.rst
   miscellaneous.rst
   
.. note::
  If you require a function that operates at a population or global scope you should use :ref`Host Functions<Host Functions and Conditions>`, these are distinct from Agent Functions and cannot be launched from agent functions.
