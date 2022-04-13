Overriding the Initial State
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When executing a FLAME GPU model its common to wish to override parts of the initial environment or provide a predefined agent population.

With Code
---------

Overriding initial states in code is more flexible than from state files, allowing dynamic control of the initial state. For example it could be used execute models as part of a genetic algorithm.


.. _RunPlan:
Overriding the Initial Environment
==================================

The recommended method to override the initial state of a model is by executing it using a :class:`RunPlan<flamegpu::RunPlan>`.

This class allows you to configure a collection of environment property overrides. It can then be passed to :func:`simulate()<void flamegpu::CUDASimulation::simulate(const RunPlan &)>`, to execute the model using the provided overrides.

:class:`RunPlan<flamegpu::RunPlan>` provides :func:`setProperty()<flamegpu::RunPlan::setProperty>` in the same format as elsewhere in FLAME GPU, to set the overrides.
    
Additionally a :class:`RunPlan<flamegpu::RunPlan>` holds the number of simulation steps and random seed to be used for the simulation, these replace any configuration specified via command-line or by manually setting the configs so they should normally be configured using :func:`setRandomSimulationSeed()<flamegpu::RunPlan::setRandomSimulationSeed>` and :func:`setSteps()<flamegpu::RunPlan::setSteps>` respectively.
    
.. tabs::

  .. code-tab:: cpp C++
  
    // Create a RunPlan to override the initial environment
    flamegpu::RunPlan plan(model);
    plan.setRandomSimulationSeed(123456);
    plan.setSteps(3600);
    plan.setProperty<float>("speed", 12.0f);
    plan.setProperty<float, 3>("origin", {5.0f, 0.0f, 5.0f});
  
    // Create a simulation object from the model
    flamegpu::CUDASimulation simulation(model);

    // Configure the simulation
    ...
    
    // Run the simulation using the overrides from the RunPlan
    simulation.simulate(plan);

  .. code-tab:: py Python

    # Create a RunPlan to override the initial environment
    plan = pyflamegpu.RunPlan(model)
    plan.setRandomSimulationSeed(123456)
    plan.setSteps(3600)
    plan.setPropertyFloat("speed", 12.0)
    plan.setPropertyArrayFloat("origin", 3, [5.0, 0.0, 5.0])
    
    # Create a simulation object from the model
    simulation = pyflamegpu.CUDASimulation(model)

    # Configure the Simulation
    ...

    # Run the simulation using the overrides from the RunPlan
    simulation.simulate(plan)
    
.. note::

  The Python method ``RunPlan::setPropertyArray()`` currently requires the second argument of array length, this is inconsistent with other uses. `(issue) <https://github.com/FLAMEGPU/FLAMEGPU2/issues/831>`_
    
Alternate Technique
~~~~~~~~~~~~~~~~~~~

You can also directly override the value of environment properties, by calling :func:`setEnvironmentProperty()<flamegpu::CUDASimulation::setEnvironmentProperty>` directly on the :class:`CUDASimulation<flamegpu::CUDASimulation>` instance. Again, these methods have the same usage as ``setProperty()`` found in :class:`RunPlan<flamegpu::RunPlan>`, :class:`HostEnvironment<flamegpu::HostEnvironment>` and elsewhere.

This allows finer grained control than a :class:`RunPlan<flamegpu::CUDASimulation>`, as it can be called at any time to modify the current simulation state (e.g. if stepping the model manually, you could call it between steps).

.. tabs::

  .. code-tab:: cpp C++
  
    // Create a simulation object from the model
    flamegpu::CUDASimulation simulation(model);
    
    // Override some environment properties
    simulation.setEnvironmentProperty<float>("speed", 12.0f);
    simulation.setEnvironmentProperty<float, 3>("origin", {5.0f, 0.0f, 5.0f});

    // Configure the remainder of the simulation
    ...
    
    // Run the simulation using the overrides from the RunPlan
    simulation.simulate(plan);

  .. code-tab:: py Python
    
    # Create a simulation object from the model
    simulation = pyflamegpu.CUDASimulation(model)

    # Create a RunPlan to override the initial environment
    simulation.setEnvironmentPropertyFloat("speed", 12.0)
    simulation.setEnvironmentPropertyArrayFloat("origin", [5.0, 0.0, 5.0])
    
    # Configure the remainder of the Simulation
    ...

    # Run the simulation using the overrides from the RunPlan
    simulation.simulate(plan)


