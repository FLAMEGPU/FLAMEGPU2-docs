Agent Communication
===================

FLAME GPU represents agent communication with messages. These are output by one group of 
agents in a layer, and then read in a subsequent layer by the same, or a different, group of agents.

All messaging type can be optionally output, so that only a subset of agents executing the message
output agent function will produce a message.

Agents are able to read back their own message when iterating message lists.

FLAME GPU comes with several messaging options, described below. It can be extended to support 
bespoke messaging types, for guidance on this see the file ``include/flamegpu/runtime/messaging.h``.

============== =========================== =========================================
Type           Symbol                       Description
============== =========================== =========================================
*Disabled*     ``MsgNone``                 No message type is active
Brute Force    ``MsgBruteForce``           Access all messages
Spatial 2D     ``MsgSpatial2D``            Access all messages within a radius in 2D
Spatial 3D     ``MsgSpatial3D``            Access all messages within a radius in 3D
============== =========================== =========================================


Brute Force
-----------
Brute force messaging is the most basic type of messaging, whereby all messages are seen when
iterating the message list. Due to the high level of agents supported by FLAMEGPU, use of brute
force messaging should be limited to small agent populations and optional outputs. There is often 
a more suitable message type.

An example of brute force messaging can be found in the `circles_bruteforce` example.

Model Definition
~~~~~~~~~~~~~~~~

Defining the message's variables:
.. code:: cpp
    MsgBruteForce::Description &message = model.newMessage("location");
    message.newVariable<int>("id");
    message.newVariable<float>("x");
        
Adding the message as an input/output to agent functions
    
.. code:: cpp
    // Some agent defined elsewhere
    AgentDescription &agent = ...;
    // This agent has an output function 'output_message'
    AgentFunctionDescription &output_fn = agent.newFunction("output_message", output_message)
    // 'output_message' fn outputs the message 'location'
    output_fn.setMessageOutput("location");
    // The message output is optional
    output_fn.setMessageOutputOptional(true);
    // Similarly the agent has 'move' function which reads the message 'location'
    agent.newFunction("move", move).setMessageInput("location");

Message Access
~~~~~~~~~~~~~~

Outputting messages:
.. code:: cpp
    // The 3rd argument specifies the output message type as Brute Force messaging
    FLAMEGPU_AGENT_FUNCTION(output_message, MsgNone, MsgBruteForce) {
        // Only agents with even id output the message
        if (FLAMEGPU->getVariable<int>("id") % 2 == 0) {
            // Agent variables are set to match the agent's 'id' and 'x' variables.
            FLAMEGPU->message_out.setVariable<int>("id", FLAMEGPU->getVariable<int>("id"));
            FLAMEGPU->message_out.setVariable<float>("x", FLAMEGPU->getVariable<float>("x"));
        }
        return ALIVE;
    }
    
Reading messages:
.. code:: cpp
    // The 2nd argument specifies the input message type as Brute Force messaging
    FLAMEGPU_AGENT_FUNCTION(move, MsgBruteForce, MsgNone) {
        const int ID = FLAMEGPU->getVariable<int>("id");
        const float x1 = FLAMEGPU->getVariable<float>("x");
        int count = 0;
        // The message list is an iterable
        for (const auto &message : FLAMEGPU->message_in) {
            // Check the ID variable to skip the agent's own message
            if (message.getVariable<int>("id") != ID) {
                // Process the remaining message variables
                const float x2 = message.getVariable<float>("x");
                const float separation = x2 - x1;
                if (separation < RADIUS && separation > -RADIUS) {
                    fx += separation;
                    count++;
                }
            }
        }
        fx /= count > 0 ? count : 1;
        // Update the agent according to the message processing result
        FLAMEGPU->setVariable<float>("x", x1 + fx);
        return ALIVE;
    }


Direct
------


Spatial
-------


Graph
-----