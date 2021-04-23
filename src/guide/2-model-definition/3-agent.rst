Defining Agents
===============

Agents are the central component of FLAME GPU simulations, and are directly equivalent to agent-based modelling agents. However, 
they can also be used to represent other things such as scalar fields across the environment. Agents are represented by an ``AgentDescription``
object

Defining a New Agent Type
-------------------------
FLAMEGPU2 agents are associated with a particular model. As such they are created via a `ModelDescription` object and are initialised with a name:

.. tabs::
  
  .. code-tab:: python

    # Create a new agent called 'predator' associated the model 'model' 
    predator = model.newAgent("predator")
 
  .. code-tab:: cpp

    // Create a new agent called 'predator' associated the model 'model' 
    AgentDescription &predator = model.newAgent("predator");

Agent Properties
----------------
Agent properties should be used to store data which is unique to each instance of an agent, for example, each individual predator in a predator-prey simulation
would have its own position and hunger level. Each property has a name and a type. For a complete list of supported types, see **TODO: reference page for available types**. 

.. tabs::

  .. code-tab:: python

    # Create two new floating point variables, x and y
    predator.newVariableFloat("x")
    predator.newVariableFloat("y")

    # Create a new integer variable, hungerLevel
    predator.newVariableInt("hungerLevel")

  .. code-tab:: cpp

    // Create two new floating point variables, x and y
    predator.newVariable<float>("x");
    predator.newVariable<float>("y");

    // Create a new integer variable, hungerLevel
    predator.newVariable<int>("hungerLevel");

Agent Array Properties
----------------------
Array properties can also be defined by providing a name and array length:

.. tabs::

  .. code-tab:: python

    # Create an array property called exampleArray which is an array of 3 integers
    predator.newVariableArrayInt("exampleArray", 3)

  .. code-tab:: cpp

    // Create an array property called exampleArray which is an array of 3 integers
    predator.newVariableArray<int>("exampleArray", 3);

Agent States
------------
Agent states are usually used to group sets of behaviours. For example, a predator in a predator-prey simulation may have a resting state and a hunting state.
All newly defined agent types will have a default state, but you can add additional states if you wish to. States can be defined through the 
``AgentDescription`` object:

.. tabs::

  .. code-tab:: python

    # Create two new states, resting and hunting
    predator.newState("resting")
    predator.newState("hunting")

  .. code-tab:: cpp

    // Create two new states, resting and hunting
    predator.newState("resting");
    predator.newState("hunting");
    
Full Example Code From This Page
--------------------------------

.. tabs::

  .. code-tab:: python
    
    # Create a new agent called 'predator' associated the model 'model' 
    predator = model.newAgent("predator")

    # Create two new floating point variables, x and y
    predator.newVariableFloat("x")
    predator.newVariableFloat("y")

    # Create a new integer variable, hungerLevel
    predator.newVariableInt("hungerLevel")

    # Create an array property called exampleArray which is an array of 3 integers
    predator.newVariableArrayInt("exampleArray", 3)

    # Create two new states, resting and hunting
    predator.newState("resting")
    predator.newState("hunting")

  .. code-tab:: cpp

    // Create a new agent called 'predator' associated the model 'model' 
    AgentDescription &predator = model.newAgent("predator");

    // Create two new floating point variables, x and y
    predator.newVariable<float>("x");
    predator.newVariable<float>("y");

    // Create a new integer variable, hungerLevel
    predator.newVariable<int>("hungerLevel");

    // Create an array property called exampleArray which is an array of 3 integers
    predator.newVariableArray<int>("exampleArray", 3);

    // Create two new states, resting and hunting
    predator.newState("resting");
    predator.newState("hunting");

More Info 
---------
* Related User Guide Pages

  * `Interacting with the Environment <../3-behaviour-definition/3-interacting-with-environment.html>`_
  * `Random Number Generation <../8-advanced-sim-management/2-rng-seeds.html>`_

* Full API documentation for the ``EnvironmentDescription``: link
* Examples which demonstrate creating an environment

  * Boids Brute Force (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/boids_bruteforce/src/main.cu>`_)
  * Ensemble (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/ensemble/src/main.cu>`_)