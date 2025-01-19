.. _host environment:

Accessing the Environment
=========================

As detailed in the earlier chapter detailing the :ref:`defining of environmental properties<defining environmental properties>`, there are two types of environment property which can be interacted with in host functions. Unlike :ref:`agent functions<device environment>`, host functions have full mutable access to both forms of environment property.

The :class:`HostEnvironment<flamegpu::HostEnvironment>` instance can be accessed in host functions via ``FLAMEGPU->environment``.


Environment Properties
^^^^^^^^^^^^^^^^^^^^^^

Host functions can both read and update environment properties using :func:`setProperty()<flamegpu::HostEnvironment::setProperty>` and :func:`getProperty()<flamegpu::HostEnvironment::getProperty>` respectively.

Unlike agent functions, host functions are able to access environment property arrays in a single transaction, rather than individually accessing each element. Otherwise, the syntax matches that found in agent functions.

Environmental properties are accessed, using :class:`HostEnvironment<flamegpu::HostEnvironment>`, as follows:

.. tabs::

  .. code-tab:: cpp C++

    FLAMEGPU_HOST_FUNCTION(ExampleHostFn) {
        // Get the value of scalar environment property 'scalar_f' and store it in local variable 'scalar_f'
        float scalar_f = FLAMEGPU->environment.getProperty<float>("scalar_f");
        // Set the value of the scalar environment property 'scalar_f'
        FLAMEGPU->environment.setProperty<float>("scalar_f", scalar_f + 1.0f);
    
        // Get the value of array environment property 'array_i3' and store it in local variable 'array_i3'
        std::array<int, 3> array_i3 = FLAMEGPU->environment.getProperty<int, 3>("array_i3");
        // Set the value of the array environment property 'array_i3'
        FLAMEGPU->environment.setProperty<int, 3>("array_i3", std::array<int, 3>{0, 0, 0});
        
        // Get the value of the 2nd element of the array environment property 'array_u4'
        unsigned int array_u4_1 = FLAMEGPU->environment.getProperty<unsigned int>("array_u4", 1);
        // Set the value of the 3rd element of the array environment property 'array_u4'
        FLAMEGPU->environment.setProperty<unsigned int>("array_u4", 2, array_u4_1 + 2u);
    }

  .. code-tab:: py Python

    class ExampleHostFn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Get the value of scalar environment property 'scalar_f' and store it in local variable 'scalar_f'
        scalar_f = FLAMEGPU.environment.getPropertyFloat("scalar_f")
        # Set the value of the scalar environment property 'scalar_f'
        FLAMEGPU.environment.setPropertyFloat("scalar_f", scalar_f + 1.0)
    
        # Get the value of array environment property 'array_i3' and store it in local variable 'array_i3'
        array_i3 = FLAMEGPU.environment.getPropertyArrayInt("array_i3")
        # Set the value of the array environment property 'array_i3'
        FLAMEGPU.environment.setPropertyArrayInt("array_i3", [0, 0, 0])
        
        # Get the value of the 2nd element of the array environment property 'array_u4'
        array_u4_1 = FLAMEGPU.environment.getPropertyUInt("array_u4", 1)
        # Set the value of the 3rd element of the array environment property 'array_u4'
        FLAMEGPU.environment.setPropertyUInt("array_u4", 2, array_u4_1 + 2)
        
.. note:
  There are inconsistencies as to when an environment property array's length must be specified.
  It is only required here when accessing a whole array via the C++ API.
    
.. _host macro property:

Environment Macro Properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Similar to regular environment properties, macro environment properties can be read and updated within host functions.

Environmental macro properties can be read via the returned :class:`HostMacroProperty<flamegpu::HostMacroProperty>`, as follows:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called read_env_hostfn
    FLAMEGPU_HOST_FUNCTION(read_env_hostfn) {
        // Retrieve the environment macro property foo of type float
        const float foo = FLAMEGPU->environment.getMacroProperty<float>("foo");
        // Retrieve the environment macro property bar of type int array[3][3][3]
        auto bar = FLAMEGPU->environment.getMacroProperty<int, 3, 3, 3>("bar");
        const int bar_1_1_1 = bar[1][1][1];
    }

  .. code-tab:: python
  
    # Define an host function called read_env_hostfn
    class read_env_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Retrieve the environment macro property foo of type float
        foo = FLAMEGPU->environment.getMacroPropertyFloat("foo");
        # Retrieve the environment macro property bar of type int array[3][3][3]
        bar = FLAMEGPU.environment.getMacroPropertyInt("bar");
        bar_1_1_1 = bar[1][1][1];

