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
Within agent functions, variables can be accessed with ``setVariable`` and ``getVariable``.
These variables are accessed from higher latency device memory, so it's recommended that you avoid multiple reads or writes to the same variable in any agent functions.

.. code:: cpp

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, MsgNone, MsgNone) {
        // Return agent variable 'x' and store it in local variable 'x'
        int x = FLAMEGPU->getVariable<int>("x");
        // Update the local copy
        x++;
        // Store the updated local copy in the agent's 'x' variable
        FLAMEGPU->setVariable<int>("x", x);
        return ALIVE;
    }

Agent variables can also be arrays, accessing these requires extra arguments. It is not possible to retrieve or set a full array in a single function call, during agent functions, elements must be accessed individually.

.. code:: cpp

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, MsgNone, MsgNone) {
        // Return agent variable 'location[1]' and store it in local variable 'y'
        // The length of the array must be passed as the second template argument, in this example the array has a length of 3
        int y = FLAMEGPU->getVariable<int, 3>("location", 1);
        // Update the local copy
        y++;
        // Store the updated local copy in the agent's 'location[1]' variable
        FLAMEGPU->setVariable<int, 3>("location", y, 1);
        return ALIVE;
    }

Environment Property Access
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Environment properties are read-only within agent functions (however they can be updated with host functions).

The pattern for reading environment properties is similar to agent variables. The syntax for array variables is slightly different, as the length of the array is not required, however elements are still accessed individually.

.. code:: cpp

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, MsgNone, MsgNone) {
        // Store the environment property 'a' in local variable 'foo'
        float foo = FLAMEGPU->environment.get<float>("a");
        // Store the environment array property 'b[1]' in local variable 'bar'
        // Unlike agent variables, the length of the array is not passed as a template argument
        float bar = FLAMEGPU->environment.get<float>("b", 1);
        return ALIVE;
    }

Random Number Generation
~~~~~~~~~~~~~~~~~~~~~~~~
The agent function random number api is identical to that present in host functions. It is also seeded according to the random seed provided at model execution, making it preferable to external random libraries. Floating point uniform, normal and log normal distributions are available alongside range based integer distributions.

The main difference, is that uniformly distributed floats are in the range ``(0-1]``, whereas host generation is in the range ``[0-1)``. This is due to the underlying libraries used.

*If unfamiliar with the range notation, square brackets* ``[ ]`` *denote the bound is inclusive whereas regular brackets* ``( )`` *represent an exclusive bound.*

.. code:: cpp

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, MsgNone, MsgNone) {
        // Generate a uniform distributed random float in the range (0-1]
        float x = FLAMEGPU->random.uniform<float>()
        // Generate a normal distributed random double
        double y = FLAMEGPU->random.normal<double>()
        // Generate a log normal distributed random float
        float z = FLAMEGPU->random.logNormal<float>()
        // Generate a uniform random int in the range [5, 12]
        int w = FLAMEGPU->random.uniform<int>(5, 12)
        return ALIVE;
    }
    
``float`` may be replaced with ``double``, similarly ``int`` may be
replaced with any suitable integer type (e.g. signed/unsigned:
``int8_t``, ``int16_t``, ``int32_t``, ``int_64_t``).

Communication (Messaging)
~~~~~~~~~~~~~~~~~~~~~~~~~
Available messaging types and their usage is detailed in :doc:`section 4 <4-agent-communication.rst>`.

Agent Creation
~~~~~~~~~~~~~~
The Device API’s agent creation interface is only able to create a single agent per instance of the
agent function. Additionally, the agent type and state being created must be earlier specified as
part of the model description.

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
    // You can also enable optional agent output
    function.setAgentOutputOptional(true);


Agent Output from Device:

.. code:: cpp

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, MsgNone, MsgNone) {
        // The output agent's 'x' variable is set
        FLAMEGPU->agent_out.setVariable<float>("x", 12.0f);
        // The 'y' variable has not been set, so will be set to it's default '1.0f'
        return ALIVE;
    }
