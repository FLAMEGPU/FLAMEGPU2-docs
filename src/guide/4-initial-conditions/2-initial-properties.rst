Initialising Agent Variables
============================

Initialising a Population
-------------------------

To initialise a population, iterate over the ``AgentVector`` object and set the variables for each agent:

.. tabs::

  .. code-tab:: cuda CUDA C++

    for (unsigned int i = 0; i < populationSize; i++) {
        flamegpu::AgentVector::Agent instance = population[i];
        instance.setVariable<int>("id", i);
    }

  .. code-tab:: python

    for i, instance in enumerate(population):
        instance.setVariableInt("id", i);
  
Accessing a Single Agent
------------------------

A single agent can be individually accessed by indexing into the ``AgentVector`` object:

.. tabs::

  .. code-tab:: cuda CUDA C++
    
    // Fetch the 23rd agent
    flamegpu::AgentVector::Agent instance = population[23];

    Set its id to 12,000
    instance.setVariable<int>("id", 12000);

  .. code-tab:: python
    
    # Fetch the 23rd agent
    instance = population[23]

    # Set its id to 12,000
    instance.setVariableInt("id", 12000)