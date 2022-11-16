Visualising Agents
==================
The main purpose of FLAME GPU visualisations is to display the agents. By default no agents are visualised, and each agent to be visualised must be configured.

.. tabs::

  .. code-tab:: cpp C++

    // Configure the visualisation
    flamegpu::visualiser::ModelVis visualisation = cudaSimulation.getVisualisation();
    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    ...
    
  .. code-tab:: py Python

    # Configure the visualisation
    visualisation = cudaSimulation.getVisualisation()
    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    ...

Agent Model
-----------
Currently FLAME GPU only supports loading models from ``.obj`` (wavefront) format files.

It is suggested that low-poly models are used, as each model will be drawn once per agent. Which potentially multiplies the polygon count by millions, which can significantly impact the performance of the visualiser.

Several static stock models are provided alongside FLAME GPU.

====================== ========================================================
Model Name             Description
====================== ========================================================
``SPHERE``             A sphere constructed from slices and segments
``ICOSPHERE``          A lower-poly sphere constructed from triangles
``CUBE``               A simple 12-poly cube
``TEAPOT``             The traditional graphics example model, Utah teapot
``STUNTPLANE``         A low-poly model of a plane, useful for representing agents with rotation in all 3 planes
``PYRAMID``            A 4-poly equilateral triangular pyramid
``ARROWHEAD``          A 4-poly triangular pyramid for indicating 3D orientation
====================== ========================================================

Examples of setting the agent model are shown below

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    // Configure the agent to use the stock icosphere model
    boid_agt.setModel(flamegpu::visualiser::Stock::Models::ICOSPHERE);
    // Or, configure the agent to use a custom model
    boid_agt.setModel("my_files/person.obj");
    
  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    # Configure the agent to use the stock icosphere model
    boid_agt.setModel(pyflamegpu.ICOSPHERE)
    # Or, configure the agent to use a custom model
    boid_agt.setModel("my_files/person.obj")
    
KeyFrame Animated Models
^^^^^^^^^^^^^^^^^^^^^^^^

FLAME GPU also supports the use of model pairs, to provide basic animation by interpolating between the two models. Both models must have the same number of vertices/faces in the same order for this to work.

A stock keyframe model pair ``PEDESTRIAN`` is avaiable, which represents a low-poly pedestrian.

In order to use a keyframe model pair, it is also necessary to specify a ``float`` agent variable, which contains the interpolation position in the inclusive range ``[0, 1]`` which controls the contribution of each model to that which is rendered by the agent.

Examples of setting a keyframe agent model are shown below

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'pedestrian' to the visualisation
    flamegpu::visualiser::AgentVis ped_agt = visualisation.addAgent("pedestrian");
    // Configure the agent to use the stock pedestrian model, and "animate" variable to control animation
    ped_agt.setKeyFrameModel(flamegpu::visualiser::Stock::Models::PEDESTRIAN, "animate");
    // Or, configure the agent to use a custom model pair, and "animate" variable to control animation
    ped_agt.setKeyFrameModel("my_files/ped_a.obj", "my_files/ped_a.obj", "animate");
    
  .. code-tab:: py Python

    # Add agent 'pedestrian' to the visualisation
    ped_agt = visualisation.addAgent("pedestrian")
    # Configure the agent to use the stock pedestrian model, and "animate" variable to control animation
    ped_agt.setKeyFrameModel(pyflamegpu.PEDESTRIAN, "animate")
    # Or, configure the agent to use a custom model pair, and "animate" variable to control animation
    ped_agt.setKeyFrameModel("my_files/ped_a.obj", "my_files/ped_a.obj", "animate")
    
The video below shows the Pedestrian Navigation example which demonstrates how keyframe animated agents appear.

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/9jPfBs81XmE" title="Pedestrian Navigation Example in FLAME GPU 2" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Agent Position
--------------

Agent variables can be used to control an agent's position with the visualisation. It is required that atleast one component is set, otherwise agents will all remain at the origin.

