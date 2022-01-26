Creating a Simulation
======================

In order to execute a model a ``CUDASimulation`` object from the model. You can then initialise it, set the population data and finally calling ``simulate()`` will execute the model:

.. tabs::

  .. code-tab:: cuda CUDA C++
     
    // Create a simulation object from the model
    flamegpu::CUDASimulation simulation(model);

    // Optionally specify an initial agent population (1 call per agent type)
    // Loading this before the call to initialise, will allow input file to override
    simulation.setPopulationData(population);

    // Initialise the model with the supplied command line parameters
    simulation.initialise(argc, argv);
    
    // Run the simulation
    simulation.simulate();

  .. code-tab:: python

    # Create a simulation object from the model
    simulation = pyflamegpu.CUDASimulation(model)

    # Optionally specify an initial agent population (1 call per agent type)
    # Loading this before the call to initialise, will allow input file to override
    simulation.setPopulationData(population)
    
    # Initialise the model with the supplied command line parameters
    simulation.initialise(sys.argv)

    # Run the simulation
    simulation.simulate()