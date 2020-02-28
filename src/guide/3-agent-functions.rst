Agent Behaviour
===============

Agent behaviour is defined using agent functions, agents can change their own state, send and read messages and create new agents.

**TODO General Description**


FLAMEGPU Device API
-------------------

The FLAMEGPU Device API provides functionality within agent functions for
accessing simulation properties and managing the executing agent, usage of
this functionality is described below.

Agent Variable Access
~~~~~~~~~~~~~~~~~~~~~
**TODO Description**

Environment Property Access
~~~~~~~~~~~~~~~~~~~~~~~~~~~
**TODO Description**

Random Number Generation
~~~~~~~~~~~~~~~~~~~~~~~~
**TODO Description**

Communication (Messaging)
~~~~~~~~~~~~~~~~~~~~~~~~~
Available messaging types and their usage is detailed in :doc:`section 4 <4-agent-communication.rst>`.

Agent Creation
~~~~~~~~~~~~~~
The Device API’s agent creation interface is only able to create a single agent per instance of the
agent function. Additionally, the agent type and state being created must be earlier specified as
part of the model description.

Device agent creation is always treated as optional, if any agent variable is set the agent will be output.

**Note:** *Agents created by agent functions do not exist until the next layer.*


Model Definition:

.. code:: cpp
    ModelDescription model("example_model");
    AgentDescription &agent = model.newAgent("example_agent");
    // Agents require atleast 1 variable
    agent.newVariable<float>("x");
    agent.newVariable<float>("y", 1.0f);
    AgentFunctionDescription &function = agent.newFunction("example_function", ExampleFn);
    // The agent type 'example_agent' is set as the agent output type
    function.setAgentOutput(agent);


Agent Output from Device:
.. code:: cpp
    FLAMEGPU_AGENT_FUNCTION(ExampleFn, MsgNone, MsgNone) {
        // The output agent's 'x' variable is set
        FLAMEGPU->agent_out.setVariable<float>("x", 12.0f);
        // The 'y' variable has not been set, so will be set to it's default '1.0f'
        return ALIVE;
    }