Defining Execution Order
========================

Once the agents and behaviours of your model have been specified, you must define the dependencies present in the model. 
Specifying a dependency, e.g. *a depends on b* ensures that function a will not run until function b has completed. This
can be used to define the order you want behaviours to take place in, and to ensure that a function which outputs messages
is complete before another function attempts to read them.

Specifying Dependencies
-----------------------

Dependencies are specified between ``AgentFunctionDescription``, ``Submodel`` and ``HostFunctionDescription`` objects. 
These are specified using the ``dependsOn`` method.

.. tabs::

  .. code-tab:: python

    # Declare that agent_fn2 depends on agent_fn1
    agent_fn2.dependsOn(agent_fn1)

    # Declare that host_fn1 depends on agent_fn2
    host_fn1.dependsOn(agent_fn2)

  .. code-tab:: cpp

    // Declare that agent_fn2 depends on agent_fn1
    agent_fn2.dependsOn(agent_fn1)

    // Declare that host_fn1 depends on agent_fn2
    host_fn1.dependsOn(agent_fn2)    

Any of the objects can depend on multiple other objects:

.. tabs::

  .. code-tab:: python

    # Declare that agent_fn6 depends on agent_fn3, agent_fn4 and agent_fn5
    agent_fn6.dependsOn(agent_fn3)
    agent_fn6.dependsOn(agent_fn4)
    agent_fn6.dependsOn(agent_fn5)

  .. code-tab:: cpp

    // Declare that agent_fn6 depends on agent_fn3, agent_fn4 and agent_fn5
    agent_fn6.dependsOn(agent_fn3, agent_fn4, agent_fn5)

Accessing the DependencyGraph
-----------------------------

Each model has an associated dependency graph which is accessed via a ``ModelDescription`` as follows:

.. tabs::

  .. code-tab:: python

    # Access the DependencyGraph of model
    graph = model.getDependencyGraph()

  .. code-tab:: cpp

    // Access the DependencyGraph of model
    flamegpu::DependencyGraph& graph = model.getDependencyGraph();

Specifying Roots
----------------

Any functions or submodels which have no dependencies are *roots*. These must be added to the dependency graph:

.. tabs::

  .. code-tab:: python

    # Add agent_fn1 as a root
    graph.addRoot(agent_fn1)

  .. code-tab:: cpp

    // Add agent_fn1 as a root
    graph.addRoot(agent_fn1);

You do not need to manually add every function or submodel to the graph. Adding the roots is enough, as the others will be included
as a result of the dependency specifications.

Generating Layers
-----------------

When you have specified all your dependencies and roots, you must instruct the model to generate execution layers from the dependency graph:

.. tabs::

  .. code-tab:: python

    # Generate the actual execution layers from the dependency graph
    model.generateLayers()

  .. code-tab:: cpp

    // Generate the actual execution layers from the dependency graph
    model.generateLayers();

If you wish to see the actual layers generated, you can use the ``getConstructedLayersString()`` method of the dependency graph to obtain a
string representation of the layers:

.. tabs::

  .. code-tab:: python

    # Get the constructed layers and store them in variable actualLayers
    actualLayers = graph.getConstructedLayersString()

    # Print the layers to the console
    print(actualLayers)

  .. code-tab:: cpp

    // Get the constructed layers and store them in variable actualLayers
    std::string actualLayers = graph.getConstructedLayersString();

    // Print the layers to the console
    std::cout << actualLayers << std::endl;

Visualising the Dependencies
----------------------------

FLAMEGPU2 can automatically produce a *GraphViz* format graph of your dependency tree. You can use this to visually validate that behaviours 
will be happening in the order you expect them to.

.. tabs::

  .. code-tab:: python

    # Produce a diagram of the dependency graph, saved as graphdiagram.gv
    graph.generateDOTDiagram("graphdiagram.gv")

  .. code-tab:: cpp

    // Produce a diagram of the dependency graph, saved as graphdiagram.gv
    graph.generateDOTDiagram("graphdiagram.gv");

As an example, the following code would produce the graph below in a file named *diamond.gv*:

.. tabs::

  .. code-tab:: python

    f2.dependsOn(f)
    f3.dependsOn(f)
    f4.dependsOn(f2)
    f4.dependsOn(f3)
    graph = model.getDependencyGraph()
    graph.addRoot(f)
    graph.generateDOTDiagram("diamond.gv")

  .. code-tab:: cpp

    f2.dependsOn(f);
    f3.dependsOn(f);
    f4.dependsOn(f2, f3);
    graph = model.getDependencyGraph();
    graph.addRoot(f);
    graph.generateDOTDiagram("diamond.gv");

.. graphviz::

  digraph {
    Function1[style = filled, color = red];
    Function2[style = filled, color = red];
    Function4[style = filled, color = red];
    Function3[style = filled, color = red];
    Function4[style = filled, color = red];
    Function1 -> Function2;
    Function2 -> Function4;
    Function1 -> Function3;
    Function3 -> Function4;
  }

Manual Layer Specification
--------------------------

FLAMEGPU2 will automatically determine the optimal execution layers using the DependencyGraph, but you can
specify them manually if you wish. To do so, create `LayerDescription` objects, one representing each execution layer.
Manually created layers will execute in the order they are defined. You should not mix manual layer creation with
the dependency specification method.


.. tabs::

  .. code-tab:: python

    # Create a new layer for the model 'model'
    layer = model.newLayer()

    # Add the agent function 'outputdata' to the layer
    layer.addAgentFunction(outputdata)

  .. code-tab:: cpp

    // Create a new layer for the model 'model'
    flamegpu::LayerDescription &layer = model.newLayer();
    
    // Add the agent function 'outputdata' to the layer
    layer.addAgentFunction(outputdata);