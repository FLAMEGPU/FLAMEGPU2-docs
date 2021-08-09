Agent Communication
===================

Communication between agents in FLAMEGPU2 is handled through messages. Messages contain variables which are used to transmit information between agents.

Defining Messages
-----------------
Defining a message type in FLAMEGPU2 requires selection of a communication strategy and specification of the data the message will contain. FLAME GPU comes 
with several built-in communication strategies, described below. It can also be extended to support bespoke messaging types. For guidance on this see the file 
``include/flamegpu/runtime/messaging.h``. For each message type, the communication strategy defines how the messages will be accessed.

============== =========================== ======================================================
Type           Symbol                       Description
============== =========================== ======================================================
Brute Force    ``MessageBruteForce``           Access all messages
Spatial 2D     ``MessageSpatial2D``            Access all messages within a radius in 2D
Spatial 3D     ``MessageSpatial3D``            Access all messages within a radius in 3D
Array 1D       ``MessageArray1D``              Directly access messages via a 1 dimensional array
Array 2D       ``MessageArray2D``              Directly access messages via a 2 dimensional array
Array 3D       ``MessageArray3D``              Directly access messages via a 3 dimensional array
============== =========================== ======================================================

A new message type can defined using one of the above symbols:

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Create a new message type called "location" which uses the brute force communication strategy
      flamegpu::MessageBruteForce::Description &locationMessage = model.newMessage("location");

    .. code-tab:: python
      
      # Create a new message type called "location" which uses the brute force communication strategy
      location_message = model.newMessageBruteForce("location")



Data the message should contain can then be defined using the ``newVariable`` method of the message's ``Description`` object:

.. tabs::

    .. code-tab:: cuda CUDA C++
        
      // Add a variable of type "int" with name "id" to the "location_message" type
      locationMessage.newVariable<int>("id");

    .. code-tab:: python
      
      # Add a variable of type "int" with name "id" to the "location_message" type
      location_message.newVariableInt("id")

Sending Messages
----------------
Messages can be output by agent functions. Each agent function can output a single message. To output a message from an agent function,
the communication strategy and message type must be specified. The communication strategy is set in the third parameter of the agent function definition,
and must match that of the message type:

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageBruteForce" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageBruteForce) {
        // Agent function code goes here
        ...
      }

To specify the type of message the function should output, the ``setMessageOutput`` method of the ``AgentFunctionDescription`` object is used:

.. tabs::
    .. code-tab:: cuda CUDA C++
      
      // Specify that the "outputdata" agent function outputs a "location_message"
      outputdata.setMessageOutput("location_message");    

    .. code-tab:: python
      
      # Specify that the "outputdata" agent function outputs a "location_message"
      outputdata.setMessageOutput("location_message")

The agent function will now output a message of type "location_message". The variables in the message can be set as follows:

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageBruteForce" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageBruteForce) {
        // Set the "id" message variable to this agent's id 
        FLAMEGPU->message_out.setVariable<int>("id", FLAMEGPU->getVariable<int>("id"));
        return flamegpu::ALIVE;
      }

**Spatial Messaging**
If you are using ``MessageSpatial2D`` or ``MessageSpatial3D`` then your message type will automatically have ``float`` variables ``x``, ``y`` (and ``z`` for 3D) added to the message. These correspond to the message's spatial location and must be set in your agent function. 

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageSpatial3D" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageSpatial3D) {
        // Set the required variables for spatial messaging
        FLAMEGPU->message_out.setVariable<float>("x", FLAMEGPU->getVariable<float>("x"));
        FLAMEGPU->message_out.setVariable<float>("y", FLAMEGPU->getVariable<float>("y"));
        FLAMEGPU->message_out.setVariable<float>("z", FLAMEGPU->getVariable<float>("z"));
        return flamegpu::ALIVE;
      }

You must also specify the interaction radius via the ``MessageDescription`` object:

.. tabs::
    
    .. code-tab:: cuda CUDA C++

      // Specify that the "outputdata" agent function has an interaction radius of 2.0f
      outputdata.setMessageOutput(2.0f);
  
    .. code-tab:: python
      
      # Specify that the "outputdata" agent function has an interaction radius of 2.0
      outputdata.setRadius(2.0)

      
**Array Messaging**
If you are using ``MessageArray1D``, ``MessageArray2D`` or ``MessageArray3D`` then you must specify the corresponding array index when outputting a message. It is important that only 1 agent writes a message to each index (if ``SEATBELTS`` is enabled then multiple outputs to the same index will raise an exception).

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageArray3D" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageArray3D) {
        // Set the index to store the array message
        FLAMEGPU->message_out.setIndex(FLAMEGPU->getVariable<unsigned int>("x"), FLAMEGPU->getVariable<unsigned int>("y"), FLAMEGPU->getVariable<unsigned int>("z"));
        // Set message variables
        FLAMEGPU->message_out.setVariable<float>("foo", FLAMEGPU->getVariable<float>("bar"));
        return flamegpu::ALIVE;
      }

