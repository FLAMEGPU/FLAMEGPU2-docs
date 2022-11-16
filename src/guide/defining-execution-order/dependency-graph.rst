.. _Dependency Graph:

Dependency Graph
^^^^^^^^^^^^^^^^

The dependency graph functionality, is new to FLAME GPU 2 and provides a more natural means of specifying the execution order a model.

Specifying a dependency, e.g. ``a`` *depends on* ``b`` ensures that function ``a`` will not run until function ``b`` has completed.
This can be used to define the order you want behaviours to take place in, and to ensure that a function which outputs messages
is complete before another function attempts to read them.


Dependency specification cannot be mixed with manually specified layers introduced in the :ref:`next section<Layers>`.

Specifying Dependencies
-----------------------

Dependencies are specified between :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`, :class:`SubmodelDescription<flamegpu::SubmodelDescription>` and :class:`HostFunctionDescription<flamegpu::HostFunctionDescription>` objects. 
These are specified using the ``dependsOn()`` method available within each.

.. tabs::

  .. code-tab:: cpp C++

    // Declare that agent_fn2 depends on agent_fn1
    agent_fn2.dependsOn(agent_fn1)

    // Declare that host_fn1 depends on agent_fn2
    host_fn1.dependsOn(agent_fn2)

  .. code-tab:: py Python

    # Declare that agent_fn2 depends on agent_fn1
    agent_fn2.dependsOn(agent_fn1)

    # Declare that host_fn1 depends on agent_fn2
    host_fn1.dependsOn(agent_fn2)

Any of the objects can depend on multiple other objects:

.. tabs::

  .. code-tab:: cpp C++

    // Declare that agent_fn6 depends on agent_fn3, agent_fn4 and agent_fn5
    agent_fn6.dependsOn(agent_fn3, agent_fn4, agent_fn5)

  .. code-tab:: py Python

    # Declare that agent_fn6 depends on agent_fn3, agent_fn4 and agent_fn5
    agent_fn6.dependsOn(agent_fn3)
    agent_fn6.dependsOn(agent_fn4)
    agent_fn6.dependsOn(agent_fn5)




Specifying Roots
----------------

Any functions or submodels which have no dependencies are *roots*. These must be added to the dependency graph:

.. tabs::

  .. code-tab:: cpp C++

    // Add agent_fn1 as a root
    model.addExecutionRoot(agent_fn1);

  .. code-tab:: py Python

    # Add agent_fn1 as a root
    model.addExecutionRoot(agent_fn1)

You do not need to manually add every function or submodel to the graph. Adding the roots is enough, as the others will be included
as a result of the dependency specifications.



Host Layer Functions
--------------------

In order to add a host layer function to the dependency graph, a :class:`HostFunctionDescription<flamegpu::HostFunctionDescription>` object must be created to wrap it:

.. tabs::

  .. code-tab:: cpp C++

    // Define a host function called host_fn1
    FLAMEGPU_HOST_FUNCTION(host_fn1) {
        // Behaviour goes here
    }

    // ... other code ...

    // Wrap it in a HostFunctionDescription, giving it the name "HostFunction1"
    HostFunctionDescription hf("HostFunction1", host_fn1);

    // Specify that it depends on an agent function "f"
    hf.dependsOn(f);


  .. code-tab:: py Python

    # Define a host function called host_fn1
    class host_fn1(pyflamegpu.HostFunctionCallback):
      '''
         The explicit __init__() is optional, however if used the superclass __init__() must be called
      '''
      def __init__(self):
        super().__init__()

      def run(self,FLAMEGPU):
        # Behaviour goes here

    # ... other code ...

    # Wrap it in a HostFunctionDescription, giving it the name "HostFunction1"
    hf = pyflamegpu.HostFunctionDescription("HostFunction1", host_fn1)

    # Specify that it depends on an agent function "f"
    hf.dependsOn(f)

If you are using the layers API directly, you do not need to wrap your host layer functions in :class:`HostFunctionDescription` objects.

Generating Layers
-----------------

When you have specified all your dependencies and roots, you must instruct the model to generate execution layers from the dependency graph:

.. tabs::

  .. code-tab:: cpp C++

    // Generate the actual execution layers from the dependency graph
    model.generateLayers();

  .. code-tab:: py Python

    # Generate the actual execution layers from the dependency graph
    model.generateLayers()

If you wish to see the actual layers generated, you can use the :func:`getConstructedLayersString()<flamegpu::ModelDescription::getConstructedLayersString>` method of the model description to obtain a string representation of the layers:

.. tabs::

  .. code-tab:: cpp C++

    // Get the constructed layers and store them in variable actualLayers
    std::string actualLayers = model.getConstructedLayersString();

    // Print the layers to the console
    std::cout << actualLayers << std::endl;

  .. code-tab:: py Python

    # Get the constructed layers and store them in variable actualLayers
    actualLayers = model.getConstructedLayersString()

    # Print the layers to the console
    print(actualLayers)

Visualising the Dependencies
----------------------------

FLAME GPU 2 can automatically produce a *GraphViz* format graph of your dependency tree. You can use this to visually validate that behaviours 
will be happening in the order you expect them to.

.. tabs::

  .. code-tab:: cpp C++

    // Produce a diagram of the dependency graph, saved as graphdiagram.gv
    model.generateDependencyGraphDOTDiagram("graphdiagram.gv");

  .. code-tab:: py Python

    # Produce a diagram of the dependency graph, saved as graphdiagram.gv
    model.generateDependencyGraphDOTDiagram("graphdiagram.gv")

As an example, the following code would produce the graph below in a file named *diamond.gv*:

.. tabs::

  .. code-tab:: cpp C++

    f2.dependsOn(f);
    f3.dependsOn(f);
    f4.dependsOn(f2, f3);
    model.addExecutionRoot(f);
    model.generateDependencyGraphDOTDiagram("diamond.gv");

  .. code-tab:: py Python

    f2.dependsOn(f)
    f3.dependsOn(f)
    f4.dependsOn(f2)
    f4.dependsOn(f3)
    model.addExecutionRoot(f)
    model.generateDependencyGraphDOTDiagram("diamond.gv")

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


Accessing the DependencyGraph
-----------------------------

In general you should not need to directly access the dependency graph as all relevant functionality can be accessed via the model description. If 
for some reason you do need direct access, you can request it from via a :class:`ModelDescription<flamegpu::ModelDescription>` as follows:

.. tabs::

  .. code-tab:: cpp C++

    // Access the DependencyGraph of model
    flamegpu::DependencyGraph& graph = model.getDependencyGraph();

  .. code-tab:: py Python

    # Access the DependencyGraph of model
    graph = model.getDependencyGraph()

Related Links
-------------

* Full API documentation for :class:`DependencyGraph<flamegpu::DependencyGraph>`
* Full API documentation for :class:`ModelDescription<flamegpu::ModelDescription>`
* Full API documentation for :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`
* Full API documentation for :class:`HostFunctionDescription<flamegpu::HostFunctionDescription>`
* Full API documentation for :class:`SubmodelDescription<flamegpu::SubmodelDescription>`