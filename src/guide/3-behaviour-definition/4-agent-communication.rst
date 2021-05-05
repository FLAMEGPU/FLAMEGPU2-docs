Agent Communication
===================

Communication between agents in FLAMEGPU2 is handled through messages. Messages contain variables which are used to transmit information between agents.

*TODO: Diagram demonstrating messaging structure*

Defining Messages
-----------------
Defining a message type in FLAMEGPU2 requires selection of a communication strategy and specification of the data the message will contain. FLAME GPU comes 
with several built-in communication strategies, described below. It can also be extended to support bespoke messaging types. For guidance on this see the file 
``include/flamegpu/runtime/messaging.h``. For each message type, the communication strategy defines how the messages will be accessed.

============== =========================== ==================================================
Type           Symbol                       Description
============== =========================== ==================================================
Brute Force    ``MsgBruteForce``           Access all messages
Spatial 2D     ``MsgSpatial2D``            Access all messages within a radius in 2D
Spatial 3D     ``MsgSpatial3D``            Access all messages within a radius in 3D
Array 1D       ``MsgArray1D``              Directly access messages via a 1 dimensional array
Array 2D       ``MsgArray2D``              Directly access messages via a 2 dimensional array
Array 3D       ``MsgArray3D``              Directly access messages via a 3 dimensional array
============== =========================== ==================================================

A new message type can defined using one of the above symbols:

.. tabs::
    
    .. code-tab:: python
      
      # Create a new message type called "location" which uses the brute force communication strategy
      location_message = model.newMessageBruteForce("location")

    .. code-tab:: cpp
      
      // Create a new message type called "location" which uses the brute force communication strategy
      MsgBruteForce::Description &locationMessage = model.newMessage("location");

Data the message should contain can be defined using the ``newVariable`` method of the ``MessageDescription`` object:

.. tabs::
    
    .. code-tab:: python
      
      # Add a variable of type "int" with name "id" to the "location_message" type
      location_message.newVariableInt("id")

    .. code-tab:: cpp
      
      // Add a variable of type "int" with name "id" to the "location_message" type
      locationMessage.newVariable<Int>("id");




Sending Messages
----------------
Messages can be output by agent functions. Each agent function can output a single message. To output a message from an agent function,
the communication strategy and message type must be specified. The communication strategy is set in the third parameter of the agent function definition,
and must match that of the message type:

.. tabs::

    .. code-tab:: cpp

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MsgBruteForce" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, MsgNone, MsgBruteForce) {
        // Agent function code goes here
        ...
      }

To specify the type of message the function should output, the ``setMessageOutput`` method of the ``AgentFunctionDescription`` object is used:

.. tabs::
    
    .. code-tab:: python
      
      # Specify that the "outputdata" agent function outputs a "location_message"
      outputdata.setMessageOutput("location_message")

    .. code-tab:: cpp
      
      // Specify that the "outputdata" agent function outputs a "location_message"
      outputdata.setMessageOutput("location_message");

The agent function will now output a message of type "location_message". The variables in the message can be set as follows:

.. tabs::

    .. code-tab:: cpp

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MsgBruteForce" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, MsgNone, MsgBruteForce) {
        // Set the "id" message variable to this agent's id 
        FLAMEGPU->message_out.setVariable<int>("id", FLAMEGPU->getVariable<int>("id"));
      }

**Spatial Messaging**
If you are using ``MsgSpatial3D`` then your message type will automatically have the following variables added to it which are used for communication:

- x (float)
- y (float)
- z (float)

These must be set in your agent function. 

.. tabs::

    .. code-tab:: cpp

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MsgSpatial3D" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, MsgNone, MsgSpatial3D) {
        // Set the required variables for spatial messaging
        FLAMEGPU->message_out.setVariable<float>("x", FLAMEGPU->getVariable<float>("x"));
        FLAMEGPU->message_out.setVariable<float>("y", FLAMEGPU->getVariable<float>("y"));
        FLAMEGPU->message_out.setVariable<float>("z", FLAMEGPU->getVariable<float>("z"));

      }

You must also specify the interaction radius via the ``MessageDescription`` object:

.. tabs::
    
    .. code-tab:: python
      
      # Specify that the "outputdata" agent function has an interaction radius of 2.0
      outputdata.setRadius(2.0)

    .. code-tab:: cpp
      
      // Specify that the "outputdata" agent function has an interaction radius of 2.0f
      outputdata.setMessageOutput(2.0f);

Reading Messages
----------------

Reading a message is very similar to sending one. The second argument in the agent function definition defines the input message communication strategy.

.. tabs::

    .. code-tab:: cpp

      // Define an agent function, "inputdata" which has accepts an input message using the "MsgBruteForce" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, MsgBruteForce, MsgNone) {
        // Agent function code goes here
        ...
      }

The input message type is specified using the ``setMessageInput`` method of the ``AgentFunctionDescription`` object:


.. tabs::
    
    .. code-tab:: python
      
      # Specify that the "inputdata" agent function inputs a "location_message"
      inputdata.setMessageInput("location_message")

    .. code-tab:: cpp
      
      // Specify that the "inputdata" agent function inputs a "location_message"
      inputdata.setMessageInput("location_message");

With the input message type specified, the message list will be available in the agent function definition. The message list can be iterated over to access each message:


.. tabs::

    .. code-tab:: cpp

      // Define an agent function, "inputdata" which has accepts an input message using the "MsgBruteForce" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, MsgBruteForce, MsgNone) {
        // For each message in the message list
        for (const auto& message : FLAMEGPU->message_in) {
          int idFromMessage = message->getVariable<int>("id");
        }
      }

**Spatial Messaging**
If you are using one of the spatial messaging strategies, you will also need to supply the x and y coordinates of this agent to access the relevant messages:

.. tabs::

    .. code-tab:: cpp

      // Define an agent function, "inputdata" which has accepts an input message using the "MsgSpatial" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, MsgSpatial, MsgNone) {
        // Get this agent's x, y, z variables
        const float x = FLAMEGPU->getVariable<float>("x");
        const float y = FLAMEGPU->getVariable<float>("y");
        const float z = FLAMEGPU->getVariable<float>("z");
        
        // For each message in the message list which was output by a nearby agent
        for (const auto& message : FLAMEGPU->message_in(x, y, z)) {
          int idFromMessage = message->getVariable<int>("id");
        }
      }

**TODO** also needs manual radius check