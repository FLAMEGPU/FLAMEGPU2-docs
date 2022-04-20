.. _Running a Simulation:

Running a Simulation
====================
Once you have a fully described model, it's time to create and execute a simulation.


In order to execute a model a :class:`CUDASimulation<flamegpu::CUDASimulation>` must be created by passing it your completed :class:`ModelDescription<flamegpu::ModelDescription>`. The :class:`CUDASimulation<flamegpu::CUDASimulation>` then creates it's own copy of the :class:`ModelDescription<flamegpu::ModelDescription>`, so further changes will not affect the simulation.

The simulation can then be executed by calling :func:`simulate()<flamegpu::CUDASimulation::simulate>`:

.. tabs::

  .. code-tab:: cpp C++
  
    // Fully declare a model
    flamegpu::ModelDescription model("example model");
    ...
     
    // Create a simulation object from the model
    flamegpu::CUDASimulation simulation(model);

    // Configure the simulation
    ...
    
    // Run the simulation
    simulation.simulate();

  .. code-tab:: py Python

    # Fully declare a model
    model = pyflamegpu.ModelDescription("example model")
    ...
    
    # Create a simulation object from the model
    simulation = pyflamegpu.CUDASimulation(model)

    # Configure the Simulation
    ...

    # Run the simulation
    simulation.simulate()

This is the most simple case, however normally a simulation needs to be configured, to select simulation option, override the initial state and specify data to be collected.

This chapter has been broken up into several sections detailing these features:

.. toctree::
   :maxdepth: 1
   
   configuring-execution.rst
   initial-state.rst
   collecting-data.rst
   

Additionally, a visualisation can be configured, however that is covered in it's :ref:`own chapter<Visualisation>`.