Launching a Simulation
======================

To launch a simulation, construct a ``CUDASimulation`` object from the model. You must then initialise it, set the population data and finally call 
its ``simulate`` method:

.. tabs::

  .. code-tab:: cpp
     
    // Create a simulation object from the model
    flamegpu::CUDASimulation simulation(model);

    // Initialise the model with the supplied command line parameters
    simulation.initialise(argc, argv);

    // Set a procedural population
    simulation.setPopulationData(population);

    // Run the simulation
    simulation.simulate();

  .. code-tab:: python

    # Create a simulation object from the model
    simulation = pyflamegpu.CUDASimulation(model)

    # Initialise the model with the supplied command line parameters
    simulation.initialise(sys.argv)

    # Set a procedural population
    simulation.setPopulationData(population)

    # Run the simulation
    simulation.simulate()