Reading Messages
----------------

Reading a message is very similar to sending one. The second argument in the agent function definition defines the input message communication strategy.

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageBruteForce" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageBruteForce, flamegpu::MessageNone) {
        // Agent function code goes here
        ...
      }

The input message type is specified using the ``setMessageInput`` method of the ``AgentFunctionDescription`` object:


.. tabs::

    .. code-tab:: cuda CUDA C++
      
      // Specify that the "inputdata" agent function inputs a "location_message"
      inputdata.setMessageInput("location_message");

    .. code-tab:: python
      
      # Specify that the "inputdata" agent function inputs a "location_message"
      inputdata.setMessageInput("location_message")

With the input message type specified, the message list will be available in the agent function definition. The message list can be iterated over to access each message:


.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageBruteForce" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageBruteForce, flamegpu::MessageNone) {
        // For each message in the message list
        for (const auto& message : FLAMEGPU->message_in) {
          int idFromMessage = message->getVariable<int>("id");
        }
      }

**Spatial Messaging**
If you are using one of the spatial messaging strategies, you will also need to supply the x and y coordinates of this agent to access the relevant messages.

Spatial messaging will return all messages within the radius specified at the model description time, however it can also return some messages which fall outside of this radius. So it is important that messages are distance checked to ensure they fall within the radius.

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageSpatial3D" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageSpatial3D, flamegpu::MessageNone) {
        const float RADIUS = FLAMEGPU->message_in.radius();
        // Get this agent's x, y, z variables
        const float x = FLAMEGPU->getVariable<float>("x");
        const float y = FLAMEGPU->getVariable<float>("y");
        const float z = FLAMEGPU->getVariable<float>("z");
        
        // For each message in the message list which was output by a nearby agent
        for (const auto& message : FLAMEGPU->message_in(x, y, z)) {
          const float x2 = message.getVariable<float>("x");
          const float y2 = message.getVariable<float>("y");
          const float z2 = message.getVariable<float>("z");
          // Calculate the distance to check the message is in range
          float x21 = x2 - x1;
          float y21 = y2 - y1;
          float z21 = z2 - z1;
          const float separation = cbrt(x21*x21 + y21*y21 + z21*z21);
          if (separation < RADIUS && separation > 0.0f) {
            // Process the message
            int idFromMessage = message->getVariable<int>("id");
          }
        }
        return flamegpu::ALIVE;
      }

Please note that at this time spatial messaging does not return messaging wrapping the environment bounds.

**Array Messaging**
If you are using one of the array messaging strategies, there are several methods for accessing messages.

Messages can be accessed from a specific array index:

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageSpatial3D" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray3D, flamegpu::MessageNone) {
        // Get this agent's x, y, z variables
        const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
        const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
        const unsigned int z = FLAMEGPU->getVariable<unsigned int>("z");
        // Select the message
        const auto message = FLAMEGPU->message_in.at(x, y, z);        
        // Process the message's variables
        int idFromMessage = message->getVariable<int>("id");
        return flamegpu::ALIVE;
      }
      
Similar to spatial messaging, array messages can be used to iterate the exclusive Moore neighbourhood around a target index (the specified index's message is not returned):

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageSpatial3D" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray3D, flamegpu::MessageNone) {
        // Get this agent's x, y, z variables
        const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
        const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
        const unsigned int z = FLAMEGPU->getVariable<unsigned int>("z");
         // For each message in the exclusive Moore neighbourhood of radius 1
        for (const auto& message : FLAMEGPU->message_in(x, y, z)) {        
          // Process the message's variables
          int idFromMessage = message->getVariable<int>("id");
        }
        return flamegpu::ALIVE;
      }

Moore iteration supports radii of any suitable positive integer. Whilst the default is ``1``, bespoke values can optionally be passed as the final argument during iteration.

If wrapping of array bounds is required, then an alternate iterator method ``wrap()`` is called.

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageSpatial3D" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray3D, flamegpu::MessageNone) {
        // Get this agent's x, y, z variables
        const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
        const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
        const unsigned int z = FLAMEGPU->getVariable<unsigned int>("z");
         // For each message in the wrapped exclusive Moore neighbourhood of radius 2
        for (const auto& message : FLAMEGPU->message_in.wrap(x, y, z, 2)) {        
          // Process the message's variables
          int idFromMessage = message->getVariable<int>("id");
        }
        return flamegpu::ALIVE;
      }