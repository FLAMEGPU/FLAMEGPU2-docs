.. _Collecting Data:

Collecting Data
===============

Configuring Data to be Collected
--------------------------------

As Simulations are likely to involve thousands to millions of agents, logging the full simulation state would produce large amounts of output most of which is not required. As such, FLAMEGPU provides the ability to specify a subset of population level reductions and environment properties to be logged each step or at simulation exit.

To define a logging config, you should declare either a ``LoggingConfig`` or ``StepLoggingConfig``, passing your ``ModelDescription`` to the constructor. These two classes share the same interface for specifying data to be logged, however ``StepLoggingConfig`` additionally allows you specify ``setLoggingFrequency()`` to adjust how often steps are logged (default 1, every step).

Environment properties are logged with ``logEnvironment()``, specifying the property's name

Agent data is logged according to agent state, so agent's with multiple states must have the config specified for each state required to be logged. The total number of agents in the state can be logged with ``logCount()``. Or variable reductions can be logged with; ``logMean()``, ``logStandardDev()``, ``logMin()``, ``logMax()``, ``logSum()`` specifying the variable's name and type (in the same form as used throughout the API).

.. tabs::

  .. code-tab:: cuda CUDA C++
    
    
    flamegpu::ModelDescription model("example model");
    
    ... // Fully define the model
    
    // Specify the desired LoggingConfig or StepLoggingConfig
    flamegpu::StepLoggingConfig step_log_cfg(model);
    {
        // Log every step (not available to LoggingConfig, for exit logs)
        step_log_cfg.setFrequency(1);
        // Include the environment property 'env_prop' in the logged data
        step_log_cfg.logEnvironment("env_prop");
        // Include the current number of 'boid' agents, within the default state
        step_log_cfg.agent("boid").logCount();
        // Include the current number of 'boid' agents, within the 'alive' state
        step_log_cfg.agent("boid", "alive").logCount();
        // Include the mean of the boid agent population's variable 'speed', within the default state
        step_log_cfg.agent("boid").logMean<float>("speed");
        // Include the standard deviation of the boid agent population's variable 'speed', within the default state
        step_log_cfg.agent("boid").logStandardDev<float>("speed");
        // Include the min and max of the boid agent population's variable 'speed', within the default state
        step_log_cfg.agent("boid").logMin<float>("speed");
        step_log_cfg.agent("boid").logMax<float>("speed");
        // Include the sum of the boid agent population's variable 'health', within the 'alive' state
        step_log_cfg.agent("boid").logSum<int>("health");
    }
    
    // Create the CUDASimulation instance
    flamegpu::CUDASimulation cuda_sim(model, argc, argv);
    
    // Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg);
    // cuda_sim.setExitLog(exit_log_cfg);
    
    // Run the simulation as normal
    cuda_sim.simulate();

  .. code-tab:: python    
    
    model = pyflamegpu.ModelDescription("example model")
    
    ... # Fully define the model
    
    # Specify the desired LoggingConfig or StepLoggingConfig
    step_log_cfg = flamegpu.StepLoggingConfig(model)
    # Log every step (not available to LoggingConfig, for exit logs)
    step_log_cfg.setFrequency(1)
    # Include the environment property 'env_prop' in the logged data
    step_log_cfg.logEnvironment("env_prop")
    # Include the current number of 'boid' agents, within the default state
    step_log_cfg.agent("boid").logCount()
    # Include the current number of 'boid' agents, within the 'alive' state
    step_log_cfg.agent("boid", "alive").logCount()
    # Include the mean of the boid agent population's variable 'speed', within the default state
    step_log_cfg.agent("boid").logMeanFloat("speed")
    # Include the standard deviation of the boid agent population's variable 'speed', within the default state
    step_log_cfg.agent("boid").logStandardDevFloat("speed")
    # Include the min and max of the boid agent population's variable 'speed', within the default state
    step_log_cfg.agent("boid").logMinFloat("speed")
    step_log_cfg.agent("boid").logMaxFloat("speed")
    # Include the sum of the boid agent population's variable 'health', within the 'alive' state
    step_log_cfg.agent("boid").logSumInt("health")
    
    # Create the CUDASimulation instance
    cuda_sim = flamegpu.CUDASimulation(model, sys.argv)
    
    # Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg)
    # cuda_sim.setExitLog(exit_log_cfg)
    
    # Run the simulation as normal
    cuda_sim.simulate()


