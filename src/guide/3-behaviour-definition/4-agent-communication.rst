Agent Communication
===================

Communication between agents in FLAMEGPU2 is handled through messages. Messages contain variables which are used to transmit information between agents.

Defining Messages
-----------------
Defining a message type in FLAMEGPU2 requires selection of a communication strategy and specification of the data the message will contain. FLAMEGPU2 comes 
with several built-in communication strategies, described below. It can also be extended to support bespoke messaging types. For guidance on this see the file 
``include/flamegpu/runtime/messaging.h``. For each message type, the communication strategy defines how the messages will be accessed.

============== ======================================================= ======================================================
Type           Symbol                                                  Description
============== ======================================================= ======================================================
Brute Force    :class:`MessageBruteForce<flamegpu::MessageBruteForce>` Access all messages
Bucket         :class:`MessageBucket<flamegpu::MessageBucket>`         Access all messages with a specified integer key
Spatial 2D     :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>`   Access all messages within a radius in 2D
Spatial 3D     :class:`MessageSpatial3D<flamegpu::MessageSpatial3D>`   Access all messages within a radius in 3D
Array 1D       :class:`MessageArray<flamegpu::MessageArray>`           Directly access messages via a 1 dimensional array
Array 2D       :class:`MessageArray2D<flamegpu::MessageArray2D>`       Directly access messages via a 2 dimensional array
Array 3D       :class:`MessageArray3D<flamegpu::MessageArray3D>`       Directly access messages via a 3 dimensional array
============== ======================================================= ======================================================


A new message type can be defined using one of the above symbols:

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

To specify the type of message the function should output, the :func:`setMessageOutput()<flamegpu::AgentFunctionDescription::setMessageOutput>` method of the :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` object is used:

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

**Bucket Messaging**
Bucket Messages each have an associated bucket index, of an integer type such as ``int`` or ``unsigned int``.
The Bucket indices are a sequential set of integers, between a configurable lower and upper bound, using the :func:`setUpperBound()<flamegpu::MessageBucket::Description::setUpperBound>`, :func:`setLowerBound()<flamegpu::MessageBucket::Description::setLowerBound>` and :func:`setBounds()<flamegpu::MessageBucket::Description::setBounds>` methods on the :class:`BucketMessage::Description<flamegpu::MessageBucket::Description>` class.

.. tabs::
    
  .. code-tab:: cuda CUDA C++

    // Set an upper bound of bucket indices to 12 for the "message" MessageBucket::Description instance.
    message.setUpperBound(12);
    // Set the lower bound to 2, this will default to 0 if not provided
    message.setLowerBound(2);

    // Or set them both at the same time
    message.setBounds(2, 12);

  .. code-tab:: python
    
    # Set an upper bound of bucket indices to 12 for the "message" MessageBucket::Description instance.
    message.setUpperBound(12);
    # Set the lower bound to 2, this will default to 0 if not provided
    message.setLowerBound(2);

    # Or set them both at the same time
    message.setBounds(2, 12);

When outputting bucket messages, the bucket index for the message must be set, using the :func:`setKey()<flamegpu::MessageBucket::Out::setKey>` method.

.. tabs::

    .. code-tab:: cuda CUDA C++

      // Define an agent function, "outputdata" which has no input messages and outputs a message using the "MessageBucket" communication strategy
      FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageBucket) {
        FLAMEGPU->message_out.setVariable<float>("x", FLAMEGPU->getVariable<float>("x"));
        // Set the bucket key for the message, to the agents "bucket" member variable
        FLAMEGPU->message_out.setKey(FLAMEGPU->getVariable<int>("bucket"));
        return flamegpu::ALIVE;
      }

**Spatial Messaging**
If you are using :class:`MessageSpatial2D` or :class:`MessageSpatial3D` then your message type will automatically have ``float`` variables ``x``, ``y`` (and ``z`` for 3D) added to the message. These correspond to the message's spatial location and must be set in your agent function. 

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

You must also specify the interaction radius via the ``MessageDescription`` (:class:`2D<flamegpu::MessageSpatial2D::Description>`, :class:`3D<flamegpu::MessageSpatial3D::Description>`) object:

.. tabs::
    
    .. code-tab:: cuda CUDA C++

      // Specify that the "outputdata" agent function has an interaction radius of 2.0f
      outputdata.setMessageOutput(2.0f);
  
    .. code-tab:: python
      
      # Specify that the "outputdata" agent function has an interaction radius of 2.0
      outputdata.setRadius(2.0)

      
