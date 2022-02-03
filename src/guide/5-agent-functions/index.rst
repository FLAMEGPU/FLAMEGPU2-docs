.. _Agent Functions:
Agent Functions
===============

As FLAME GPU is an agent-based modelling framework, agent functions are central to describing a model. Most behaviours within your model will be implemented using agent functions.

Each agent has one or more agent functions, which allow agents to interact with the environment and other agents. Additionally, agent functions can be conditionally executed based on agent states and properties.

Each agent function in FLAME GPU 2 is associated with a particular agent type and is represented by an :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` object. This object describes the name of the function, the agent state in which it should be active, and any state transitions it should apply to the agent. The implementation code for the behaviour is written separately and is identified by using the
:c:macro:`FLAMEGPU_AGENT_FUNCTION` macro to label the code. Alternatively, the implementations can be written in strings and loaded at runtime. The latter method is the only method supported by FLAME GPU 2's Python API.

This chapter has been broken up into several sections:

.. toctree::
   :maxdepth: 1
   
   1-defining-agent-functions.rst
   2-modifying-agent-variables.rst   
   3-interacting-with-environment.rst   
   4-agent-communication.rst
   5-agent-birth-death.rst
   6-random-numbers.rst
   7-conditional-behaviours.rst
   8-miscellaneous.rst
