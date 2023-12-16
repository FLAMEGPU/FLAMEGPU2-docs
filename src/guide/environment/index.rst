.. _defining environmental properties:

Environmental Properties
========================

The environment within a FLAME GPU model represents external properties which influence agent behaviour. 

Environment properties are read-only to agents, but may be updated by host functions.

Although initial values must be specified for environment properties, they can be overridden at model runtime with :ref:`various techniques<RunPlan>`.

Distinct from environment properties, FLAME GPU 2 introduces environment macro properties, these are intended for larger environment properties which may have upto four dimensions and can be updated by agents with a limited collection of atomic backed methods.

Accessing the EnvironmentDescription Object
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A model's :class:`EnvironmentDescription<flamegpu::EnvironmentDescription>` is retrieved from the :class:`ModelDescription<flamegpu::ModelDescription>` using :func:`Environment()<flamegpu::ModelDescription::Environment>`. This returns a reference to the model's :class:`EnvironmentDescription<flamegpu::EnvironmentDescription>`.

.. tabs::

  .. code-tab:: cpp C++

    // Define a new FLAME GPU model
    flamegpu::ModelDescription model("My Model");
    // Fetch the model's environment
    flamegpu::EnvironmentDescription env = model.Environment();

  .. code-tab:: py Python

    # Define a new FLAME GPU model
    model = pyflamegpu.ModelDescription("My Model")
    # Fetch the model's environment
    env = model.Environment()

.. note::
  
    As the :class:`EnvironmentDescription<flamegpu::EnvironmentDescription>` is owned by the :class:`ModelDescription<flamegpu::ModelDescription>`, it is returned as a reference, so it's type must take the form ``EnvironmentDescription&`` when using the C++ API.


Defining Properties
^^^^^^^^^^^^^^^^^^^

Environment properties are declared using the :func:`newProperty()<template<typename T> void flamegpu::EnvironmentDescription::newProperty(const std::string &, T, bool)>` methods.

The type, name and initial value of the property are all specified, array properties additionally require the length of the array to be specified.

For a full list of supported types, see :ref:`Supported Types<Supported Types>`.

.. tabs::

  .. code-tab:: cpp C++

    // Fetch the model's environment
    flamegpu::EnvironmentDescription env = model.Environment();
    // Declare an int property named 'foo', with a default value 12
    env.newProperty<int>("foo", 12);
    // Declare a float array property of length 3 named 'bar', with a default value [4.0, 5.0, 6.0]
    env.newProperty<float, 3>("bar", {4.0f, 5.0f, 6.0f});

  .. code-tab:: py Python

    # Fetch the model's environment
    env = model.Environment()
    # Declare an int property named 'foo', with a default value 12
    env.newPropertyInt("foo", 12)
    # Declare a float array property of length 3 named 'bar', with a default value [4.0, 5.0, 6.0]
    env.newPropertyArrayFloat("bar", [4.0, 5.0, 6.0])

.. note::
  Under the C/C++ API, the type and array length arguments are specified via template args. Under the Python API, the type is included in the method's identifier, and the array length is normally not required to be explicitly specified. This pattern is a consistent difference between the two APIs, however code in agent functions follow the C/C++ format.

.. note:
  
  Property names must not begin with ``_``, this is reserved for internal variables.


.. _Define Macro Environmental Properties:

Defining Macro Properties
^^^^^^^^^^^^^^^^^^^^^^^^^

FLAME GPU 2 introduces environment macro properties, these are intended for larger environment properties which may have upto four dimensions. Environment macro properties, unlike regular environment properties, can be updated by agents with a limited collection of atomic backed methods. However, they also have additional limitations; they always default to zero, cannot be logged, and cannot make use of experimental GLM support.

In contrast to regular environment properties, environment macro properties are declared using the :func:`newMacroProperty()<flamegpu::EnvironmentDescription::newMacroProperty>` method.

These may have upto 4 dimensions (unused dimensions if left unspecified, will default to length 1).

The type, dimensions and name of the macro property are all specified. The macro property will be initialised to a zero'd state, if a different initial value is required it should be populated by an :ref:`initialisation function<host macro property>`.

.. tabs::

  .. code-tab:: cpp C++

    // Fetch the model's environment
    flamegpu::EnvironmentDescription env = model.Environment();
    // Declare an int macro property named 'foobar', with array dimensions [5, 5, 5, 3]
    env.newMacroProperty<int, 5, 5, 5, 3>("foobar");

  .. code-tab:: py Python

    # Fetch the model's environment
    env = model.Environment()
    # Declare an int macro property named 'foobar', with array dimensions [5, 5, 5, 3]
    env.newMacroPropertyInt("foobar", 5, 5, 5, 3)
    

Defining a Directed Graph
^^^^^^^^^^^^^^^^^^^^^^^^^
FLAME GPU 2 introduces static directed graphs as a structure for storing organised data within the environment. The graph's structure can be defined within a host function, with properties attached to vertices and/or edges.

Directed graphs can then be traversed by agents which can iterate either input or output edges to a given vertex.

Environment directed graphs are currently static, therefore resizing the number of vertices or edges requires all properties to be reinitialised.

.. tabs::

  .. code-tab:: cpp C++

    // Fetch the model's environment
    flamegpu::EnvironmentDescription env = model.Environment();
    // Declare a new directed graph named 'fgraph'
    EnvironmentDirectedGraphDescription fgraph = model.Environment().newDirectedGraph("fgraph");
    // Attach an float[2] property 'bar' to vertices
    fgraph.newVertexProperty<float, 2>("bar");
    // Attach an int property 'foo' to edges
    fgraph.newEdgeProperty<int>("foo");
    
  .. code-tab:: py Python

    # Fetch the model's environment
    env = model.Environment()
    # Declare a new directed graph named 'fgraph'
    EnvironmentDirectedGraphDescription fgraph = model.Environment().newDirectedGraph("fgraph")
    # Attach an float[2] property 'bar' to vertices
    fgraph.newVertexPropertyArrayFloat("bar", 2)
    # Attach an int property 'foo' to edges
    fgraph.newEdgePropertyInt("foo")

Related Links
^^^^^^^^^^^^^

* User Guide Section: :ref:`Supported Types<Supported Types>`
* User Guide Page: :ref:`Accessing the Environment<device environment>` (Agent Functions)
* User Guide Page: :ref:`Accessing the Environment<host environment>` (Host Functions & Conditions)
* User Guide Page: :ref:`Overriding the Initial Environment<RunPlan>`
* Full API documentation for :class:`EnvironmentDescription<flamegpu::EnvironmentDescription>`
* Full API documentation for :class:`ModelDescription<flamegpu::ModelDescription>`
