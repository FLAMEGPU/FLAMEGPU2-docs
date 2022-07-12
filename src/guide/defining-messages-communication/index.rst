.. _Defining Messages:

Defining Messages (Communication)
=================================

Communication between agents in FLAME GPU is handled through messages. Messages contain variables which are used to transmit information between agents. Agents may output a single message from an agent function, subsequent agent functions can then be configured to access messages of the same type according to the message's communication strategy.


Communication Strategies
^^^^^^^^^^^^^^^^^^^^^^^^

Defining a message type in FLAME GPU requires selection of a communication strategy and specification of the data the message will contain. FLAME GPU 2 comes with several built-in communication strategies, described below. It can also be extended to support bespoke messaging types. For guidance on this see the header file ``include/flamegpu/runtime/messaging.h``. For each message type, the communication strategy defines how the messages will be accessed.

============== ======================================================= ==========================================================
Strategy       Symbol                                                  Description
============== ======================================================= ==========================================================
Brute Force    :class:`MessageBruteForce<flamegpu::MessageBruteForce>` Access all messages
Bucket         :class:`MessageBucket<flamegpu::MessageBucket>`         Access all messages with a specified integer key
Spatial 2D     :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>`   Access all messages within a radius in 2D continuous space
Spatial 3D     :class:`MessageSpatial3D<flamegpu::MessageSpatial3D>`   Access all messages within a radius in 3D continuous space
Array 1D       :class:`MessageArray<flamegpu::MessageArray>`           Directly access messages via a 1 dimensional array
Array 2D       :class:`MessageArray2D<flamegpu::MessageArray2D>`       Directly access messages via a 2 dimensional array
Array 3D       :class:`MessageArray3D<flamegpu::MessageArray3D>`       Directly access messages via a 3 dimensional array
============== ======================================================= ==========================================================

Defining a New Message Type
^^^^^^^^^^^^^^^^^^^^^^^^^^^

A new message type can be defined using one of the above symbols, two examples are shown below:

.. tabs::

    .. code-tab:: cpp C++

      // Create a new message called "brute_force" which uses the brute force communication strategy
      flamegpu::MessageBruteForce::Description &bf_message = model.newMessage<flamegpu::MessageBruteForce>("brute_force");
      // Create a new message called "spatial_3D" which uses the Spatial 3D communication strategy
      flamegpu::MessageSpatial3D::Description &s3d_message = model.newMessage<flamegpu::MessageSpatial3D>("spatial_3D");

    .. code-tab:: py Python
      
      # Create a new message called "brute_force" which uses the brute force communication strategy
      bf_message = model.newMessageBruteForce("brute_force")
      # Create a new message called "spatial_3D" which uses the Spatial 3D communication strategy
      s3d_message = model.newMessageSpatial3D("spatial_3D")
      
      
Variables that the message should contain can then be defined using the ``newVariable`` method of the message's respective ``Description`` object.
This function works similarly to that previously introduced for defining agent variables, however message variables cannot have default values specified:

.. tabs::

    .. code-tab:: cpp C++
        
      // Add a variable of type "int" with name "foo" to the "bf_message" type
      bf_message.newVariable<int>("foo");
      // Add a variable of type "float" with name "bar" to the "bf_message" type
      bf_message.newVariable<float>("bar");

    .. code-tab:: py Python
      
      # Add a variable of type "int" with name "foo" to the "bf_message" type
      bf_message.newVariableInt("foo")
      # Add a variable of type "float" with name "bar" to the "bf_message" type
      bf_message.newVariableFloat("bar")

.. note::
  
  Variable names must not begin with ``_``, this is reserved for internal variables.



Brute Force Specialisation
--------------------------
:class:`MessageBruteForce<flamegpu::MessageBruteForce>` is the simplest message type to utilise, as such :class:`MessageBruteForce::Description<flamegpu::MessageBruteForce::Description>` does not have any additional options which must be configured. 
However for any large agent population, having all-to-all communication is prohibitively expensive so using better suited message specialisations is recommended where feasible.

Bucket Specialisation
----------------------

Bucket messages work similarly to the data structure known as a multimap. Messages are assigned an integer key (in a predefined range) when output. When an agent requests messages, it then specifies a key, all the messages assigned this key are returned.

When defining a bucket message, a :class:`MessageBucket::Description<flamegpu::MessageBucket::Description>` is returned.

The Bucket keys are a sequential set of integers, between a configurable lower and upper bound, using the :func:`setUpperBound()<flamegpu::MessageBucket::Description::setUpperBound>` and  :func:`setLowerBound()<flamegpu::MessageBucket::Description::setLowerBound>` or :func:`setBounds()<flamegpu::MessageBucket::Description::setBounds>` methods on the :class:`BucketMessage::Description<flamegpu::MessageBucket::Description>` class.

.. tabs::
    
  .. code-tab:: cpp C++

    // Set an upper bound of bucket keys to 12 for the "message" MessageBucket::Description instance.
    message.setUpperBound(12);
    // Set the lower bound to 2, this will default to 0 if not provided
    message.setLowerBound(2);

    // Or set them both at the same time
    message.setBounds(2, 12);

  .. code-tab:: py Python
    
    # Set an upper bound of bucket keys to 12 for the "message" MessageBucket::Description instance.
    message.setUpperBound(12)
    # Set the lower bound to 2, this will default to 0 if not provided
    message.setLowerBound(2)

    # Or set them both at the same time
    message.setBounds(2, 12)


Bucket messages are automatically assigned a hidden ``int`` variable ``_key`` representing the key of a given message, this cannot be accessed via regular variable methods and has dedicated methods which are introduced in the relevant later sections regarding message input and output.


Spatial Specialisation
----------------------

Spatial messages operate by decomposing the 2D or 3D environment into a discrete grid of bins. Messages may be emitted outside the bounds of the specified 3D environment, however significant quantities of messages output out of bounds will harm performance.
When an agent requests messages, it then specifies a search origin. Messages from bins within the interaction radius of the search origin are then returned. As such, it's possible for messages outside of the interaction radius to be returned, and distances to each message must be calculated by the agent.

The discrete grid which support spatial messaging is abstracted from users, when defining spatial messages either a :class:`MessageSpatial2D::Description<flamegpu::MessageSpatial2D::Description>` or :class:`MessageSpatial3D::Description<flamegpu::MessageSpatial3D::Description>` will be returned. This is used to configure the environment bounds and interaction radius.

The following is an example of configuring the specialisations for a :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>` message:

.. tabs::
    
  .. code-tab:: cpp C++

    // Specify the minimum coordinate of the environment as (0.0, 0.0)
    message.setMin(0.0f, 0.0f);
    // Specify the maximum coordinate of the environment as (100.0, 100.0)
    message.setMax(100.0f, 100.0f);
    // Specify the interaction radius as 1.0
    message.setRadius(1.0f);

  .. code-tab:: py Python    

    # Specify the minimum coordinate of the environment as (0.0, 0.0)
    message.setMin(0, 0)
    # Specify the maximum coordinate of the environment as (100.0, 100.0)
    message.setMax(100, 100)
    # Specify the interaction radius as 1.0
    message.setRadius(1)
    
The :func:`setMin()<flamegpu::MessageSpatial3D::Description::setMin>` and :func:`setMax()<flamegpu::MessageSpatial3D::Description::setMax>` of :class:`MessageSpatial3D::Description<flamegpu::MessageSpatial3D::Description>` instead take 3 arguments.

Spatial messages are automatically assigned ``float`` location variables with the names ``x``, ``y`` (and ``z``). These are used by FLAME GPU internally to sort messages and handle localised accesses, so must be used when outputting messages.

Array Specialisation
--------------------

Array messages work similarly to an array. When an array message type is defined, it's dimensions must be specified. Agents can then output a message to a single unique element within the array.

Multiple agents must not output messages to the same element, if ``SEATBELTS`` error checking is enabled this will be detected and an exception raised.

Elements which do not have a message output will return ``0`` for all variables, similar to if an agent does not set all variables of a message it outputs.

when defining spatial messages either a :class:`MessageArray::Description<flamegpu::MessageArray::Description>`, :class:`MessageArray2D::Description<flamegpu::MessageArray2D::Description>` or :class:`MessageArray3D::Description<flamegpu::MessageArray3D::Description>` will be returned. This should be used to configure dimensions.

The following is an example of configuring the specialisations for each of the 3 array message types:

.. tabs::
    
  .. code-tab:: cpp C++

    // Specify the length of the MessageArray as [100000]
    message_1D.setLength(100000);
    
    // Specify the dimensions of the MessageArray2D as [100][100]
    message_2D.setDimensions(100, 100);
    
    // Specify the dimensions of the MessageArray3D as [50][50][10]
    message_3D.setDimensions(50, 50, 10);

  .. code-tab:: py Python    

    # Specify the length of the MessageArray as [100000]
    message_1D.setLength(100000)
    
    # Specify the dimensions of the MessageArray2D as [100][100]
    message_2D.setDimensions(100, 100)
    
    # Specify the dimensions of the MessageArray3D as [50][50][10]
    message_3D.setDimensions(50, 50, 10)
    

Array messages are all automatically assigned a hidden ``int`` variable ``___INDEX`` representing the index assigned to an output message, this cannot be accessed via regular variable methods and has a dedicated method which is introduced in the :ref:`later section regarding message output<Sending Messages>`.


Related Links
^^^^^^^^^^^^^

* User Guide Page: :ref:`Agent Communication<Device Agent Communication>`
* User Guide Page: :ref:`What is SEATBELTS?<SEATBELTS>`
* Full API documentation for :class:`MessageBruteForce::Description<flamegpu::MessageBruteForce::Description>`
* Full API documentation for :class:`MessageBucket::Description<flamegpu::MessageBucket::Description>`
* Full API documentation for :class:`MessageSpatial2D::Description<flamegpu::MessageSpatial2D::Description>`
* Full API documentation for :class:`MessageSpatial3D::Description<flamegpu::MessageSpatial3D::Description>`
* Full API documentation for :class:`MessageArray::Description<flamegpu::MessageArray::Description>`
* Full API documentation for :class:`MessageArray2D::Description<flamegpu::MessageArray2D::Description>`
* Full API documentation for :class:`MessageArray3D::Description<flamegpu::MessageArray3D::Description>`
* Full API documentation for :class:`ModelDescription<flamegpu::ModelDescription>`