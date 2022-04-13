.. _Configuring Execution:

Configuring Execution
=====================

The :class:`CUDASimulation<flamegpu::CUDASimulation>` instance provides a range of configuration options which can be controlled directly in code, or via the command line interface. The below table details the variables available in code, and the arguments available to the command line interface.

======================= ========================== ================== ====================================================================================
Config Variable         Long Argument              Short Argument     Description
======================= ========================== ================== ====================================================================================
``input_file``          ``--in <file path>``       ``-i <file path>`` Path to a JSON/XML file to read the input state (agent/environment data). See the :ref:`File Format Guide<Initial State From File>`
``step_log_file``       ``--out-step <file path>`` n/a                Path to a JSON/XML file to store step logging data.
``exit_log_file``       ``--out-exit <file path>`` n/a                Path to a JSON/XML file to store exit logging data.
``common_log_file``     ``--out-log <file path>``  n/a                Path to a JSON/XML file to store both step and exit logging data.
``truncate_log_files``  n/a                        n/a                If true, log files will overwrite any pre-existing file with the same path/name. Default value true.
``random_seed``         ``--random <int>``         ``-r <int>``       Random seed. Default value is sample from the clock (e.g. it will change each run).
``steps``               ``--steps <int>``          ``-s <int>``       Number of simulation steps to execute. 0 will run indefinitely, or until an exit function causes the simulation to end. Default value 1.    
``verbose``             ``--verbose``              ``-v``             Enable verbose simulation output to console. Default value false.
``timing``              ``--timing``               ``-t``             Output simulation timing detail to console. Default value false.
``console_mode``        ``--console``              ``-c``             Visualisation builds only, disable the visualisation. Default value false.
``device_id``           ``--device <device id>``   ``-d <device id>`` The CUDA device id of the GPU to use. Default value 0 (Note this is found within :class:`CUDASimulation::Config<flamegpu::CUDASimulation::Config>`)
``inLayerConcurrency``  n/a                        n/a                Enables the use of concurrency within layers. Default value ``true``. (Note this is found within :class:`CUDASimulation::Config<flamegpu::CUDASimulation::Config>`)
n/a                     ``--help``                 ``-h``             Print help for the command line interface and exit.
======================= ========================== ================== ====================================================================================

In order for the command line arguments to be processed ``argc`` and ``argv`` (Python: ``argv`` only) must be passed to :func:`initialise()<flamegpu::Simulation::initialise>`.

.. tabs::

  .. code-tab:: cpp C++

    int main(int argc, const char **argv) {
    
        ...
        
        // Create a simulation object from the model
        flamegpu::CUDASimulation simulation(model);
        
        // Initialise the model with the supplied command line parameters
        simulation.initialise(argc, argv);
        
        // Run the simulation
        simulation.simulate();
        
        ...

  .. code-tab:: py Python
  
    # Import sys to access argv
    import sys

    # Create a simulation object from the model
    simulation = pyflamegpu.CUDASimulation(model)
    
    # Initialise the model with the supplied command line parameters
    simulation.initialise(sys.argv)

    # Run the simulation
    simulation.simulate()


To configure the simulation in code the variables must be updated via the :class:`Simulation::Config<flamegpu::Simulation::Config>` and :class:`CUDASimulation::Config<flamegpu::CUDASimulation::Config>` structures, these are accessed via :func:`SimulationConfig()<flamegpu::Simulation::SimulationConfig>` and :func:`CUDAConfig()<flamegpu::CUDASimulation::CUDAConfig>` respectively on the :class:`CUDASimulation<flamegpu::CUDASimulation>` instance. Subsequently :func:`applyConfig()<flamegpu::Simulation::applyConfig>` must be called, to implement any changes to the configuration.


.. note ::
  At current, unlike :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>`, it is not possible to configure defaults to the :class:`CUDASimulation<flamegpu::CUDASimulation>` command line interface. Calling :func:`initialise()<flamegpu::Simulation::initialise>` resets the configuration before parsing command line arguments. `(issue) <https://github.com/FLAMEGPU/FLAMEGPU2/issues/755>`_

.. tabs::

  .. code-tab:: cpp C++
     
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

  .. code-tab:: py Python

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

Related Links
-------------
* User Guide: :ref:`Initial State From File<Initial State From File>`
* Full API documentation for :class:`CUDASimulation<flamegpu::CUDASimulation>`
* Full API documentation for :class:`Simulation<flamegpu::Simulation>`
* Full API documentation for :class:`Simulation::Config<flamegpu::Simulation::Config>`
* Full API documentation for :class:`CUDASimulation::Config<flamegpu::CUDASimulation::Config>`