**Array Messaging**
If you are using :class:`MessageArray<flamegpu::MessageArray>`, :class:`MessageArray2D<flamegpu::MessageArray2D>` or :class:`MessageArray3D<flamegpu::MessageArray3D>` then you must specify the corresponding array index when outputting a message. It is important that only 1 agent writes a message to each index (if `SEATBELTS` is enabled then multiple outputs to the same index will raise an exception).

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

The input message type is specified using the :func:`setMessageInput()<flamegpu::AgentFunctionDescription::setMessageInput>` method of the :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` object:


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

**Bucket Messaging**

If you are using the Bucket messaging strategy, you will also need to supply the bucket index/key to access the messages from the specific bucket.
If an invalid bucket index is provided (based on the bounds), then either a device exception will be thrown if available (`SEATBELTS=ON<SEATBELTS>`), or no messages will be returned.

.. tabs::

  .. code-tab:: cuda CUDA C++

    // Define an agent function, "inputdata" which has accepts an input message using the "MessageBucket" communication strategy and inputs no messages
    FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageBucket, flamegpu::MessageNone) {
      // Get this agent's bucket variable
      const int x = FLAMEGPU->getVariable<int>("bucket");

      // For each message in the message list which was output to the requested bucket
      for (const auto& message : FLAMEGPU->message_in(bucket)) {
        // const T var = message.getVariable<T>(...);
      }

      return flamegpu::ALIVE;
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
      

Similar to spatial messaging, array messages provide several iterators for accessing a collection of messages localised to a specific location (normally a discrete agent's position).``operator()`` (:func:`1D<flamegpu::MessageArray::In::operator()>`, :func:`2D<flamegpu::MessageArray2D::In::operator()>`, :func:`3D<flamegpu::MessageArray3D::In::operator()>`):


================================= =============================================== ==================================
Iterator                          Usage                                           API Docs
================================= =============================================== ==================================
Moore Neighbourhood               ``FLAMEGPU->message_in(<arguments>)``           :func:`1D<flamegpu::MessageArray::In::operator()>`, :func:`2D<flamegpu::MessageArray2D::In::operator()>`, :func:`3D<flamegpu::MessageArray3D::In::operator()>`
Wrapped Moore Neighbourhood       ``FLAMEGPU->message_in.wrap(<arguments>)``      :func:`1D<flamegpu::MessageArray::In::wrap()>`, :func:`2D<flamegpu::MessageArray2D::In::wrap()>`, :func:`3D<flamegpu::MessageArray3D::In::wrap()>`
Von Neumann Neighbourhood         ``FLAMEGPU->message_in.vn(<arguments>)``        :func:`2D<flamegpu::MessageArray2D::In::vn()>`, :func:`3D<flamegpu::MessageArray3D::In::vn()>`
Wrapped Von Neumann Neighbourhood ``FLAMEGPU->message_in.vn_wrap(<arguments>)``   :func:`2D<flamegpu::MessageArray2D::In::vn_wrap()>`, :func:`3D<flamegpu::MessageArray3D::In::vn_wrap()>`
================================= =============================================== ==================================

The *arguments* for each of these methods are identical. They simply require the search origin to be specified, and optionally a radius (by default a radius of 1 is used). In all cases, the radius must be a positive integer. Hence taking the form ``(x_pos, y_pos, z_pos, radius=1)`` in 3D, 2D and 1D lack the ``z_pos`` and ``y_pos`` arguments. 

Wrapped iterators will return messages over the exclusive neighbourhood of the selected type, hence the message at the search origin is not returned.

.. note::
  * For radii greater than 1, the Von Neumann iterator returns cells with a Manhattan distance ``<= R``.
  * The Von Neumann iterator does not support the 1 dimensional :class:`MessageArray<flamegpu::MessageArray>`, the Moore iterators or a simple for loop can be used for this case.
  * The Von Neumann iterator is generalised to support any radius. For this reason, if requiring radius 1, performance may be improved by accessing the 4 messages explicitly rather than using the iterator.


Below are some examples using each of the iterators:

.. tabs::

    .. code-tab:: cuda Moore

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
      
    .. code-tab:: cuda Wrapped Moore

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageSpatial2D" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray2D, flamegpu::MessageNone) {
        // Get this agent's x, y variables
        const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
        const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
         // For each message in the exclusive wrapped Moore neighbourhood of radius 2
        for (const auto& message : FLAMEGPU->message_in.wrap(x, y, 2)) {        
          // Process the message's variables
          int idFromMessage = message->getVariable<int>("id");
        }
        return flamegpu::ALIVE;
      }
      
    .. code-tab:: cuda Von Neumann

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageSpatial3D" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray3D, flamegpu::MessageNone) {
        // Get this agent's x, y, z variables
        const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
        const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
        const unsigned int z = FLAMEGPU->getVariable<unsigned int>("z");
         // For each message in the exclusive Von Neumann neighbourhood of radius 2
        for (const auto& message : FLAMEGPU->message_in.vn(x, y, z, 2)) {        
          // Process the message's variables
          int idFromMessage = message->getVariable<int>("id");
        }
        return flamegpu::ALIVE;
      }
      
    .. code-tab:: cuda Wrapped Von Neumann

      // Define an agent function, "inputdata" which has accepts an input message using the "MessageSpatial2D" communication strategy and inputs no messages
      FLAMEGPU_AGENT_FUNCTION(inputdata, flamegpu::MessageArray2D, flamegpu::MessageNone) {
        // Get this agent's x, y, z variables
        const unsigned int x = FLAMEGPU->getVariable<unsigned int>("x");
        const unsigned int y = FLAMEGPU->getVariable<unsigned int>("y");
         // For each message in the exclusive wrapped Von Neumann neighbourhood of radius 1
        for (const auto& message : FLAMEGPU->message_in.vn_wrap(x, y)) {        
          // Process the message's variables
          int idFromMessage = message->getVariable<int>("id");
        }
        return flamegpu::ALIVE;
      }
      
More Info 
---------


* Full API documentation for :class:`MessageBruteForce<flamegpu::MessageBruteForce>`, :class:`MessageBruteForce::Description<flamegpu::MessageBruteForce::Description>`, :class:`MessageBruteForce::Out<flamegpu::MessageBruteForce::Out>`, :class:`MessageBruteForce::In<flamegpu::MessageBruteForce::In>`
* Full API documentation for :class:`MessageBucket<flamegpu::MessageBucket>` :class:`MessageBucket::Description<flamegpu::MessageBucket::Description>`, :class:`MessageBucket::Out<flamegpu::MessageBucket::Out>`, :class:`MessageBucket::In<flamegpu::MessageBucket::In>`
* Full API documentation for :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>` :class:`MessageSpatial2D::Description<flamegpu::MessageSpatial2D::Description>`, :class:`MessageSpatial2D::Out<flamegpu::MessageSpatial2D::Out>`, :class:`MessageSpatial2D::In<flamegpu::MessageSpatial2D::In>`
* Full API documentation for :class:`MessageSpatial3D<flamegpu::MessageSpatial3D>` :class:`MessageSpatial3D::Description<flamegpu::MessageSpatial3D::Description>`, :class:`MessageSpatial3D::Out<flamegpu::MessageSpatial3D::Out>`, :class:`MessageSpatial3D::In<flamegpu::MessageSpatial3D::In>`
* Full API documentation for :class:`MessageArray<flamegpu::MessageArray>` :class:`MessageArray::Description<flamegpu::MessageArray::Description>`, :class:`MessageArray::Out<flamegpu::MessageArray::Out>`, :class:`MessageArray::In<flamegpu::MessageArray::In>`
* Full API documentation for :class:`MessageArray2D<flamegpu::MessageArray2D>` :class:`MessageArray2D::Description<flamegpu::MessageArray2D::Description>`, :class:`MessageArray2D::Out<flamegpu::MessageArray2D::Out>`, :class:`MessageArray2D::In<flamegpu::MessageArray2D::In>`
* Full API documentation for :class:`MessageArray3D<flamegpu::MessageArray3D>` :class:`MessageArray3D::Description<flamegpu::MessageArray3D::Description>`, :class:`MessageArray3D::Out<flamegpu::MessageArray3D::Out>`, :class:`MessageArray3D::In<flamegpu::MessageArray3D::In>`
* Examples which demonstrate brute force messaging

  * Boids Brute Force (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/boids_bruteforce/src/main.cu>`__)
  * Circles Brute Force (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/circles_bruteforce/src/main.cu>`__)
  
* Examples which demonstrate spatial 3D messaging

  * Boids Spatial 3D (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/boids_spatial3D/src/main.cu>`__)
  * Boids Spatial 3D (Python) (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/swig_boids_spatial3D/boids_spatial3D.py>`__)
  * Circles Spatial 3D (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/circles_spatial3D/src/main.cu>`__)
  
* Examples which demonstrate array 2D messaging

  * Game of Life (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/game_of_life/src/main.cu>`__)
  * Sugarscape (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/sugarscape/src/main.cu>`__)
  * Diffusion (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/diffusion/src/main.cu>`__)
