Conditional Behaviours
======================

Agent Function Conditions
-------------------------
Agent function conditions are specified using the :c:macro:`FLAMEGPU_AGENT_FUNCTION_CONDITION`, this differs from the normal agent function macro as only the function condition name must be specified.


Agent function conditions are primarily used to split agent populations, allowing them to diverge between agent states. As such, when creating an :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` the initial and end states for the executing agent must be specified. Following this, all agents in the specified initial state will execute the agent function and move to the end state. In order to allow agents in the same state to diverge an agent function condition must be added to the function.

Agent function conditions are executed by all agents before the main agent function, and must return either ``true``
or ``false``. Agents which return ``true`` pass the function and continue to execute the agent function and transition
to the end state.

Within agent function conditions a reduced read-only Device API, :class:`ReadOnlyDeviceAPI<flamegpu::ReadOnlyDeviceAPI>`, is available. This only permits reading agent
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


More Info 
---------

* Full API documentation for :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`
* Full API documentation for :c:macro:`FLAMEGPU_AGENT_FUNCTION_CONDITION`
* Full API documentation for :class:`ReadOnlyDeviceAPI<flamegpu::ReadOnlyDeviceAPI>`