Accessing Collected Data
------------------------

After configuring a ``CUDASimulation`` to use specific logging configs, and executing the simulation, the log can be accessed via code using ``getRunLog()``. This returns a structure combining the step and exit logs that were requested.

.. tabs::

  .. code-tab:: cuda CUDA C++
    
    // Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg);
    // cuda_sim.setExitLog(exit_log_cfg);
    
    // Run the simulation as normal
    cuda_sim.simulate();
    
    // Fetch the logged data
    flamegpu::RunLog run_log = cuda_sim.getRunLog();
    
    // Get the random seed used
    uint64_t rng_seed = run_log.getRandomSeed();
    // Get the step logging frequency
    unsigned int step_log_freqency = run_log.getStepLogFrequency();
    
    // Access the step and exit log data
    // The step and exit logs will be empty, if a respective logging config was not specified.
    flamegpu::LogFrame exit_log = run_log.getExitLog();
    std::list<flamegpu::LogFrame> step_log = run_log.getStepLog();
    
    // Iterate the step log and print some information to console
    for (auto &log:step_log) {
        // Get the step index
        unsigned int step_count = log.getStepCount();
        // Get a logged environment property
        int env_prop = log.getEnvironmentProperty<int>("env_prop");
        // Get logged boid agent property reduction data, from the default state
        unsigned int agent_count = log.getAgent("boid").getCount();
        // Reduce operators upcast the return type to the most suitable to not lose data
        double agent_speed_mean = log.getAgent("boid").getMean("speed");
        // Print data to console
        printf("#%u: %u, %f\n", step+count, agent_count, agent_speed_mean);
    }

  .. code-tab:: python
  
    # Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg)
    # cuda_sim.setExitLog(exit_log_cfg)
    
    # Run the simulation as normal
    cuda_sim.simulate()
    
    # Fetch the logged data
    run_log = cuda_sim.getRunLog();
    
    # Get the random seed used
    rng_seed = run_log.getRandomSeed();
    # Get the step logging frequency
    step_log_freqency = run_log.getStepLogFrequency();
    
    # Access the step and exit log data
    # The step and exit logs will be empty, if a respective logging config was not specified.
    exit_log = run_log.getExitLog();
    step_log = run_log.getStepLog();
    
    # Iterate the step log and print some information to console
    for log in step_log:
        # Get the step index
        unsigned int step_count = log.getStepCount();
        # Get a logged environment property
        int env_prop = log.getEnvironmentPropertyInt("env_prop")
        # Get logged boid agent property reduction data, from the default state
        unsigned int agent_count = log.getAgent("boid").getCount()
        # Reduce operators upcast the return type to the most suitable to not lose data
        double agent_speed_mean = log.getAgent("boid").getMean("speed")
        # Print data to console
        print("#%u: %u, %f"%(step+count, agent_count, agent_speed_mean))
        

Writing Collected Data to File
------------------------------

Instead of processing logged data at runtime, you can store it to file for post-processing at a later time.

This is achieved by specifying output path configuration arguments, either via the command line at runtime or in code.

In order to pass arguments via the command line, it is necessary to ensure that command line args (``argc``, ``argv``) are passed to ``CUDASimulation``, either the constructor or to `initialise()`.

The command line arguments available related to logging:

========================== ================== ============================
Long Argument              Short Argument     Description
========================== ================== ============================
``--out-step`` <file path> n/a                Path to a JSON/XML file to store step logging data.
``--out-exit`` <file path> n/a                Path to a JSON/XML file to store exit logging data.
``--out-log`` <file path>  n/a                Path to a JSON/XML file to store both step and exit logging data.
========================== ================== ============================