Setting Initial Agent Populations
=================================

If you are unable to generate your agent populations within an initialisation function, as detailed in :ref:`Host Agent Creation<Host Agent Creation>`, you can create an :class:`AgentVector<flamegpu::AgentVector>` for each agent state population and pass them to the :class:`CUDASimulation<flamegpu::CUDASimulation>`.


An :class:`AgentVector<flamegpu::AgentVector>` is created by passing it's constructor an :class:`AgentDescription<flamegpu::AgentDescription>` and optionally the initial size of the vector which will create the specified number of default initialised agents.

The interface :class:`AgentVector<flamegpu::AgentVector>` is modelled after C++'s ``std::vector``, with elements of type :class:`AgentVector::Agent<flamegpu::AgentVector_Agent>`. However, internally data is stored in a structure-of-arrays format.  

:class:`AgentVector::Agent<flamegpu::AgentVector_Agent>` then has the standard :func:`setVariable()<flamegpu::AgentVector_Agent::setVariable>` and :func:`getVariable()<flamegpu::AgentVector_CAgent::getVariable>` methods found elsewhere in the library.

Once the :class:`AgentVector<flamegpu::AgentVector>` is ready, it can be passed to :func:`setPopulationData()<flamegpu::CUDASimulation::setPopulationData>` on the :class:`CUDASimulation<flamegpu::CUDASimulation>`. If your are using multiple agent states, it is also necessary to specify the desired agent state as the second argument.

.. tabs::

  .. code-tab:: cpp C++
    
    // Create a population of 1000 'Boid' agents
    flamegpu::AgentVector population(model.Agent("Boid"), 1000);
    
    // Manually initialise the "speed" variable in each agent
    for (flamegpu::AgentVector::Agent &instance : population) {
        instance.setVariable<float>("speed", 1.0f);
    }
    
    // Specifically set the 12th agent's variable differently
    population[11].setVariable<float>("speed", 0.0f);
    
    // Set the "Boid" population in the default state with the AgentVector
    simulation.setPopulationData(population);
    // Set the "Boid" population in the "healthy" state with the AgentVector
    // simulation.setPopulationData(population, "healthy");
  .. code-tab:: py Python
    
    # Create a population of 1000 'Boid' agents
    population = pyflamegpu.AgentVector(model.Agent("Boid"), 1000)
    
    for instance in population:
        instance.setVariableFloat("speed", 1.0)
        
    # Specifically set the 12th agent's variable differently
    population[11].setVariableFloat("speed", 0.0)
    
    # Set the "Boid" population in the default state with the AgentVector
    simulation.setPopulationData(population)
    # Set the "Boid" population in the "healthy" state with the AgentVector
    # simulation.setPopulationData(population, "healthy")
        
    
.. _Initial State From File:
From File
---------

FLAME GPU 2 simulations can be initialised from disk using either the XML or JSON format. The XML format is compatible with the previous FLAME GPU 1 input/output files, whereas the JSON format is new to FLAME GPU 2. In both cases, the input and output file formats are the same.

Loading simulation state (agent data and environment properties) from file can be achieved via either command line specification, or explicit specification within the code for the model. (See the :ref:`previous section<Configuring Execution>` for more information)

In most cases, the input file will be taken from command line which can be passed using ``-i <input file>``.

Agent IDs must be unique when the file is loaded from disk, otherwise an ``AgentIDCollision`` exception will be thrown. This must be corrected in the input file, as there is no method to do so within FLAME GPU at runtime.

In most cases, components of the input file are optional and can be omitted if defaults are preferred. If agents are not assigned IDs within the input file, they will be automatically generated.

Simulation state output files produces by FLAME GPU are compatible for use as input files. However, if working with large agent populations they are likely to be prohibitively large due to their human-readable format.


File Format
===========

