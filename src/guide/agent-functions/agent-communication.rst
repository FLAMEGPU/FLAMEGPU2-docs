.. _Device Agent Communication:

Agent Communication
^^^^^^^^^^^^^^^^^^^

Each agent function is able to output a single message, and read from a single message list. In order to achieve either of these, the agent function must be configured to specify the message which should be input and/or output. First the message type must have been defined, as covered in the earlier chapter on :ref:`defining messages<Defining Messages>`.

.. _Sending Messages:

Sending Messages
----------------
Messages can be output by agent functions. Each agent function can output a single message. To output a message from an agent function, the communication strategy and message type must be specified. The communication strategy is set in the third parameter of the agent function definition, and must match that of the message type:

.. tabs::

    .. code-tab:: cuda Agent C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageBruteForce" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageBruteForce) {
          // Agent function code goes here
          ...
      }


    .. code-tab:: py Agent Python

      # Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageBruteForce" communication strategy
      @pyflamegpu.agent_function
      def outputdata(message_in: pyflamegpu.MessageNone, message_out: pyflamegpu.MessageBruteForce):
          # Agent function code goes here
          ...

To specify the type of message the function should output, the :func:`setMessageOutput()<flamegpu::AgentFunctionDescription::setMessageOutput>` method of the :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` object is used:

.. tabs::
    .. code-tab:: cpp C++
      
      // Specify that the "outputdata" agent function outputs a "location_message"
      outputdata.setMessageOutput("location_message");    

    .. code-tab:: py Python
      
      # Specify that the "outputdata" agent function outputs a "location_message"
      outputdata.setMessageOutput("location_message")
      
By default, FLAMEGPU expects all agents to output a message every time the agent function is triggered. If optional message output is desired, then optional support can be enabled using :func:`AgentFunctionDescription::setMessageOutputOptional()<flamegpu::AgentFunctionDescription::setMessageOutputOptional>`.

.. tabs::
    .. code-tab:: cpp C++
      
      // Specify that the "outputdata" agent function's message output is optional
      outputdata.setMessageOutputOptional(true);    

    .. code-tab:: py Python
      
      # Specify that the "outputdata" agent function outputs a "location_message"
      outputdata.setMessageOutputOptional(True)
      
When optional message output is specified, only agents which set a message variable will have messages output.

The agent function will now allow output a message of type "location_message". The variables in the message can be set as follows:

.. tabs::

    .. code-tab:: cuda Agent C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageBruteForce" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageBruteForce) {
          // Set the "id" message variable to this agent's id 
          FLAMEGPU->message_out.setVariable<flamegpu::id_t>("id", FLAMEGPU->getID());
          return flamegpu::ALIVE;
      }

    .. code-tab:: py Agent Python

      # Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageBruteForce" communication strategy
      @pyflamegpu.agent_function
      def outputdata(message_in: pyflamegpu.MessageNone, message_out: pyflamegpu.MessageBruteForce):
          # Set the "id" message variable to this agent's id (ID type is equivalent to an unsigned int within Python)
          pyflamegpu.message_out.setVariableUInt("id", pyflamegpu.getID())
          return pyflamegpu.ALIVE

      
Specialised message types have additional output values which must be provided. These are detailed in the following sub sections.

Bucket Messaging
================

Bucket messages each have an associated key, of type ``int``, as bucket messaging is a key-value store similar to a multimap.

When outputting bucket messages, the bucket index for the message must be set, using the :func:`setKey()<flamegpu::MessageBucket::Out::setKey>` method.

.. tabs::

    .. code-tab:: cuda Agent C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageBucket" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageBucket) {
          FLAMEGPU->message_out.setVariable<float>("x", FLAMEGPU->getVariable<float>("x"));
          // Set the bucket key for the message, to the agents "bucket" member variable
          FLAMEGPU->message_out.setKey(FLAMEGPU->getVariable<int>("bucket"));
          return flamegpu::ALIVE;
      }

    .. code-tab:: py Agent Python

      # Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageBucket" communication strategy
      @pyflamegpu.agent_function
      def outputdata(message_in: pyflamegpu.MessageNone, message_out: pyflamegpu.MessageBruteForce):
          pyflamegpu.message_out.setVariableFloat("x", pyflamegpu.getVariableFloat("x"))
          # Set the bucket key for the message, to the agents "bucket" member variable
          pyflamegpu.message_out.setKey(pyflamegpu.getVariableInt("bucket"))
          return pyflamegpu.ALIVE
      
Messages assigned keys outside of the bounds have undefined behaviour. If using ``FLAMEGPU_SEATBELTS`` error checking, an exception will be raised.

Spatial Messaging
=================

If you are using :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>` or :class:`MessageSpatial3D<flamegpu::MessageSpatial3D>` then your message type will automatically have ``float`` variables ``x``, ``y`` (and ``z`` for 3D) added to the message. These correspond to the message's spatial location and must be set in your agent function. 