Macro properties in host functions are designed to behave as closely to their representative data type as possible. So most assignment and arithmetic operations should behave as expected.

Python has several exceptions to this rule:

* The assignment operator is only available when it maps to ``__setitem__(index, val)`` (e.g. ``foo[0] = 10``)
* The increment/decrement operators are not available, as they cannot be overridden.

Below are several examples of how environment macro properties can be updated in host functions:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called write_env_hostfn
    FLAMEGPU_HOST_FUNCTION(write_env_hostfn) {
        // Retrieve the environment macro property foo of type float
        auto foo = FLAMEGPU->environment.getMacroProperty<float>("foo");
        // Retrieve the environment macro property bar of type int array[3][3][3]
        auto bar = FLAMEGPU->environment.getMacroProperty<int, 3, 3, 3>("bar");
        // Update some of the values
        foo = 12.0f;
        bar[0][0][0]+= 1;
        bar[0][1][0] = 5;
        ++bar[0][0][2];
    }

  .. code-tab:: python
  
    # Define an host function called write_env_hostfn
    class write_env_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
          # Retrieve the environment macro property foo of type float
          foo = FLAMEGPU->environment.getMacroPropertyFloat("foo");
          # Retrieve the environment macro property bar of type int array[3][3][3]
          bar = FLAMEGPU.environment.getMacroPropertyInt("bar");
          # Update some of the values
          # foo = 12.0; is not allowed
          foo.set(12.0);
          foo[0] = 12.0; # This is the same as calling set()
          bar[0][0][0]+= 1;
          bar[0][1][0] = 5;
          bar[0][0][2]+= 1; # Python does not allow the increment operator to be overridden
      
.. warning::
  Be careful when using :class:`HostMacroProperty<flamegpu::HostMacroProperty>` via the C++ API. When you retrieve an element e.g. ``bar[0][0][0]`` (from the example above), it is of type :class:`HostMacroProperty<flamegpu::HostMacroProperty>` not ``int``. Therefore you cannot pass it directly to functions which take generic arguments such as ``printf()``, as it will be interpreted incorrectly. You must either store it in a variable of the correct type which you instead pass, or explicitly cast it to the correct type when passing it e.g. ``(int)bar[0][0][0]`` or ``static_cast<int>(bar[0][0][0])``.
    
Macro Property File Input/Output
--------------------------------

Environment macro properties are best suited for large datasets. For this reason it may be necessary to initialise them from file. As such, the :class:`HostEnvironment<flamegpu::HostEnvironment>` provides methods for importing and exporting macro properties. Unlike model state export, these operate on a single property. The additional ``.bin`` (binary) file format is supported.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called macro_prop_io_hostfn
    FLAMEGPU_HOST_FUNCTION(macro_prop_io_hostfn) {
        // Export the macro property
        FLAMEGPU->environment.exportMacroProperty("macro_float_3_3_3", "out.bin");
        // Import a macro property
        FLAMEGPU->environment.importMacroProperty("macro_float_3_3_3", "in.json");
    }

  .. code-tab:: python
  
    # Define an host function called macro_prop_io_hostfn
    class macro_prop_io_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Export the macro property
        FLAMEGPU.environment.exportMacroProperty("macro_float_3_3_3", "out.bin");
        # Import a macro property
        FLAMEGPU.environment.importMacroProperty("macro_float_3_3_3", "in.json");
    
Environment Directed Graph
^^^^^^^^^^^^^^^^^^^^^^^^^^

The environment directed graph can be initialised within host functions, defining the connectivity and initialising any properties stored within.

The host API allows vertices and edges to be managed via a map/dictionary interface, where the ID is used to access a vertex, or source and destination vertex IDs to access an edge.

Vertex IDs are unsigned integers, however the value `0` is reserved so cannot be assigned. Vertex IDs are not required to be contiguous, however they are stored sparsely such that two vertices with IDs `1` and `1000001` will require an index of length `1000000`. It may be possible to run out of memory if IDs are too sparsely distributed.

