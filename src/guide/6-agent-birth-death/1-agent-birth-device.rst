Agent Birth from Agent Functions
================================

Agent Creation Overview
-----------------------
The agent creation interface usable in agent functions is only able to create a single agent per existing agent per iteration. 
Additionally, the agent type and state being created must be earlier specified as part of the model description. If you need
to create more than one agent for each existing agent, you should use the :ref:`Agent Birth from Host Functions`.

**Note:** *Agents created by agent functions do not exist until the next layer.*

Enabling Agent Creation
-----------------------

To create agents from agent functions, you must specify the type of agent the function produces when defining your agent functions:

.. tabs::

  .. code-tab:: cuda CUDA C++

    // The agent type 'example_agent' is set as the agent output type
    agent_fn1_description.setAgentOutput(example_agent);

  .. code-tab:: python
  
    # The agent type 'example_agent' is set as the agent output type
    agent_fn1_description.setAgentOutput(example_agent)

Creating the New Agent
----------------------

When agent output has been enabled for an agent function, the ``FLAMEGPU->agent_out`` object will become available within agent
function definitions. This can be used to initialise the properties of the newly created agent.

Agent Output from Device:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
      FLAMEGPU_AGENT_FUNCTION(ExampleAgentOutputFn, flamegpu::MessageNone, flamegpu::MessageNone) {
          // The output agent's 'x' variable is set
          FLAMEGPU->agent_out.setVariable<float>("x", 12.0f);
  
          // Other agent function code
          ...
      }

Agent variables which are not manually set will be initialised with their default values.

Conditional Agent Creation
--------------------------

By default, agent creation is mandatory for an agent function which has agent output enabled. If you don't want all the agents the 
function runs for to output an agent, you can enable optional agent output:

.. tabs::

  .. code-tab:: cuda CUDA C++

    // Enable optional agent output
    agent_fn1_description.setAgentOutputOptional(true);

  .. code-tab:: python

    # Enable optional agent output
    agent_fn1_description.setAgentOutputOptional(true)

With this set, a new agent will only be created if one of the ``FLAMEGPU->agent_out`` variables is set manually.
As an example:

.. tabs::
  .. code-tab:: cuda CUDA C++
  
    FLAMEGPU_AGENT_FUNCTION(OptionalOutput, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Fetch this agent's id
        unsigned int id = FLAMEGPU->getVariable<unsigned int>("id");
  
        // If its id is even, output a new agent, otherwise do nothing
        if (id % 2 == 0) {
            // Output a new agent with its 'x' variable set to 500.0f
            FLAMEGPU->agent_out.setVariable<float>("x", 500.0f);
        }
  
        // Other agent function code
        ...
    }

Full Example Code From This Page
--------------------------------



.. tabs::

  .. code-tab:: cuda CUDA C++

    // The agent type 'example_agent' is set as the agent output type
    agent_fn1_description.setAgentOutput(example_agent);

    // Enable optional agent output
    agent_fn1_description.setAgentOutputOptional(true);

    .. code-tab:: python
    
    # The agent type 'example_agent' is set as the agent output type
    agent_fn1_description.setAgentOutput(example_agent)

    # Enable optional agent output
    agent_fn1_description.setAgentOutputOptional(true)




.. tabs::

  .. code-tab:: cuda CUDA C++
  
      FLAMEGPU_AGENT_FUNCTION(ExampleAgentOutputFn, flamegpu::MessageNone, flamegpu::MessageNone) {
          // The output agent's 'x' variable is set
          FLAMEGPU->agent_out.setVariable<float>("x", 12.0f);
  
          // Other agent function code
          ...
      }

      FLAMEGPU_AGENT_FUNCTION(OptionalOutput, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Fetch this agent's id
        unsigned int id = FLAMEGPU->getVariable<unsigned int>("id");
  
        // If its id is even, output a new agent, otherwise do nothing
        if (id % 2 == 0) {
            // Output a new agent with its 'x' variable set to 500.0f
            FLAMEGPU->agent_out.setVariable<float>("x", 500.0f);
        }
  
        // Other agent function code
        ...
      }


More Info 
---------
* Related User Guide Pages

  * `Interacting with the Environment <../3-behaviour-definition/3-interacting-with-environment.html>`_
  * `Random Number Generation <../8-advanced-sim-management/2-rng-seeds.html>`_

* Full API documentation for the ``EnvironmentDescription``: link
* Examples which demonstrate creating an environment

  * Boids Brute Force (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/boids_bruteforce/src/main.cu>`__)
  * Ensemble (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/ensemble/src/main.cu>`__)