.. note::

  If spatial messages will be accessed via the wrapped iterator, all messages must be output within the environment bounds defined for the message list. Accessing out of bounds messages with the wrapped iterator is undefined behaviour. 

.. tabs::

    .. code-tab:: cuda Agent C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageSpatial3D" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageSpatial3D) {
          // Set the required variables for spatial messaging
          FLAMEGPU->message_out.setVariable<float>("x", FLAMEGPU->getVariable<float>("x"));
          FLAMEGPU->message_out.setVariable<float>("y", FLAMEGPU->getVariable<float>("y"));
          FLAMEGPU->message_out.setVariable<float>("z", FLAMEGPU->getVariable<float>("z"));
          // Set any tertiary message variables
          FLAMEGPU->message_out.setVariable<int>("count", FLAMEGPU->getVariable<int>("count"));
          return flamegpu::ALIVE;
      }
      
    .. code-tab:: py Agent Python

      # Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageSpatial3D" communication strategy
      @pyflamegpu.agent_function
      def outputdata(message_in: pyflamegpu.MessageNone, message_out: pyflamegpu.MessageSpatial3D):
          # Set the required variables for spatial messaging
          pyflamegpu.message_out.setVariableFloat("x", pyflamegpu.getVariableFloat("x"))
          pyflamegpu.message_out.setVariableFloat("y", pyflamegpu.getVariableFloat("y"))
          pyflamegpu.message_out.setVariableFloat("z", pyflamegpu.getVariableFloat("z"))
          # Set any tertiary message variables
          pyflamegpu.message_out.setVariableInt("count", pyflamegpu.getVariableInt("count"))
          return pyflamegpu.ALIVE


Array Messaging
===============

If you are using :class:`MessageArray<flamegpu::MessageArray>`, :class:`MessageArray2D<flamegpu::MessageArray2D>` or :class:`MessageArray3D<flamegpu::MessageArray3D>` then you must specify the corresponding array index when outputting a message. It is important that only 1 agent writes a message to each index. If ``FLAMEGPU_SEATBELTS`` error-checking is enabled then multiple outputs to the same index will raise an exception.

.. tabs::

    .. code-tab:: cuda Agent C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageArray3D" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageArray3D) {
          // Set the index to store the array message
          FLAMEGPU->message_out.setIndex(FLAMEGPU->getVariable<unsigned int>("x"), FLAMEGPU->getVariable<unsigned int>("y"), FLAMEGPU->getVariable<unsigned int>("z"));
          // Set message variables
          FLAMEGPU->message_out.setVariable<float>("foo", FLAMEGPU->getVariable<float>("bar"));
          return flamegpu::ALIVE;
      }

    .. code-tab:: py Agent Python

      # Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageArray3D" communication strategy
      @pyflamegpu.agent_function
      def outputdata(message_in: pyflamegpu.MessageNone, message_out: pyflamegpu.MessageArray3D):
          # Set the index to store the array message
          pyflamegpu.message_out.setIndex(pyflamegpu.getVariableUInt("x"), pyflamegpu.getVariableUInt("y"), pyflamegpu.getVariableUInt("z"))
          # Set message variables
          pyflamegpu.message_out.setVariableFloat("foo", pyflamegpu.getVariableFloat("bar"))
          return pyflamegpu.ALIVE

