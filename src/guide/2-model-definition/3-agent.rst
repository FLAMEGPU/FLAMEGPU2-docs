Defining Agents
===============

Agents are the central component of FLAME GPU simulations, as they map effectively to the highly parallel architecture of GPUs.

**TODO General Description**

Model Definition
----------------
**TODO**



Agent Function Conditions
~~~~~~~~~~~~~~~~~~~~~~~~~
When defining agent functions the initial and end states for the executing agent must be specified. Following this,
all agents in the specified initial state will execute the agent function and move to the end state. In order to
allow agents in the same state to diverge an agent function condition must be added to the function.

Agent function conditions are executed by all agents before the main agent function, and must return either ``true``
or ``false``. Agents which return ``true`` pass the function and continue to execute the agent function and transition
to the end state.

Within agent function conditions a reduced read-only FGPU Device API is available. This only permits reading agent
variables, reading environment variables and random number generation.

Example definition:

.. code:: cpp

    // This agent function condition only allows agents who's 'x' variable equals '1' to progress
    FLAMEGPU_AGENT_FUNCTION_CONDITION(x_is_1) {
        return FLAMEGPU->getVariable<int>("x") == 1;
    }
    
 
.. code:: cpp

    // A model is defined
    ModelDescription m("model");
    // It contains an agent with 'variable 'x' and two states 'foo' and 'bar'
    AgentDescription &a = m.newAgent("agent");
    a.newVariable<int>("x");
    a.newState("foo");
    a.newState("bar");
    // The agent has an agent function which transitions agents from state 'foo' to 'bar'
    AgentFunctionDescription &af1 = a.newFunction("example_function", ExampleFn);
    af1.setInitialState("foo");
    af1.setEndState("bar");
    // Only agents that pass function condition 'x_is_1' may execute the function and transition
    af1.setFunctionCondition(x_is_1);