Alternatively, these options can be configured in code:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    ...
    
    // Manually configure the simulation config
    sim_cfg = cuda_sim.SimulationConfig();
    sim_cfg.step_log_file = "step_log.json";
    sim_cfg.exit_log_file = "exit_log.json";
    sim_cfg.common_log_file = "some_directory/common_log.xml";
    sim_cfg.truncate_log_files = True; // This is the default setting
    
    // Notify the simulation that you have updated the config
    // This is not always required, in this case it will only create subdirectories that are missing
    cuda_sim.applyConfig();
    
    // Run the simulation as normal
    cuda_sim.simulate();
    
    // Logged data should be written to file when simulate() returns

  .. code-tab:: python
  
    ...
  
    # Manually configure the simulation config
    sim_cfg = cuda_sim.SimulationConfig()
    sim_cfg.step_log_file = "step_log.json"
    sim_cfg.exit_log_file = "exit_log.json"
    sim_cfg.common_log_file = "some_directory/common_log.xml"
    sim_cfg.truncate_log_files = True # This is the default setting
    
    # Notify the simulation that you have updated the config
    # This is not always required, in this case it will only create subdirectories that are missing
    cuda_sim.applyConfig()
    
    # Run the simulation as normal
    cuda_sim.simulate()
    
    # Logged data should be written to file when simulate() returns


Accessing the Complete Agent State
----------------------------------

In some limited cases, you may want to directly access a full agent population. This can only be achieved in code, either directly accessing the agent data or specifying that it should be sent to file.


Similar to specifying an initial agent population, you can fetch an agent population.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    flamegpu::ModelDescription model("example model");
    flamegpu::AgentDescription &boid_agent = model.newAgent("boid");
    
    ... // Fully define the model
    
    ... // Setup the CUDASimulation
    
    // Run the simulation as normal
    // step() could also be used to access the agent state, on a per step basis
    cuda_sim.simulate();
    
    // Copy the boid agent data, from the default state, to an agent vector
    flamegpu::AgentVector out_pop(boid_agent);
    cuda_sim.getPopulationData(out_pop);
    
    // Iterate the agents, and print their speed
    for (auto &boid : out_pop) {
        printf("Speed: %f\n", boid.getVariable<float>("speed"));
    }
    
  .. code-tab:: python
  
    model = pyflamegpu.ModelDescription("example model");
    boid_agent = model.newAgent("boid");
    
    ... # Fully define the model
    
    ... # Setup the CUDASimulation
    
    # Run the simulation as normal
    # step() could also be used to access the agent state, on a per step basis
    cuda_sim.simulate()
    
    # Copy the boid agent data, from the default state, to an agent vector
    flamegpu::AgentVector out_pop(boid_agent)
    cuda_sim.getPopulationData(out_pop)
    
    # Iterate the agents, and print their speed
    for boid in out_pop:
        print("Speed: %f"%(boid.getVariableFloat("speed"))

Alternatively, ``exportData()`` can be called to export the full simulation state to file (agent variables and environment properties).

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    flamegpu::ModelDescription model("example model");
    flamegpu::AgentDescription &boid_agent = model.newAgent("boid");
    
    ... // Fully define the model
    
    ... // Setup the CUDASimulation
    
    // Run the simulation as normal
    // step() could also be used to access the agent state, on a per step basis
    cuda_sim.simulate();
    
    // Log the simulation state to JSON/XML file
    cuda_sim.exportData("end.json");
    
  .. code-tab:: python
  
    model = pyflamegpu.ModelDescription("example model");
    boid_agent = model.newAgent("boid");
    
    ... # Fully define the model
    
    ... # Setup the CUDASimulation
    
    # Run the simulation as normal
    # step() could also be used to access the agent state, on a per step basis
    cuda_sim.simulate()
    
    # Log the simulation state to JSON/XML file
    cuda_sim.exportData("end.json")

Additional Notes
----------------

At the time of writing it is not possible to log Environment Macro Properties, doing so would require manually outputting them via an init, step or exit function.