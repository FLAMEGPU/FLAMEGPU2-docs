Defining Agent Functions
========================

What is an Agent Function?
--------------------------

Most behaviours within your model will be implemented using agent functions. Agent functions allow you to modify agent variables, change state
and interact with the environment or other agents. Each agent function in FLAMEGPU2 is associated with a particular agent type and is represented
by an ``AgentFunctionDescription`` object. This object describes the name of the function, the agent state in which it should be active, and any
state transitions it should apply to the agent. The implementation code for the behaviour is written separately and is identified by using the
``FLAMEGPU_AGENT_FUNCTION`` macro to label the code. Alternatively, the implementations can be written in strings and loaded at runtime. The latter
method is the only method supported for the python version of FLAMEGPU2.

Defining an Agent Function
--------------------------

An agent function is defined using the ``FLAMEGPU_AGENT_FUNCTION`` macro. This takes three arguments: a unique name identifying the function, an input
message communication strategy, and an output message communication strategy. We will discuss messages in more detail later, so for now don't worry about the second and third paramters.

In C++, these definitions should appear before your main function. In python, they should be specified in string literals, with the containing variable'state
name matching the unique function identifier:

.. tabs::

  .. code-tab:: python

    # Define an agent function called agent_fn1
    agent_fn1_source = r"""
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, MessageNone, MessageNone) {
        # Behaviour goes here
    }
    """

  .. code-tab:: cpp
     
    // Define an agent function called agent_fn1 - specified ahead of main function
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, MessageNone, MessageNone) {
        // Behaviour goes here
    }

    int main() {
    ... // Rest of code

With the agent function named and defined, it can now be attached to a particular agent type via an ``AgentDescription`` object:

.. tabs::

  .. code-tab:: python

    # Attach a function called agent_fn1 to an agent called agent
    # The AgentFunctionDescription is stored in the agent_fn1_description variable
    agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

  .. code-tab:: cpp
     
    // Attach a function called agent_fn1 to an agent called agent
    // The AgentFunctionDescription is stored in the agent_fn1_description variable
    TODO: Should we use auto for these?
    AgentFunctionDescription& agent_fn1_description = agent.newFunction("agent_fn1", agent_fn1_source);


Defining a Runtime-Compiled Agent Function (C++)
------------------------------------------------
If you are using the python interface, you can only use runtime-compiled agent functions and this was presented in
the previous section, so you can*TODO: skip to the next section*

The previously described method for defining an agent function results in the function being compiled at compile time. 
If you know that you want to define your agent behaviours at runtime, you can instead use this method. Otherwise, you can 
*TODO: skip to the next section*

To define a runtime-compiled agent function, the function source should be stored in a string:

*TODO: std::string vs const char**

.. tabs::

  .. code-tab:: cpp

    // Define an agent function called agent_fn1 which will be compiled at runtime
    const char* agent_fn1_source = R"###(
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, MessageNone, MessageNone) {
        // Behaviour goes here
    }
    )###";

The function can then be added to an ``AgentDescription`` using the ``newRTCFunction`` method:

.. tabs::

  .. code-tab:: cpp

    // Attach a runtime-compiled function called agent_fn1 to an agent called agent
    // The AgentFunctionDescription is stored in the agent_fn1_description variable
    AgentFunctionDescription& agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

FLAMEGPU Device Functions
-------------------------

If you wish to define regular functions which can be used within agent function definitions, you can use the `FLAMEGPU_DEVICE_FUNCTION` macro:

.. tabs::

  .. code-tab:: cpp

    // Define a function for adding two ingtegers which can be called inside agent functions.
    FLAMEGPU_DEVICE_FUNCTION int add(int a, int b) {
      return a + b;
    }

FLAMEGPU Host Device Functions
------------------------------

If you wish to define regular functions which can be used within agent function definitions and in host code, you can use the `FLAMEGPU_HOST_DEVICE_FUNCTION` macro:

.. tabs::

  .. code-tab:: cpp

    // Define a function for subtracting two ingtegers which can be called inside agent functions, or in host code
    FLAMEGPU_HOST_DEVICE_FUNCTION int subtract(int a, int b) {
      return a - b;
    }

Full Example Code From This Page
--------------------------------

.. tabs::

  .. code-tab:: python
    
    # Define an agent function called agent_fn1
    agent_fn1_source = r"""
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, MessageNone, MessageNone) {
        # Behaviour goes here
    }
    """

    # Attach a function called agent_fn1 to an agent called agent
    # The AgentFunctionDescription is stored in the agent_fn1_description variable
    agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

  .. code-tab:: cpp

    // Define a function for adding two ingtegers which can be called inside agent functions.
    FLAMEGPU_DEVICE_FUNCTION int add(int a, int b) {
      return a + b;
    }

    // Define an agent function called agent_fn1 - specified ahead of main function
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, MessageNone, MessageNone) {
        // Behaviour goes here
    }

    // Define an agent function called agent_fn1 which will be compiled at runtime
    const char* agent_fn1_source = R"###(
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, MessageNone, MessageNone) {
        // Behaviour goes here
    }
    )###";


    // Somewhere inside main() {

    // Attach a function called agent_fn1 to an agent called agent
    // The AgentFunctionDescription is stored in the agent_fn1_description variable
    TODO: Should we use auto for these?
    AgentFunctionDescription& agent_fn1_description = agent.newFunction("agent_fn1", agent_fn1_source);

    // Attach a runtime-compiled function called agent_fn1 to an agent called agent
    // The AgentFunctionDescription is stored in the agent_fn1_description variable
    AgentFunctionDescription& agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);


More Info 
---------
* Related User Guide Pages

  * `Interacting with the Environment <../3-behaviour-definition/3-interacting-with-environment.html>`_
  * `Random Number Generation <../8-advanced-sim-management/2-rng-seeds.html>`_

* Full API documentation for the ``EnvironmentDescription``: link
* Examples which demonstrate creating an environment

  * Boids Brute Force (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/boids_bruteforce/src/main.cu>`_)
  * Ensemble (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/ensemble/src/main.cu>`_)