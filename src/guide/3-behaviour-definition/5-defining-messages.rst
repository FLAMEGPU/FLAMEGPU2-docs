Defining Messages
=================

FLAME GPU represents agent communication with messages. These are output by one group of 
agents in a layer, and then read in a subsequent layer by the same, or a different, group of agents.

All messaging type can be optionally output, so that only a subset of agents executing the message
output agent function will produce a message.

Agents are able to read back their own message when iterating message lists.

FLAME GPU comes with several messaging options, described below. It can be extended to support 
bespoke messaging types, for guidance on this see the file ``include/flamegpu/runtime/messaging.h``.

============== =========================== ==================================================
Type           Symbol                       Description
============== =========================== ==================================================
*Disabled*     ``MsgNone``                 No message type is active
Brute Force    ``MsgBruteForce``           Access all messages
Spatial 2D     ``MsgSpatial2D``            Access all messages within a radius in 2D
Spatial 3D     ``MsgSpatial3D``            Access all messages within a radius in 3D
Array 1D       ``MsgArray1D``              Directly access messages via a 1 dimensional array
Array 2D       ``MsgArray2D``              Directly access messages via a 2 dimensional array
Array 3D       ``MsgArray3D``              Directly access messages via a 3 dimensional array
============== =========================== ==================================================


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


Array
------
Array messaging is available in 1D, 2D and 3D, providing direct access to messages at a known location within an array.

**TODO** Details on how optional output works.

It is also possible to iterate messages within a Moore neighbourhood of a selected element of the array.

An example of 2D array messaging can be found in the `game_of_life` example.

Model Definition
~~~~~~~~~~~~~~~~

**TODO**

Message Access
~~~~~~~~~~~~~~

**TODO**


Spatial
-------
Spatial messaging is available in both 2D and 3D, providing access to a reduced subset of messages 
which fall within a set radius. This message types force the inclusion of the ``float`` message 
variables ``x``, ``y`` (and ``z``). These are used internally by the data structure and correspond
to the location of the message.

**Note:** *Spatial message access does not limit messages to those inside the radius. The user must 
perform this bounds check manually. This is not performed automatically, to avoid duplication of 
expensive distance calculations.*

An example of spatial 3D messaging can be found in the `circles_spatial3D` example.

Model Definition
~~~~~~~~~~~~~~~~

Defining the message's variables:

.. code:: cpp

    // Message type is specified as MsgSpatial2D
    MsgSpatial2D::Description &message = model.newMessage<MsgSpatial2D>("location");
    // Add extra message variables
    message.newVariable<int>("id");
    // This is the search radius for message access, and must be set
    message.setRadius(1.0f);
    // These are the bounds of the environment, and must be set
    // messages that fall outside will have their location clamped (within the data structure's handling)
    message.setMin(0, 0);
    message.setMax(50, 50);
        
The message is added to agent functions the same as all other messaging types. For an example see the
earlier examples for Brute Force messaging.

Message Access
~~~~~~~~~~~~~~

Outputting messages:

.. code:: cpp

    // The 3rd argument specifies the output message type as Spatial 2D messaging
    FLAMEGPU_AGENT_FUNCTION(output_message, MsgNone, MsgSpatial2D) {
        // Set extra message variables
        FLAMEGPU->message_out.setVariable<int>("id", FLAMEGPU->getVariable<int>("id"));
        // Spatial messaging add convenience methods for setting the 2D or 3D location with a single call
        FLAMEGPU->message_out.setLocation(
            FLAMEGPU->getVariable<float>("x"),
            FLAMEGPU->getVariable<float>("y"));
        return ALIVE;
    }
    
Reading messages:

.. code:: cpp

    // The 2nd argument specifies the input message type as Brute Force messaging
    FLAMEGPU_AGENT_FUNCTION(move, MsgBruteForce, MsgNone) {
        const int ID = FLAMEGPU->getVariable<int>("id");
        // Load user specified constants
        const float REPULSE_FACTOR = FLAMEGPU->environment.get<float>("repulse");
        const float RADIUS = FLAMEGPU->message_in.radius();
        // Load agent variables
        const float x1 = FLAMEGPU->getVariable<float>("x");
        const float y1 = FLAMEGPU->getVariable<float>("y");
        int count = 0;
        // The message list is an iterable, the search origin is specified as (x1, y1, z1)
        for (const auto &message : FLAMEGPU->message_in(x1, y1, z1)) {
            // Check the ID variable to skip the agent's own message
            if (message.getVariable<int>("id") != ID) {
                const float x2 = message.getVariable<float>("x");
                const float y2 = message.getVariable<float>("y");
                float x21 = x2 - x1;
                float y21 = y2 - y1;
                const float separation = sqrt(x21*x21 + y21*y21);
                // Calculate whether the message falls within the search radius
                if (separation < RADIUS && separation > 0.0f) {
                    // Process the message
                    float k = sinf((separation / RADIUS)*3.141*-2)*REPULSE_FACTOR;
                    x21 /= separation;
                    y21 /= separation;
                    fx += k * x21;
                    fy += k * y21;
                    count++;
                }
            }
        }
        fx /= count > 0 ? count : 1;
        fy /= count > 0 ? count : 1;
        // Update the agent according to the message processing result
        FLAMEGPU->setVariable<float>("x", x1 + fx);
        FLAMEGPU->setVariable<float>("y", y1 + fy);
        return ALIVE;
    }


Graph
-----
Not yet available.