For convenience vertices and edges, including those which have not yet been initialised, can also be iterated and accessed via their index within the allocated buffer. However, it should be noted that these indices are not stable, and may change between host functions when the graph is rebuilt.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called directed_graph_hostfn
    FLAMEGPU_HOST_FUNCTION(directed_graph_hostfn) {
        // Fetch a handle to the directed graph
        HostEnvironmentDirectedGraph fgraph = FLAMEGPU->environment.getDirectedGraph("fgraph");
        // Declare the number of vertices and edges
        fgraph.setVertexCount(5);
        fgraph.setEdgeCount(5);
        // Initialise the vertices by ID
        HostEnvironmentDirectedGraph::VertexMap vertices = graph.vertices();
        for (int i = 1; i <= 5; ++i) {
            // Create (or fetch) vertex with ID i
            HostEnvironmentDirectedGraph::VertexMap::Vertex vertex = vertices[i];
            vertex.setProperty<float, 2>("bar", {0.0f, 10.0f});
        }
        // Access a vertex by index
        vertices.atIndex(0).setProperty<float>("i", 15);
        // Initialise the edges
        HostEnvironmentDirectedGraph::EdgeMap edges = graph.edges();
        for (int i = 1; i <= 5; ++i) {
            // Create (or fetch) edge with specified source/dest vertex IDs
            HostEnvironmentDirectedGraph::EdgeMap::Edge edge = edges[{i, ((i + 1)%5) + 1}];
            edge.setProperty<int>("foo", 12);
        }
        // Iterate edges
        for (auto &edge : edges) {
            edge.setProperty<int>("foobar", 21);
        }
    }

  .. code-tab:: python
  
    # Define an host function called directed_graph_hostfn
    class directed_graph_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Fetch a handle to the directed graph
        fgraph = FLAMEGPU->environment.getDirectedGraph("fgraph")
        # Declare the number of vertices and edges
        fgraph.setVertexCount(5)
        fgraph.setEdgeCount(5)
        # Initialise the vertices by ID
        vertices = graph.vertices()
        for i in range(1, 6):
            # Create (or fetch) vertex with ID i
            vertex = vertices[i]
            vertex.setPropertyArrayFloat("bar", [0, 10])
        # Access a vertex by index
        vertices.atIndex(0).setPropertyFloat("i", 15)
        # Initialise the edges
        edges = graph.edges()
        for i in range(1, 6):
            # Create (or fetch) edge with specified source/dest vertex IDs
            edge = edges[i, ((i + 1)%5) + 1]
            edge.setPropertyInt("foo", 12)
        # Iterate edges
        for edge in edges:
            edge.setPropertyInt("foobar", 21)

.. note:

  If :func:`setVertexCount()<flamegpu::HostEnvironmentDirectedGraph::setVertexCount>` or :func:`setEdgeCount()<flamegpu::HostEnvironmentDirectedGraph::setEdgeCount>` is called, all data currently in the associated vertex/edge buffers will be lost.

.. _directed graph io:

Directed Graph File Input/Output
--------------------------------
:class:`HostEnvironmentDirectedGraph<flamegpu::HostEnvironmentDirectedGraph>` provides :func:`importGraph()<flamegpu::HostEnvironmentDirectedGraph::importGraph>` and :func:`exportGraph()<flamegpu::HostEnvironmentDirectedGraph::exportGraph>` to import and export the graph respectively using a common JSON format.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called directed_graph_hostfn
    FLAMEGPU_HOST_FUNCTION(directed_graph_hostfn) {
        // Fetch a handle to the directed graph
        HostEnvironmentDirectedGraph fgraph = FLAMEGPU->environment.getDirectedGraph("fgraph");
        // Export the graph
        fgraph.exportGraph("out.json");
        // Import a different graph
        fgraph.importGraph("in.json");
    }

  .. code-tab:: python
  
    # Define an host function called directed_graph_hostfn
    class directed_graph_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Fetch a handle to the directed graph
        fgraph = FLAMEGPU->environment.getDirectedGraph("fgraph")
        # Export the graph
        fgraph.exportGraph("out.json");
        # Import a different graph
        fgraph.importGraph("in.json");
        
An example of this format is shown below:

.. tabs::

  .. code-tab:: json
  
    {
        "nodes": [
            {
                "id": "1",
                "bar": [
                    12.0,
                    22.0
                ]
            },
            {
                "id": "2",
                "bar": [
                    13.0,
                    23.0
                ]
            }
        ],
        "links": [
            {
                "source": "1",
                "target": "2",
                "foo": 21
            },
            {
                "source": "2",
                "target": "1",
                "foo": 22
            }
        ]
    }

.. note:

  When importing a graph, if string IDs do not map directly to integers they will automatically be replaced and remapped.

Related Links
^^^^^^^^^^^^^

* User Guide Page: :ref:`Defining Environmental Properties<defining environmental properties>`
* User Guide Page: :ref:`Agent Functions: Accessing the Environment<device environment>`
* Full API documentation for :class:`HostEnvironment<flamegpu::HostEnvironment>`
* Full API documentation for :class:`HostMacroProperty<flamegpu::HostMacroProperty>`