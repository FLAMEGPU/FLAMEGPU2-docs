.. _Configuring Execution:

Configuring Execution
=====================

The ``CUDASimulation`` instance provides a range of configuration options which can be controlled directly in code, or via the command line interface. The below table details the variables available in code, and the arguments available to the command line interface.

====================== ========================== ================== ============================
Config Variable        Long Argument              Short Argument     Description
====================== ========================== ================== ============================
``input_file``         ``--in <file path>``       ``-i <file path>`` Path to a JSON/XML file to read the input state (agent/environment data).
``step_log_file``      ``--out-step <file path>`` n/a                Path to a JSON/XML file to store step logging data.
``exit_log_file``      ``--out-exit <file path>`` n/a                Path to a JSON/XML file to store exit logging data.
``common_log_file``    ``--out-log <file path>``  n/a                Path to a JSON/XML file to store both step and exit logging data.
``truncate_log_files`` n/a                        n/a                If true, log files will overwrite any pre-existing file with the same path/name. Default value true.
``random_seed``        ``--random <int>``         ``-r <int>``       Random seed. Default value is sample from the clock (e.g. it will change each run).
``steps``              ``--steps <int>``          ``-s <int>``       Number of simulation steps to execute. 0 will run indefinitely, or until an exit function causes the simulation to end. Default value 1.    
``verbose``             ``--verbose``             ``-v``             Enable verbose simulation output to console. Default value false.
``timing``              ``--timing``              ``-t``             Output simulation timing detail to console. Default value false.
``console_mode``        ``--console``             ``-c``             Visualisation builds only, disable the visualisation. Default value false.
``device_id``           ``--device <device id>``  ``-d <device id>`` The CUDA device id of the GPU to use. Default value 0 (Note this is found within ``CUDAConfig()``)
``inLayerConcurrency``  n/a                       n/a                Enables the use of concurrency within layers. Default value true. (Note this is found within ``CUDAConfig()``)
n/a                     ``--help``                ``-h`              Print help for the command line interface and exit
======================= ========================= ================== ============================

In order for the command line arguments to be processed ``argc`` and ``argv`` must be passed to ``initialise()``. An example of this is shown below.

.. tabs::

  .. code-tab:: cuda CUDA C++
     
    // Create a simulation object from the model
    flamegpu::CUDASimulation simulation(model);
    
    // Initialise the model with the supplied command line parameters
    simulation.initialise(argc, argv);
    
    // Run the simulation
    simulation.simulate();

  .. code-tab:: python

    # Create a simulation object from the model
    simulation = pyflamegpu.CUDASimulation(model)
    
    # Initialise the model with the supplied command line parameters
    simulation.initialise(sys.argv)

    # Run the simulation
    simulation.simulate()


To configure the simulation in code the variables must be updated via the ``SimulationConfig()`` and ``CUDAConfig()`` structures. Subsequently ``applyConfig()`` must be called, to implement any changes to the configuration. A short example of this workflow is shown below.


.. note ::
  At current, unlike ``CUDAEnsemble`` it is not possible to configure defaults to the ``CUDASimulation`` command line interface. Calling ``initialise()`` will reset the configuration before parsing command line arguments. `(issue) <https://github.com/FLAMEGPU/FLAMEGPU2/issues/755>`_.

.. tabs::

  .. code-tab:: cuda CUDA C++
     
    // Create a simulation object from the model
    flamegpu::CUDASimulation simulation(model);
    
    // Update the configuration
    simulation.SimulationConfig().steps = 100;
    simulation.SimulationConfig().input_file = "input.json";
    simulation.CUDAConfig().device = 1;

    // Apply the updated configuration
    simulation.applyConfig();
    
    // Run the simulation
    simulation.simulate();

  .. code-tab:: python

    # Create a simulation object from the model
    simulation = pyflamegpu.CUDASimulation(model)
    
    # Update the configuration
    simulation.SimulationConfig().steps = 100
    simulation.SimulationConfig().input_file = "input.json"
    simulation.CUDAConfig().device = 1

    # Apply the updated configuration
    simulation.applyConfig()

    # Run the simulation
    simulation.simulate()