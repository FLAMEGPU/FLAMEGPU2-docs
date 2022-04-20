.. _agent birth death:

Agent Birth & Death
^^^^^^^^^^^^^^^^^^^

By default agents within FLAME GPU cannot die or create new agents. In order to enable the checks and processing required for either of these operations, they must be enabled first.

Agent Death
-----------

When an agent in FLAME GPU is killed, it is removed from the simulation and all data held in the agent's variables is discarded.

Enabling Agent Death
====================

By default in FLAME GPU 2 agents do not die. To enable death for a particular agent function, use the :func:`setAllowAgentDeath()<flamegpu::AgentFunctionDescription::setAllowAgentDeath>` method of
the :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` object:

.. tabs::
  
  .. code-tab:: cpp C++

    // Allow agent_fn1 to kill agents
    agent_fn1_description.setAllowAgentDeath(true);

  .. code-tab:: py Python

    # Allow agent_fn1 to kill agents
    agent_fn1_description.setAllowAgentDeath(True)


Killing Agents via Agent Functions
==================================

To have an agent die, simply return :enumerator:`flamegpu::DEAD<flamegpu::AGENT_STATUS::DEAD>` instead of :enumerator:`flamegpu::ALIVE<flamegpu::AGENT_STATUS::ALIVE>` at the end of a death-enabled agent function. You can use conditionals to only have agents die according to a certain condition:

.. tabs::

  .. code-tab:: cuda CUDA C++
    
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Get the 'x' variable of the agent
        int x = FLAMEGPU->getVariable<int>("x");
        
        // Kill any agents with x < 25
        if (x < 25) {
            return flamegpu::DEAD;
        } else {
            return flamegpu::ALIVE;
        }
    }


If :enumerator:`flamegpu::DEAD<flamegpu::AGENT_STATUS::DEAD>` is returned by an agent function whilst agent death is not enabled the agent will not die. If ``SEATBELTS`` error checking is enabled an exception will be raised.


Agent Birth
-----------
The agent creation interface usable in agent functions is only able to create a single agent per existing agent per iteration. 
Additionally, the  type (and state) of the agent being created must be earlier specified as part of the model description (a single agent function can only output 1 specific agent type and state). Agent's can also be created via host functions, that may be more applicable in cases where many agents must be created from a single source.

Agent birth from agent functions is always considered optional, any agent which sets an output agent's variables will cause the output agent to be created.

.. note::
    Agents created by agent functions do not exist until the next layer.

Enabling Agent Birth
====================

To create agents from agent functions, you must specify the type of agent the function produces when defining your agent functions, by passing it a reference to the :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`. If using states you can additionally specify the state the agent should be created within:

.. tabs::

  .. code-tab:: cpp C++
  
    // Create a new agent type 'example_agent'
    flamegpu::AgentDescription &example_agent = model.newAgent("example_agent");
    
    ...
    
    // The agent type 'example_agent' is set as the agent output type
    // To be output in the default state
    agent_fn1_description.setAgentOutput(example_agent);
    
    // The agent type 'example_agent' is set as the agent output type
    // To be output in the state 'living'
    agent_fn2_description.setAgentOutput(example_agent, "living");

  .. code-tab:: py Python
  
    # Create a new agent type 'example_agent'
    example_agent = model.newAgent("example_agent")
    
    ...
  
    # The agent type 'example_agent' is set as the agent output type
    # To be output in the default state
    agent_fn1_description.setAgentOutput(example_agent)
    
    # The agent type 'example_agent' is set as the agent output type
    # To be output in the state 'living'
    agent_fn2_description.setAgentOutput(example_agent, "living")

Creating Agents via Agent Functions
===================================

When agent output has been enabled for an agent function, the :class:`FLAMEGPU->agent_out<flamegpu::DeviceAPI::AgentOut>` object will become available within agent
function definitions. This can be used to initialise the properties of the newly created agent.

Much like the agent's variables, :func:`setVariable()<flamegpu::DeviceAPI::AgentOut::setVariable>` can be used on this object, to set the new agent's variables. Additionally, :func:`getID()<flamegpu::DeviceAPI::AgentOut::getID>` may be used to retrieve the new agents future ID.

Agent variables which are not manually set will be initialised with their default values.

Agent creation is always optional once enabled, a new agent will only be marked for creation when either :func:`setVariable()<flamegpu::DeviceAPI::AgentOut::setVariable>` or :func:`getID()<flamegpu::DeviceAPI::AgentOut::getID>` are called.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    FLAMEGPU_AGENT_FUNCTION(OptionalOutput, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Fetch this agent's id
        flamegpu::id_t id = FLAMEGPU->getID();
  
        // If its id is even, output a new agent, otherwise do nothing
        if (id % 2 == 0) {
            // Output a new agent with its 'x' variable set to 500.0f
            FLAMEGPU->agent_out.setVariable<float>("x", 500.0f);
        }
  
        // Other agent function code
        ...
    }

If :class:`FLAMEGPU->agent_out<flamegpu::DeviceAPI::AgentOut>` is used in an agent function which has not had agent output enabled, no agent will be created. If ``SEATBELTS`` error checking is enabled, an exception will be raised.

Related Links
-------------

* User Guide Page: :ref:`Defining Agents<Defining Agents>`
* User Guide Page: :ref:`Agent Operations<Host Agent Operations>` (Host Functions)
* User Guide Page: :ref:`What is SEATBELTS?<SEATBELTS>`
* Full API documentation for :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`
* Full API documentation for :class:`AgentOut<flamegpu::DeviceAPI::AgentOut>`
* Full API documentation for :class:`DeviceAPI<flamegpu::DeviceAPI>`
