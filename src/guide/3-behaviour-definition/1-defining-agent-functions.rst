.. _Defining Agent Function:

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

Agent Functions can be specified as C++ functions, built at compile time when using the C++ interface, or they can be specified as Run-Time Compiled (RTC) functions when using the C++ interface, or the Python interface.

An agent function is defined using the ``FLAMEGPU_AGENT_FUNCTION`` macro. 
This takes three arguments: a unique name identifying the function, an input message communication strategy, and an output message communication strategy.
We will discuss messages in more detail later, so for now don't worry about the second and third parameters.

For Non-RTC functions, when using the C++ interface, the ``FLAMEGPU_AGENT_FUNCTION`` macro can be used to declare and define the agent function, which can then be associated with the ``flamegpu::AgentDescription`` object using the ``newFunction`` method.


.. tabs::

  .. code-tab:: cpp
     
    // Define an agent function called agent_fn1 - specified ahead of main function
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Behaviour goes here
    }

    int main() {
        // ...

        // Attach a function called agent_fn1, defined by the symbol agent_fn1 to the AgentDescription object agent.
        flamegpu::AgentFunctionDescription& agent_fn1_description = agent.newFunction("agent_fn1", agent_fn1);

        // ...
    }

When using the Run-Time Compiled (RTC) functions, optionally in the C++ interface or required by the Python interface, the function must be defined in a string and associated with the AgentDescription using the ``newRTCFunction`` method.

.. tabs::

  .. code-tab:: cpp

    const char* agent_fn1_source = R"###(
    // Define an agent function called agent_fn1 - specified ahead of main function
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Behaviour goes here
    }
    )###";

    int main() {
        // ...

        // Attach a function called agent_fn1, defined in the string variable agent_fn1_source to the AgentDescription object agent.
        flamegpu::AgentFunctionDescription& agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

        // ...
    }

  .. code-tab:: python

    # Define an agent function called agent_fn1
    agent_fn1_source = r"""
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, MessageNone, MessageNone) {
        # Behaviour goes here
    }
    """

    # ...

    # Attach a function called agent_fn1 to an agent represented by the AgentDescription agent 
    # The AgentFunctionDescription is stored in the agent_fn1_description variable
    agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

    # ...

FLAMEGPU Device Functions
-------------------------

If you wish to define regular functions which can be used within agent function definitions, you can use the `FLAMEGPU_DEVICE_FUNCTION` macro:

.. tabs::

  .. code-tab:: cpp

    // Define a function for adding two integers which can be called inside agent functions.
    FLAMEGPU_DEVICE_FUNCTION int add(int a, int b) {
      return a + b;
    }

FLAMEGPU Host Device Functions
------------------------------

If you wish to define regular functions which can be used within agent function definitions and in host code, you can use the `FLAMEGPU_HOST_DEVICE_FUNCTION` macro:

.. tabs::

  .. code-tab:: cpp

    // Define a function for subtracting two integers which can be called inside agent functions, or in host code
    FLAMEGPU_HOST_DEVICE_FUNCTION int subtract(int a, int b) {
      return a - b;
    }

Full Example Code From This Page
--------------------------------

.. tabs::

  .. code-tab:: cpp

    // Define a function for adding two integers which can be called inside agent functions.
    FLAMEGPU_DEVICE_FUNCTION int add(int a, int b) {
      return a + b;
    }

    // Define an agent function called agent_fn1 - specified ahead of main function
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Behaviour goes here
    }

    // Define an agent function called agent_fn1 which will be compiled at runtime
    const char* agent_fn1_source = R"###(
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Behaviour goes here
    }
    )###";

    // Somewhere inside main() {

    // Attach a function called agent_fn1 to an agent called agent
    // The AgentFunctionDescription is stored in the agent_fn1_description variable
    flamegpu::AgentFunctionDescription& agent_fn1_description = agent.newFunction("agent_fn1", agent_fn1_source);

    // Attach a runtime-compiled function called agent_fn1 to an agent called agent
    // The AgentFunctionDescription is stored in the agent_fn1_description variable
    flamegpu::AgentFunctionDescription& agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

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


More Info 
---------
* Related User Guide Pages

  * `Interacting with the Environment <../3-behaviour-definition/3-interacting-with-environment.html>`_
  * `Random Number Generation <../8-advanced-sim-management/2-rng-seeds.html>`_

* Full API documentation for the ``EnvironmentDescription``: link
* Examples which demonstrate creating an environment

  * Boids Brute Force (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/boids_bruteforce/src/main.cu>`__)
  * Ensemble (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/ensemble/src/main.cu>`__)