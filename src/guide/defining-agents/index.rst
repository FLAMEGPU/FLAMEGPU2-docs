.. _Defining Agents:

Defining Agents
===============

Agents are the central component of FLAME GPU simulations, and are directly equivalent to agent-based modelling agents. However, they can also be used to represent other things such as scalar fields across the environment. Agents are represented by an :class:`AgentDescription<flamegpu::AgentDescription>` object.

Defining a New Agent Type
^^^^^^^^^^^^^^^^^^^^^^^^^
FLAME GPU 2 agents are associated with a particular model. As such they are created via a :class:`ModelDescription<flamegpu::ModelDescription>` object and are initialised with a name:

.. tabs::

  .. code-tab:: cpp C++

    // Create a new agent called 'predator' associated the model 'model' 
    flamegpu::AgentDescription predator = model.newAgent("predator");

  .. code-tab:: py Python

    # Create a new agent called 'predator' associated the model 'model' 
    predator = model.newAgent("predator")

Agent Variables
^^^^^^^^^^^^^^^

Agent variables should be used to store data which is unique to each instance of an agent, for example, each individual predator in a predator-prey simulation
would have its own position and hunger level. Each variable has a name, type, default value and may take the form of a scalar or array.

For a full list of supported types, see :ref:`Supported Types<Supported Types>`.

Agent ID
--------

All agents have a built in ID variable. This is a number which uniquely identifies this agent. Each agent will automatically be assigned an ID when the simulation 
starts or the agent is birthed. The ID is value for every agent is unique among agents of all types. There is currently no way to change the ID of an agent. The agent ID variable is of type :type:`flamegpu::id_t` (Python: ``ID``) which is an ``unsigned int`` by default, but can be redefined if more IDs are required, e.g. a model with extremely high rates of agent birth/death.

The symbol :var:`flamegpu::ID_N0T_SET` , equal to ``0``, is reserved and will never be assigned as an agent's id. Therefore it can be used if invalid or no ID must be represented.

User Defined Variables
----------------------

Bespoke agent variables are declared using the :func:`newVariable()<template<typename T> void flamegpu::AgentDescription::newVariable(const std::string &, T)>` methods.

The type and name the variables must be specified, array variables additionally require the length of the array to be specified. Optionally, a default value for the variables may also be specified

.. tabs::

  .. code-tab:: cpp C++

    // Declare an integer variable 'foo', with a default value 12
    predator.newVariable<int>("foo", 12);
    // Declare a float variable 'bar', without a default value
    predator.newVariable<int>("bar", 12);
    // Declare a float array variable of length 3 named 'foobar', with a default value [4.0, 5.0, 6.0]
    predator.newVariable<float, 3>("foobar", {4.0f, 5.0f, 6.0f});

  .. code-tab:: py Python
  
    # Declare an integer variable 'foo', with a default value 12
    predator.newVariableInt("foo", 12)
    # Declare a float variable 'bar', without a default value
    predator.newVariableFloat("bar")
    # Declare a float array variable of length 3 named 'bar', with a default value [4.0, 5.0, 6.0]
    predator.newVariableArrayFloat("foobar", 3, [4.0, 5.0, 6.0])


.. note::
  
  Variable names must not begin with ``_``, this is reserved for internal variables.

.. _Agent States:

Agent States
^^^^^^^^^^^^

Agent states are usually used to group sets of behaviours. For example, a predator in a predator-prey simulation may have a resting state and a hunting state.
All newly defined agent types will have a default state, but you can add additional states if you wish to. Agent functions can then utilise agent function conditions to perform state transitions.

States can be defined through the :class:`AgentDescription<flamegpu::AgentDescription>` object:

.. tabs::


  .. code-tab:: cpp C++

    // Create two new states, resting and hunting
    predator.newState("resting");
    predator.newState("hunting");

  .. code-tab:: py Python

    # Create two new states, resting and hunting
    predator.newState("resting")
    predator.newState("hunting")

:ref:`Agent State Transitions<Agent State Transitions>` are then used to transfer agents between states.

Related Links
^^^^^^^^^^^^^

* User Guide Section: :ref:`Supported Types<Supported Types>`
* User Guide Chapter: :ref:`Agent Functions<Agent Functions>`
* User Guide Page: :ref:`Agent Operations<Host Agent Operations>` (Host Functions)
* User Guide Page: :ref:`Agent State Transitions<Agent State Transitions>`
* Full API documentation for :class:`AgentDescription<flamegpu::AgentDescription>`
* Full API documentation for :class:`ModelDescription<flamegpu::ModelDescription>`
