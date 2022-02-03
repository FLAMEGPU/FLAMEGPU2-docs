.. _Layers:
Layers
^^^^^^

If you are a returning user, familiar with FLAME GPU 1, then you should already be familiar with the concept of layers.

The execution of a model can be broken down into several layers. The layers execute in order, each represented by a :class:`LayerDescription<flamegpu::LayerDescription>`, with functions within the same layer having the ability to execute concurrently.

FLAME GPU enforces limitations on which model components can be placed in the same layer, to ensure safe concurrency within a layer.

Manually specified layers cannot be mixed with dependency specification introduced in the :ref:`previous section<Dependency Graph>`.

Manual Layer Specification
--------------------------

:func:`newLayer()<flamegpu::ModelDescription::newLayer>` is called on the :class:`ModelDescription<flamegpu::ModelDescription>` to create a new :class:`LayerDescription<flamegpu::LayerDescription>`. Layers will execute in the order that they are created.

Agent functions, host functions, and submodels can then be added to layers via their respective methods: :func:`addAgentFunction()<flamegpu::LayerDescription::addAgentFunction>`, :func:`addHostFunction()<flamegpu::LayerDescription::addHostFunction>` (Python: ``addHostFunctionCallback()``) and :func:`addSubModel()<flamegpu::LayerDescription::addSubModel>`. To each of these you pass the respective description object, alternatively for agent and host functions you can pass their raw function handles that were used to create the functions (this won't work for agent function definitions used by multiple agents).

The below example demonstrates adding an agent and host function to separate layers.
  
.. tabs::
  .. code-tab:: cpp C++
  
    FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageSpatial3D) {
        // Do something
        return flamegpu::ALIVE;
    }
    FLAMEGPU_HOST_FUNCTION(validation) {
        // Do something
    }

    flamegpu::ModelDescription model("Layers Example");
    ... // Full model definition, including the agent function 'outputdata'

    // Create a new layer for the model 'model'
    flamegpu::LayerDescription &layer = model.newLayer();    
    // Add the agent function 'outputdata' to the layer
    layer.addAgentFunction(outputdata);
    
    // Create a new layer for the host function 'validation'
    model.newLayer().addHostFunction(validation);

  .. code-tab:: py Python
  
    outputdata = r"""
    FLAMEGPU_AGENT_FUNCTION(outputdata, flamegpu::MessageNone, flamegpu::MessageSpatial3D) {
        // Do something
        return flamegpu::ALIVE;
    }
    """
    class validation(pyflamegpu.HostFunctionCallback):
        def run(self, FLAMEGPU):
            # Do something
    }

    model = pyflamegpu.ModelDescription("Layers Example")
    agent = model.newAgent("agent")
    outputdata_desc = agent.newRTCFunction("output data", outputdata)
    ... # Remaining model description (e.g. agent variables)

    # Create a new layer for the model 'model'
    layer = model.newLayer();   
    # Add the agent function 'outputdata' to the layer, using it's AgentFunctionDescription
    layer.addAgentFunction(outputdata_desc)
    
    # Create a new layer for the host function 'validation'
    model.newLayer().addHostFunctionCallback(validation().__disown__())


Layer Specification Rules
--------------------------

The below rules are enforced, to ensure functions and submodels placed in the same layer can operate concurrently. If you attempt to break these rules an exception will be raised.

* An agent function and a host function may not exist in the same layer.
* An agent function cannot be added to a layer containing an agent function for the same agent (which shares an input or output state) with another agent function.
* An agent function cannot be added to a layer containing an agent function which outputs new agents which share the type (and input or output state) with another agent function.
* An agent function which outputs to a message list cannot be in the same layer as an agent function which inputs/outputs to/from the same message list.
* A host function may only exist in a layer by itself.
* A submodel may only exist in a layer by itself.


Related Links
-------------

* Full API documentation for :class:`LayerDescription<flamegpu::LayerDescription>`
* Full API documentation for :class:`ModelDescription<flamegpu::ModelDescription>`