By default, if an agent has ``float`` variables with names ``x``, ``y`` and ``z``, these will be used for the agent's position.

However, you can use other variables if you have used different variable names or an array variable.

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    
    // Set agent position with upto 3 individual float variables
    boid_agt.setXVariable("pos_x");
    boid_agt.setYVariable("pos_y");
    boid_agt.setZVariable("pos_z");
    // Or, set agent position with a single float[2] variable
    boid_agt.setXYVariable("pos_xy");
    // Or, set agent position with a single float[3] variable
    boid_agt.setXYZVariable("pos_xyz");
    
  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid");
    
    # Set agent position with upto 3 individual float variables
    boid_agt.setXVariable("pos_x")
    boid_agt.setYVariable("pos_y")
    boid_agt.setZVariable("pos_z")
    # Or, set agent position with a single float[2] variable
    boid_agt.setXYVariable("pos_xy")
    # Or, set agent position with a single float[3] variable
    boid_agt.setXYZVariable("pos_xyz")


Agent Direction
---------------

Agent direction or rotation can be linked to agent variables similar to that of agent position, this will cause the model used for the agent to rotate towards the given direction. However, there are several options to choose from depending on how direction is stored within your model.

You can specify the forward vector of the agent (e.g. it's velocity), which are used to derive the agent's yaw and pitch. This can optionally be extended by specifying an up vector, which will be used to derive agent's roll.

Alternatively, you can directly specify the yaw, pitch and roll variables.

A few examples are provided below, for a complete understanding of the combinations permitted view the API documentation for :class:`AgentVis<flamegpu::visualiser::AgentVis>`.

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    
    // Set agent forward and up vectors (yaw, pitch and roll) with individual float variables
    boid_agt.setForwardXVariable("velocity_x");
    boid_agt.setForwardYVariable("velocity_y");
    boid_agt.setForwardZVariable("velocity_z");
    boid_agt.setUpXVariable("up_x");
    boid_agt.setUpYVariable("up_y");
    boid_agt.setUpZVariable("up_z");
    // Or, set agent forward vector xz (yaw) with a single float[2] variable
    boid_agt.setForwardXZVariable("velocity_xz");
    // Or, set agent forward vector (yaw and pitch) with a single float[3] variable
    boid_agt.setForwardXYZVariable("velocity_xyz");
    // Or, set agent yaw, pitch and roll angles with individual float variables
    boid_agt.setYawVariable("yaw");
    boid_agt.setPitchVariable("pitch");
    boid_agt.setRollVariable("roll");
    // Or, set agent yaw, pitch with a single float[2] variable
    boid_agt.setDirectionYPVariable("angles");
    // Or, set agent yaw, pitch, roll with a single float[3] variable
    boid_agt.setDirectionYPRVariable("angles");
    
  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    
    # Set agent forward and up vectors (yaw, pitch and roll) with individual float variables
    boid_agt.setForwardXVariable("velocity_x")
    boid_agt.setForwardYVariable("velocity_y")
    boid_agt.setForwardZVariable("velocity_z")
    boid_agt.setUpXVariable("up_x")
    boid_agt.setUpYVariable("up_y")
    boid_agt.setUpZVariable("up_z")
    # Or, set agent forward vector xz (yaw) with a single float[2] variable
    boid_agt.setForwardXZVariable("velocity_xz")
    # Or, set agent forward vector (yaw and pitch) with a single float[3] variable
    boid_agt.setForwardXYZVariable("velocity_xyz")
    # Or, set agent yaw, pitch and roll angles with individual float variables
    boid_agt.setYawVariable("yaw")
    boid_agt.setPitchVariable("pitch")
    boid_agt.setRollVariable("roll")
    # Or, set agent yaw, pitch with a single float[2] variable
    boid_agt.setDirectionYPVariable("angles")
    # Or, set agent yaw, pitch, roll with a single float[3] variable
    boid_agt.setDirectionYPRVariable("angles")

Agent Scale
-----------

Similar to agent position and direction, agent variables can be used to set a scale multiplier for the model used.

First you should set the base model scale (with :func:`setModelScale()<flamegpu::visualiser::AgentVis::setModelScale>`), and then the multiplier used will multiply by this value (so an agent variable with value 1, would be at the base scale). If you would prefer to provide the absolute model scale via agent variables, then specify a model scale of 1.

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    // Uniformly scale the default model so that it is 1.5 units in it's longest axis
    boid_agt.setModelScale(1.5f);
    // Or, scale each axis of the default model individually
    boid_agt.setModelScale(1.0f, 1.5f, 1.0f);
    
    // Uniformly scale the model with a single float variable
    boid_agt.setUniformScaleVariable("scale_xyz");
    // Or, set agent scale multiplier with upto 3 individual float variables
    boid_agt.setScaleXVariable("scale_x");
    boid_agt.setScaleYVariable("scale_y");
    boid_agt.setScaleZVariable("scale_z");
    // Or, set agent scale multiplier with a single float[2] variable
    boid_agt.setScaleXYVariable("scale_xy");
    // Or, set agent scale multiplier with a single float[3] variable
    boid_agt.setScaleXYZVariable("scale_xyz");
    
    
  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    # Uniformly scale the default model so that it is 1.5 units in it's longest axis
    boid_agt.setModelScale(1.5)
    # Or, scale each axis of the default model individually
    boid_agt.setModelScale(1.0, 1.5, 1.0)
    
    # Uniformly scale the model with a single float variable
    boid_agt.setUniformScaleVariable("scale_xyz")
    # Or, set agent scale multiplier with upto 3 individual float variables
    boid_agt.setScaleXVariable("scale_x")
    boid_agt.setScaleYVariable("scale_y")
    boid_agt.setScaleZVariable("scale_z")
    # Or, set agent scale multiplier with a single float[2] variable
    boid_agt.setScaleXYVariable("scale_xy")
    # Or, set agent scale multiplier with a single float[3] variable
    boid_agt.setScaleXYZVariable("scale_xyz")

    
Agent Color
-----------
There are a wide range of options for controlling the color of agent models.

Static Colors
^^^^^^^^^^^^^

Agent colors can be specified as a static RGB color.

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    
    // Set the agent's color to a stock color
    boid_agt.setColor(flamegpu::visualiser::Stock::Colors::RED);
    // Set the agent's color with a HEX color code
    boid_agt.setColor(flamegpu::visualiser::Color{"#ff0000"});
    // Set the agent's color with floating point components
    boid_agt.setColor(flamegpu::visualiser::Color{1.0f, 0.0f, 0.0f});
    
    
  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    
    # Set the agent's color to a stock color
    boid_agt.setColor(pyflamegpu.RED)
    # Set the agent's color with a HEX color code
    boid_agt.setColor(pyflamegpu.Color("#ff0000"))
    # Set the agent's color with floating point components
    boid_agt.setColor(pyflamegpu.Color(1.0, 0.0, 0.0))
    
Discrete Color Selection
^^^^^^^^^^^^^^^^^^^^^^^^
An ``integer`` or ``unsigned integer`` agent variable can map to a palette of colors.

A :class:`DiscreteColor<flamegpu::visualiser::DiscreteColor>` instance is simply a map between integer keys, and :class:`Color<flamegpu::visualiser::Color>` values. An additional fall-back color must also be specified, this will be used if the value an agent holds falls outside of the keys found within the map.

A predefined stock Palette can be used to automatically fill, the map. Keys will be assigned 0,1,2 etc, however this can be changed by overriding the offset and stride.

The stock palettes available are:

========================= ================================= =============================
Qualitative               Sequential                        Diverging
========================= ================================= =============================
Set1 (from Colorbrewer)   YlOrRd (from Colorbrewer)         RdYlBu (from Colorbrewer) 
Set2 (from Colorbrewer)   YlGn (from Colorbrewer)           PiYG (from Colorbrewer) 
Dark2 (from Colorbrewer)  Greys (from Colorbrewer)
Pastel (from seaborn)     *Viridis (from BIDS/MatPlotLib)*
========================= ================================= =============================

.. note::

  The Viridis palette is dynamic, it uniformly samples the number of specified values from the continuous Viridis palette.

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    
    // Map the agent's color to the value of 'i' as selected from a discrete stock palette
    boid_agt.setColor(flamegpu::visualiser::DiscreteColor("i", flamegpu::visualiser::Stock::Palette::DARK2, flamegpu::visualiser::Stock::Colors::WHITE));
    // Or, map the agent's color to the value of 'i', as selected from a dynamic stock palette, using 10 uniformly spaced values from Viridis
    // Override the offset to 1, and stride to 2 (1,3,5,7..)
    boid_agt.setColor(flamegpu::visualiser::DiscreteColor("i", flamegpu::visualiser::Stock::Palette::Viridis(10), flamegpu::visualiser::Stock::Colors::WHITE,
    1, 2));
    
    
  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    
    # Map the agent's color to the value of 'i' as selected from a discrete stock palette
    boid_agt.setColor(pyflamegpu.DiscreteColor("i", pyflamegpu.DARK2, pyflamegpu.WHITE))
    # Or, map the agent's color to the value of 'i', as selected from a dynamic stock palette, using 10 uniformly spaced values from Viridis
    # Override the offset to 1, and stride to 2 (1,3,5,7..)
    boid_agt.setColor(pyflamegpu.DiscreteColor("i", pyflamegpu.Viridis(10), pyflamegpu.WHITE, 1, 2))

Alternatively, you can construct a bespoke palette of discrete colors

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    
    // Construct a DiscreteColor map for integer variable "i" with fall-back White
    flamegpu::visualiser::iDiscreteColor cmap("i", flamegpu::visualiser::Stock::Colors::WHITE);
    // Add desired key:color mappings
    cmap[0] = flamegpu::visualiser::Stock::Colors::RED;
    cmap[1] = flamegpu::visualiser::Color{"#00ff00"};
    cmap[2] = flamegpu::visualiser::Color{0.0, 0.0, 1.0};    
    // Bind cmap to the 'boid' agent
    boid_agt.setColor(cmap);
    
  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid");
    
    # Construct a DiscreteColor map for integer variable "i" with fall-back White
    cmap = pyflamegpu.iDiscreteColor("i", pyflamegpu.WHITE)
    # Add desired key:color mappings
    cmap[0] = pyflamegpu.RED
    cmap[1] = pyflamegpu.Color("#00ff00")
    cmap[2] = pyflamegpu.Color(0.0, 0.0, 1.0)
    # Bind cmap to the 'boid' agent
    boid_agt.setColor(cmap)

Color Interpolation
^^^^^^^^^^^^^^^^^^^
A ``float`` agent variable can also be mapped to colors, by interpolating through a specified palette.

Currently there are two options available for this; :class:`HSVInterpolation<flamegpu::visualiser::HSVInterpolation>` and :class:`ViridisInterpolation<flamegpu::visualiser::ViridisInterpolation>`.

By default interpolation clamps variables to the inclusive range [0, 1]. This can be overridden by setting the minimum and maximum bounds.

:class:`HSVInterpolation<flamegpu::visualiser::HSVInterpolation>` allows you to interpolate around the hues of the HSV color wheel. This can be used to provide a simple heatmap.


.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    
    // Use the default red-green HSV interpolation over the agent variable i
    // With custom min/max bounds [0,100]
    boid_agt.setColor(flamegpu::visualiser::HSVInterpolation::REDGREEN("i", 0.0f, 100.0f));
    // Or, use a custom HSV interpolation over the agent variable i
    boid_agt.setColor(flamegpu::visualiser::HSVInterpolation("i", 0.0f, 360.0f));
    
  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    
    # Use the default red-green HSV interpolation over the agent variable i
    # With custom min/max bounds [0,100]
    boid_agt.setColor(pyflamegpu.HSVInterpolation.REDGREEN("i", 0.0, 100.0))
    # Or, use a custom HSV interpolation over the agent variable i
    boid_agt.setColor(pyflamegpu.HSVInterpolation("i", 0.0, 360.0))


:class:`ViridisInterpolation<flamegpu::visualiser::ViridisInterpolation>` works similarly, but interpolates over the fixed Viridis heatmap from BIDS/MatPlotLib.

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    
    // Use Viridis interpolation over the agent variable i
    boid_agt.setColor(flamegpu::visualiser::ViridisInterpolation("i"));
    
  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    
    # Use Viridis interpolation over the agent variable i
    boid_agt.setColor(pyflamegpu.ViridisInterpolation("i"))

Agent States
------------

Additional configurations are possible, to differentiate multi-state agents in each of their states.

First an :class:`AgentStateVis<flamegpu::visualiser::AgentStateVis>` for specialising the agent state must be retrieved using :func:`State()<flamegpu::visualiser::AgentVis::State>`.

By default, this new agent will be assigned a different color from the default palette.

:class:`AgentStateVis<flamegpu::visualiser::AgentStateVis>` has the same methods as :class:`AgentVis<flamegpu::visualiser::AgentVis>` to allow agent states to be differentiated by their: model, model scale and color, using the same methods as described in the above sections. It is not possible, to specify a different position or direction configuration for each agent state.

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    ...
    // Specialise the 'active' agent state
    flamegpu::visualiser::AgentStateVis active_boid_agt = boid_agent.State("active");
    ...

  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    ...
    # Specialise the 'active' agent state
    active_boid_agt = boid_agent.State("active")
    ...
    
Colors from Palettes
^^^^^^^^^^^^^^^^^^^^

If you would rather use a palette to automatically assign agents in different states colors, rather than manual assignment outlined above, you can specify a pallet to be used with :func:`setAutoPalette()<flamegpu::visualiser::AgentVis::setAutoPalette>`. Each agent state specialised (by calling :func:`State()<flamegpu::visualiser::AgentVis::State>`) will then be assigned a different color from the selected palette.

.. tabs::

  .. code-tab:: cpp C++

    // Add agent 'boid' to the visualisation
    flamegpu::visualiser::AgentVis boid_agt = visualisation.addAgent("boid");
    // Assign a palette to the boid agent
    boid_agt.setAutoPalette(flamegpu::visualiser::Stock::Palette::DARK2);
    
    // Specialise the 'active' agent state, assigning it a unique color from the DARK2 palette
    boid_agent.State("active");
    // Specialise the 'waiting' agent state, assigning it a unique color from the DARK2 palette
    boid_agent.State("waiting");

  .. code-tab:: py Python

    # Add agent 'boid' to the visualisation
    boid_agt = visualisation.addAgent("boid")
    # Assign a palette to the boid agent
    boid_agt.setAutoPalette(pyflamegpu.DARK2)
    
    # Specialise the 'active' agent state, assigning it a unique color from the DARK2 palette
    boid_agent.State("active")
    # Specialise the 'waiting' agent state, assigning it a unique color from the DARK2 palette
    boid_agent.State("waiting")
    
These colors are not locked, and can be further overridden with the normal color methods.


Related Links
-------------

* Full API documentation for :class:`AgentVis<flamegpu::visualiser::AgentVis>`
* Full API documentation for :class:`AgentStateVis<flamegpu::visualiser::AgentStateVis>`
* Full API documentation for :class:`ModelVis<flamegpu::visualiser::ModelVis>`
* Full API documentation for :class:`Color<flamegpu::visualiser::Color>`
* Full API documentation for :class:`DiscreteColor<flamegpu::visualiser::DiscreteColor>`
* Full API documentation for :class:`HSVInterpolation<flamegpu::visualiser::HSVInterpolation>`
* Full API documentation for :class:`ViridisInterpolation<flamegpu::visualiser::ViridisInterpolation>`