=================== ============================================================================================
Block               Description
=================== ============================================================================================
``itno``            **XML Only** This block provides the step number in XML output files, it is included for backwards compatibility with FLAMEGPU 1. It has no use for input.
``config``          This block is split into sub-blocks ``simulation`` and ``cuda``, the members of each sub-block align with :class:`Simulation::Config<flamegpu::Simulation::Config>` and :class:`CUDASimulation::Config<flamegpu::CUDASimulation::Config>` members of the same name respectively. These values are output to log the configuration, and can optionally be used to set the configuration via input file. (See the :ref:`Configuring Execution` guide for details of each individual member)
``stats``           This block includes statistics collected by FLAME GPU 2 during execution. It has no purpose on input.
``environment``     This block includes members of the environment, and can be used to configure the environment via input file. Members which begin with ``_`` are automatically created internal properties, which can be set via input file.
``xagent``          **XML Only** Each ``xagent`` block represents a single agent, and the ``name`` and ``state`` values must match an agent state within the loaded model description hierarchy. Members which begin with ``_`` are automatically created internal variables, which can be set via input file.
``agents``          **JSON Only** Within the ``agents`` block, a sub block may exist for each agent type, and within this a sub-block for each state type. Each state then maps to an array of object, where each object consists of a single agent's variables. Members which begin with ``_`` are automatically created internal variables, which can be set via input file.
=================== ============================================================================================

The below code block displays example files output from FLAME GPU 2 in both XML and JSON formats, which could be used as input files.

.. tabs::

  .. code-tab:: xml XML

    <states>
        <itno>100</itno>
        <config>
            <simulation>
                <input_file></input_file>
                <step_log_file></step_log_file>
                <exit_log_file></exit_log_file>
                <common_log_file></common_log_file>
                <truncate_log_files>true</truncate_log_files>
                <random_seed>1643029170</random_seed>
                <steps>1</steps>
                <verbose>false</verbose>
                <timing>false</timing>
                <console_mode>false</console_mode>
            </simulation>
            <cuda>
                <device_id>0</device_id>
                <inLayerConcurrency>true</inLayerConcurrency>
            </cuda>
        </config>
        <stats>
            <step_count>100</step_count>
        </stats>
        <environment>
            <repulse>0.05</repulse>
            <_stepCount>1</_stepCount>
        </environment>
        <xagent>
            <name>Circle</name>
            <state>default</state>
            <_auto_sort_bin_index>0</_auto_sort_bin_index>
            <_id>241</_id>
            <drift>0.0</drift>
            <x>0.8293430805206299</x>
            <y>1.5674132108688355</y>
            <z>14.034683227539063</z>
        </xagent>
        <xagent>
            <name>Circle</name>
            <state>default</state>
            <_auto_sort_bin_index>0</_auto_sort_bin_index>
            <_id>242</_id>
            <drift>0.0</drift>
            <x>23.089038848876954</x>
            <y>24.715721130371095</y>
            <z>2.3497250080108644</z>
        </xagent>
    </states>


  .. code-tab:: json JSON
  
    {
      "config": {
        "simulation": {
          "input_file": "",
          "step_log_file": "",
          "exit_log_file": "",
          "common_log_file": "",
          "truncate_log_files": true,
          "random_seed": 1643029117,
          "steps": 1,
          "verbose": false,
          "timing": false,
          "console_mode": false
        },
        "cuda": {
          "device_id": 0,
          "inLayerConcurrency": true
        }
      },
      "stats": {
        "step_count": 100
      },
      "environment": {
        "repulse": 0.05,
        "_stepCount": 1
      },
      "agents": {
        "Circle": {
          "default": [
            {
              "_auto_sort_bin_index": 0,
              "_id": 241,
              "drift": 0.0,
              "x": 0.8293430805206299,
              "y": 1.5674132108688355,
              "z": 14.034683227539063
            },
            {
              "_auto_sort_bin_index": 168,
              "_id": 242,
              "drift": 0.0,
              "x": 23.089038848876954,
              "y": 24.715721130371095,
              "z": 2.3497250080108644
            }
          ]
        }
      }
    }


Related Links
-------------
* User Guide Page: :ref:`Configuring Execution<Configuring Execution>`
* Full API documentation for :class:`RunPlan<flamegpu::RunPlan>`
* Full API documentation for :class:`AgentVector<flamegpu::AgentVector>` (``AgentVector::Agent``)
* Full API documentation for :class:`AgentVector::Agent<flamegpu::AgentVector_Agent>`
* Full API documentation for :class:`AgentVector::CAgent<flamegpu::AgentVector_CAgent>` (Read-only superclass of :class:`AgentVector::Agent<flamegpu::AgentVector_Agent>`)
* Full API documentation for :class:`CUDASimulation<flamegpu::CUDASimulation>`