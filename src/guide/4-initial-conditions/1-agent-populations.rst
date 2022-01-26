Agent Populations
=================
To initialise your model it is necessary to create the initial agent populations. These can either be statically defined in
a flat file, or dynamically generated. This section deals with dynamically generating agents which is the recommended default
method. For information on loading from files, please see :ref:`Initialisation from Disk`

Creating an Agent Population
----------------------------

Populations of agents in FLAMEGPU2 are represented by the ``AgentVector`` type. A population can be created by supplying the
type of agent, and number of agents to create:

.. tabs::

  .. code-tab:: cuda CUDA C++
    
    // Create a population of 1000 'Boid' agents
    const unsigned int populationSize = 1000;
    flamegpu::AgentVector population(model.Agent("Boid"), populationSize);

  .. code-tab:: python
    
    # Create a population of 1000 'Boid' agents
    populationSize = 1000
    population = pyflamegpu.AgentVector(model.Agent("Boid"), populationSize)