Reading Messages
----------------

Reading a message is very similar to sending one. The second argument in the agent function definition specifies the input message communication strategy.

.. tabs::

    .. code-tab:: cuda Agent C++

      // Define an agent function, "inputdata" which has an input message using the "MessageBruteForce" communication strategy
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageBruteForce, flamegpu::MessageNone) {
          // Agent function code goes here
          ...
      }

    .. code-tab:: py Agent Python

      # Define an agent function, "inputdata" which has an input message using the "MessageBruteForce" communication strategy
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageBruteForce, message_out: pyflamegpu.MessageNone):
          # Agent function code goes here
          ...

To specify the type of message the function should input, the :func:`setMessageInput()<flamegpu::AgentFunctionDescription::setMessageInput>` method of the :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` object is used:

.. tabs::

    .. code-tab:: cpp C++
      
      // Specify that the "inputdata" agent function inputs a "location_message"
      inputdata.setMessageInput("location_message");

    .. code-tab:: py Python
      
      # Specify that the "inputdata" agent function inputs a "location_message"
      inputdata.setMessageInput("location_message")

With the input message type specified, the message list will be available in the agent function via ``FLAMEGPU->message_in``.

Different communication strategies have different methods of accessing their messages.

BruteForce Messaging
====================

All messages are accessed, so the whole message list is iterated over:

.. tabs::

    .. code-tab:: cuda Agent C++

      // Define an agent function, "inputdata" which has an input message using the "MessageBruteForce" communication strategy
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageBruteForce, flamegpu::MessageNone) {
          // For each message in the message list
          for (const auto& message : FLAMEGPU->message_in) {
              // Process the message's variables e.g.
              // const T var = message.getVariable<T>(...);
              ...
          }
          ...
      }

    .. code-tab:: py Agent Python

      # Define an agent function, "inputdata" which has an input message using the "MessageBruteForce" communication strategy
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageBruteForce, message_out: pyflamegpu.MessageNone):
          # For each message in the message list 
          for message in pyflamegpu.message_in:
              # Process the message's variables e.g.
              # var = message.getVariableInt(...)
              ...
          ...

Bucket Messaging
================

If you are using the Bucket messaging strategy, you will also need to supply the bucket key to access the messages from the specific bucket.

If an invalid bucket key is specified (based on the bounds provided when the messagelist was defined) no messages will be returned. If ``FLAMEGPU_SEATBELTS`` error checking is enabled, an exception will be raised.

.. tabs::

  .. code-tab:: cuda Agent C++

    // Define an agent function, "inputdata" which has an input message using the "MessageBucket" communication strategy
    FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageBucket, flamegpu::MessageNone) {
        // Get this agent's bucket variable
        const int x = FLAMEGPU->getVariable<int>("bucket");

        // For each message in the message list which was output to the requested bucket
        for (const auto& message : FLAMEGPU->message_in(bucket)) {
            // Process the message's variables e.g.
            // const T var = message.getVariable<T>(...);
            ...
        }
        ...
    }

  .. code-tab:: py Agent Python

      # Define an agent function, "inputdata" which has an input message using the "MessageBucket" communication strategy
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageBucket, message_out: pyflamegpu.MessageNone):
          # Get this agent's bucket variable
          x = pyflamegpu.getVariableInt("bucket");

          # For each message in the message list which was output to the requested bucket
          for message in pyflamegpu.message_in(bucket):
              # Process the message's variables e.g.
              # var = message.getVariableInt(...)
              ...
          ...

Spatial Messaging
=================
If you are using one of the spatial messaging strategies, you will need to supply the x, y (and z) coordinates of the agent, or the central location about which you wish to access messages.

Spatial messaging has two available iterators.

================================= =============================================== ==================================
Iterator                          Usage                                           API Docs
================================= =============================================== ==================================
Spatial Neighbourhood               ``FLAMEGPU->message_in(<arguments>)``           :func:`2D<flamegpu::MessageSpatial2D::In::operator()>`, :func:`3D<flamegpu::MessageSpatial3D::In::operator()>`
Wrapped Spatial Neighbourhood       ``FLAMEGPU->message_in.wrap(<arguments>)``      :func:`2D<flamegpu::MessageSpatial2D::In::wrap()>`, :func:`3D<flamegpu::MessageSpatial3D::In::wrap()>`
================================= =============================================== ==================================

The regular spatial neighbourhood does not wrap the environment bounds and is the easiest to use. Whereas the wrapped spatial neighbourhood will also return messages that would be in bounds were the environment tiled with itself. Correctly deploying a wrapped continuous space model can be challenging, as the modeller is responsible for ensuring that each agent remains within the environment by wrapping their location

Spatial messaging will return all messages within the radius specified at the model description time, however it can also return some messages which fall outside of this radius. So it is important that messages are distance checked to ensure they fall within the radius.


.. note::
  When spatial messages will be accessed via the wrapped iterator, all messages locations must be within the environment bounds defined for the message list. Accessing out of bounds messages with the wrapped iterator is undefined behaviour. 
  If using ``FLAMEGPU_SEATBELTS`` error checking an error may be raised whilst using the wrapped iterator if an out of bounds message is read.

.. tabs::

    .. code-tab:: cuda Agent C++ (Spatial)

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageSpatial3D" communication strategy
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
              const float separation = sqrt(x21*x21 + y21*y21 + z21*z21);
              if (separation < RADIUS && separation > 0.0f) {
                  // Process the message's variables e.g.
                  // const T var = message.getVariable<T>(...);
                  ...
              }
          }
          ...
      }

    .. code-tab:: py Agent Python (Spatial)

      # Define an agent function, "inputdata" which has an input message using the "MessageSpatial3D" communication strategy
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageSpatial3D, message_out: pyflamegpu.MessageNone):
          RADIUS = pyflamegpu.message_in.radius()
          # Get this agent's x, y, z variables
          x = pyflamegpu.getVariableFloat("x")
          y = pyflamegpu.getVariableFloat("y")
          z = pyflamegpu.getVariableFloat("z")
          
          # For each message in the message list which was output by a nearby agent
          for message in pyflamegpu.message_in(x, y, z):
              x2 = message.getVariableFloat("x")
              y2 = message.getVariableFloat("y")
              z2 = message.getVariableFloat("z")
              # Calculate the distance to check the message is in range
              x21 = x2 - x1
              y21 = y2 - y1
              z21 = z2 - z1
              separation = math.sqrt(x21*x21 + y21*y21 + z21*z21)
              if separation < RADIUS and separation > 0 :
                  # Process the message's variables e.g.
                  # var = message.getVariableInt(...)
                  ...
          ...
      
    .. code-tab:: cuda Agent C++ (Spatial Wrapped)

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageSpatial3D" communication strategy
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageSpatial3D, flamegpu::MessageNone) {
          const float RADIUS = FLAMEGPU->message_in.radius();
          // Get this agent's x, y, z variables
          const float x = FLAMEGPU->getVariable<float>("x");
          const float y = FLAMEGPU->getVariable<float>("y");
          const float z = FLAMEGPU->getVariable<float>("z");
          
          // For each message in the message list which was output by a nearby agent
          for (const auto& message : FLAMEGPU->message_in.wrap(x, y, z)) {
              const float x2 = message.getVirtualX();
              const float y2 = message.getVirtualY();
              const float z2 = message.getVirtualZ();
              // Calculate the distance to check the message is in range
              float x21 = x2 - x1;
              float y21 = y2 - y1;
              float z21 = z2 - z1;
              const float separation = sqrt(x21*x21 + y21*y21 + z21*z21);
              if (separation < RADIUS && separation > 0.0f) {
                  // Process the message's variables e.g.
                  // const T var = message.getVariable<T>(...);
                  ...
              }
          }
          ...
      }

    .. code-tab:: py Agent Python (Spatial Wrapped)

      # Define an agent function, "inputdata" which has an input message using the "MessageSpatial3D" communication strategy
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageSpatial3D, message_out: pyflamegpu.MessageNone):
          RADIUS = pyflamegpu.message_in.radius()
          # Get this agent's x, y, z variables
          x = pyflamegpu.getVariableFloat("x")
          y = pyflamegpu.getVariableFloat("y")
          z = pyflamegpu.getVariableFloat("z")
          
          # For each message in the message list which was output by a nearby agent
          for message in pyflamegpu.message_in. wrap(x, y, z):
              x2 = message.getVirtualX()
              y2 = message.getVirtualY()
              z2 = message.getVirtualZ()
              # Calculate the distance to check the message is in range
              x21 = x2 - x1
              y21 = y2 - y1
              z21 = z2 - z1
              separation = math.sqrt(x21*x21 + y21*y21 + z21*z21)
              if separation < RADIUS and separation > 0 :
                  # Process the message's variables e.g.
                  # var = message.getVariableInt(...)
                  ...
          ...
      

Array Messaging
===============
If you are using one of the array messaging strategies, there are several methods for accessing messages.

Messages can be accessed from a specific array index:

.. tabs::

    .. code-tab:: cuda Agent C++

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageArray3D" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray3D, flamegpu::MessageNone) {
          // Get this agent's x, y, z variables
          const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
          const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
          const unsigned int z = FLAMEGPU->getVariable<unsigned int>("z");
          // Select the message
          const auto message = FLAMEGPU->message_in.at(x, y, z);
          // Process the message's variables e.g.
          // const T var = message.getVariable<T>(...);
          ...
      }

    .. code-tab:: py Agent Python

      # Define an agent function, "inputdata" which has an input message using the "MessageArray3D" communication strategy
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageArray3D, message_out: pyflamegpu.MessageNone):
          # Get this agent's x, y, z variables
          x = pyflamegpu.getVariableFloat("x")
          y = pyflamegpu.getVariableFloat("y")
          z = pyflamegpu.getVariableFloat("z")
          # Select the message
          message = pyflamegpu.message_in.at(x, y, z)
          # Process the message's variables e.g.
          # var = message.getVariableInt(...)
          ...
      

Similar to spatial messaging, array messages provide several iterators for accessing a collection of messages localised to a specific location (normally a discrete agent's position). ``operator()`` (:func:`1D<flamegpu::MessageArray::In::operator()>`, :func:`2D<flamegpu::MessageArray2D::In::operator()>`, :func:`3D<flamegpu::MessageArray3D::In::operator()>`):


================================= =============================================== =============================================== ==================================
Iterator                          Agent C++ Usage                                 Agent Python Usage                              API Docs
================================= =============================================== =============================================== ==================================
Moore Neighbourhood               ``FLAMEGPU->message_in(<arguments>)``           ``message_in(<arguments>)``                     :func:`1D<flamegpu::MessageArray::In::operator()>`, :func:`2D<flamegpu::MessageArray2D::In::operator()>`, :func:`3D<flamegpu::MessageArray3D::In::operator()>`
Wrapped Moore Neighbourhood       ``FLAMEGPU->message_in.wrap(<arguments>)``      ``message_in.wrap(<arguments>)``                :func:`1D<flamegpu::MessageArray::In::wrap()>`, :func:`2D<flamegpu::MessageArray2D::In::wrap()>`, :func:`3D<flamegpu::MessageArray3D::In::wrap()>`
Von Neumann Neighbourhood         ``FLAMEGPU->message_in.vn(<arguments>)``        ``message_in.vn(<arguments>)``                  :func:`2D<flamegpu::MessageArray2D::In::vn()>`, :func:`3D<flamegpu::MessageArray3D::In::vn()>`
Wrapped Von Neumann Neighbourhood ``FLAMEGPU->message_in.vn_wrap(<arguments>)``   ``message_in.vn_wrap(<arguments>)``             :func:`2D<flamegpu::MessageArray2D::In::vn_wrap()>`, :func:`3D<flamegpu::MessageArray3D::In::vn_wrap()>`
================================= =============================================== =============================================== ==================================

The ``arguments`` for each of these methods are identical. They simply require the search origin to be specified, and optionally a radius (by default a radius of 1 is used). In all cases, the radius must be a positive integer. Hence taking the form ``(x_pos, y_pos, z_pos, radius=1)`` in 3D, 2D and 1D lack the ``z_pos`` and ``y_pos`` arguments. 

All array message iterators return messages over the exclusive neighbourhood of the selected type, hence the message at the search origin is never returned.

If you require the index of the current message within the array during iteration, the returned message objects provide the applicable ``getX()``, ``getY()`` and ``getZ()`` methods.

.. note::
  * For radii greater than 1, the Von Neumann iterator returns cells with a Manhattan distance ``<= R``.
  * The Von Neumann iterator does not support the 1 dimensional :class:`MessageArray<flamegpu::MessageArray>`, the Moore iterators or a simple for loop can be used for this case.
  * The Von Neumann iterator is generalised to support any radius. For this reason, if requiring radius 1, performance may be improved by accessing the 4 messages explicitly rather than using the iterator.


Example of a Moore neighbourhood iterator:

.. tabs::

    .. code-tab:: cuda Agent C++

      // Define an agent function, "inputdata" which accepts an input message using the "MessageArray3D" communication strategy and outputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray3D, flamegpu::MessageNone) {
          // Get this agent's x, y, z variables
          const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
          const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
          const unsigned int z = FLAMEGPU->getVariable<unsigned int>("z");
          // For each message in the exclusive Moore neighbourhood of radius 1
          for (const auto& message : FLAMEGPU->message_in(x, y, z)) {
            // Fetch the current array message's index
            // const unsigned int ix = message.getX();
            ...
            // Process the message's variables
            // const T var = message.getVariable<T>(...);
            ...
          }
          ...
      }

    .. code-tab:: py Agent Python

      # Define an agent function, "inputdata" which accepts an input message using the "MessageArray3D" communication strategy and outputs no messages
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageArray3D, message_out: pyflamegpu.MessageNone):
          # Get this agent's x, y, z variables
          x = pyflamegpu.getVariableFloat("x")
          y = pyflamegpu.getVariableFloat("y")
          z = pyflamegpu.getVariableFloat("z")
          # For each message in the exclusive Moore neighbourhood of radius 1
          for message in pyflamegpu.message_in(x, y, z):  
              # Fetch the current array message's index
              # ix = message.getX()
              ...     
              # Process the message's variables
              # var = message.getVariableInt(...)
              ...
          ...


Example of wrapped Moore neighbourhood iterator:

.. tabs::
      
    .. code-tab:: cuda Agent C++

      // Define an agent function, "inputdata" which accepts an input message using the "MessageArray2D" communication strategy and outputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray2D, flamegpu::MessageNone) {
        // Get this agent's x, y variables
        const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
        const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
        // For each message in the exclusive wrapped Moore neighbourhood of radius 2
        for (const auto& message : FLAMEGPU->message_in.wrap(x, y, 2)) {
          // Fetch the current array message's index
          // const unsigned int ix = message.getX();
          ...
          // Process the message's variables
          // const T var = message.getVariable<T>(...);
          ...
        }
        ...
      }


    .. code-tab:: py Agent Python

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageArray2D" communication strategy and outputs no messages
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageArray2D, message_out: pyflamegpu.MessageNone):
          # Get this agent's x, y, z variables
          x = pyflamegpu.getVariableFloat("x")
          y = pyflamegpu.getVariableFloat("y")
          # For each message in the exclusive wrapped Moore neighbourhood of radius 2
          for message in pyflamegpu.message_in.wrap(x, y, 2):
              # Fetch the current array message's index
              # ix = message.getX()
              ...
              # Process the message's variables
              # var = message.getVariableInt(...)
              ...
          ...
      
Example of a Von Neumann neighbourhood iterator:

.. tabs::
      
    .. code-tab:: cuda Agent C++

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageArray3D" communication strategy and outputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray3D, flamegpu::MessageNone) {
        // Get this agent's x, y, z variables
        const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
        const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
        const unsigned int z = FLAMEGPU->getVariable<unsigned int>("z");
        // For each message in the exclusive Von Neumann neighbourhood of radius 2
        for (const auto& message : FLAMEGPU->message_in.vn(x, y, z, 2)) {
          // Fetch the current array message's index
          // const unsigned int ix = message.getX();
          ... 
          // Process the message's variables          
          // const T var = message.getVariable<T>(...);
          ...
        }
        ...
      }


    .. code-tab:: py Agent Python

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageArray3D" communication strategy and outputs no messages
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageArray3D, message_out: pyflamegpu.MessageNone):
          # Get this agent's x, y, z variables
          x = pyflamegpu.getVariableFloat("x")
          y = pyflamegpu.getVariableFloat("y")
          z = pyflamegpu.getVariableFloat("z")
          # For each message in the exclusive Von Neumann neighbourhood of radius 2
          for message in pyflamegpu.message_in.vn(x, y, z, 2):
              # Fetch the current array message's index
              # ix = message.getX()
              ...
              # Process the message's variables
              # var = message.getVariableInt(...)
              ...
          ...
      

Example of a wrapped Von Neumann neighbourhood iterator:

.. tabs::
      
    .. code-tab:: cuda Agent C++

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageArray2D" communication strategy and outputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray2D, flamegpu::MessageNone) {
        // Get this agent's x, y, z variables
        const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
        const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
         // For each message in the exclusive wrapped Von Neumann neighbourhood of radius 1
        for (const auto& message : FLAMEGPU->message_in.vn_wrap(x, y)) {     
          // Fetch the current array message's index
          // const unsigned int ix = message.getX();
          ...   
          // Process the message's variables          
          // const T var = message.getVariable<T>(...);
          ...
        }
        ...
      }

    .. code-tab:: py Agent Python

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageArray2D" communication strategy and outputs no messages
      @pyflamegpu.agent_function
      def inputdata(message_in: pyflamegpu.MessageArray2D, message_out: pyflamegpu.MessageNone):
          # Get this agent's x, y, z variables
          x = pyflamegpu.getVariableFloat("x")
          y = pyflamegpu.getVariableFloat("y")
          # For each message in the exclusive wrapped Von Neumann neighbourhood of radius 1
          for message in pyflamegpu.message_in.vn_wrap(x, y):
              # Fetch the current array message's index
              # ix = message.getX()
              ...
              # Process the message's variables
              # var = message.getVariableInt(...)
              ...
          ...
     

Related Links
-------------

* User Guide Page: :ref:`Defining Messages (Communication)<Defining Messages>`
* User Guide Page: :ref:`What is FLAMEGPU_SEATBELTS?<FLAMEGPU_SEATBELTS>`
* Full API documentation for :class:`MessageBruteForce::In<flamegpu::MessageBruteForce::In>` & :class:`MessageBruteForce::Out<flamegpu::MessageBruteForce::Out>`
* Full API documentation for :class:`MessageBucket::In<flamegpu::MessageBucket::In>` & :class:`MessageBucket::Out<flamegpu::MessageBucket::Out>`
* Full API documentation for :class:`MessageSpatial2D::In<flamegpu::MessageSpatial2D::In>` & :class:`MessageSpatial2D::Out<flamegpu::MessageSpatial2D::Out>`
* Full API documentation for :class:`MessageSpatial3D::In<flamegpu::MessageSpatial3D::In>` & :class:`MessageSpatial3D::Out<flamegpu::MessageSpatial3D::Out>`
* Full API documentation for :class:`MessageArray::In<flamegpu::MessageArray::In>` & :class:`MessageArray::Out<flamegpu::MessageArray::Out>`
* Full API documentation for :class:`MessageArray2D::In<flamegpu::MessageArray2D::In>` & :class:`MessageArray2D::Out<flamegpu::MessageArray2D::Out>`
* Full API documentation for :class:`MessageArray3D::In<flamegpu::MessageArray3D::In>` & :class:`MessageArray3D::Out<flamegpu::MessageArray3D::Out>`
* Full API documentation for :class:`MessageNone::In<flamegpu::MessageNone::In>` & :class:`MessageNone::Out<flamegpu::MessageNone::Out>`
* Full API documentation for :class:`DeviceAPI<flamegpu::DeviceAPI>`
