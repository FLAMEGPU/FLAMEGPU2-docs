Initialising Agent Variables
============================

Initialising a Population
-------------------------

To initialise a population, iterate over the ``AgentVector`` object and set the variables for each agent:

** TODO: not very idiomatic - python should use enumerate I think, and range based for for cpp**

.. tabs::

  .. code-tab:: python

    for i in range(populationSize):
        instance = population[i];
        instance.setVariableInt("id", i);
  
  .. code-tab:: cpp

    for (unsigned int i = 0; i < populationSize; i++) {
        AgentVector::Agent instance = population[i];
        instance.setVariable<int>("id", i);
    }

Accessing a Single Agent
------------------------

A single agent can be individually accessed by indexing into the ``AgentVector`` object:

.. tabs::

  .. code-tab:: python
    
    # Fetch the 23rd agent
    instance = population[23]

    # Set its id to 12,000
    instance.setVariableInt("id", 12000)

  .. code-tab:: cpp
    
    // Fetch the 23rd agent
    AgentVector::Agent instance = population[23];

    Set its id to 12,000
    instance.setVariable<int>("id", 12000);