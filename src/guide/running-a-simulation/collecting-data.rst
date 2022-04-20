.. _Collecting Data:

Collecting Data
^^^^^^^^^^^^^^^

After your simulation has completed, you probably want to get some data back. FLAME GPU provides two methods of achieving this: Logging which can reduce a large simulation state down to the most important data points, and export of the entire simulation state.

Logging
-------

As Simulations are likely to involve thousands to millions of agents, logging the full simulation state would produce large amounts of output most of which is not required. As such, FLAME GPU provides the ability to specify a collection of population level reductions and environment properties to be logged each step or at simulation exit.

.. _Configuring Data to be Logged:

Configuring Data to be Logged
=============================

To define a logging config, you should create either a :class:`LoggingConfig<flamegpu::LoggingConfig>` or :class:`StepLoggingConfig<flamegpu::StepLoggingConfig>`, passing your :class:`ModelDescription<flamegpu::ModelDescription>` to the constructor. These two classes share the same interface for specifying data to be logged, however :class:`StepLoggingConfig<flamegpu::StepLoggingConfig>` additionally allows you to call :func:`setFrequency()<flamegpu::StepLoggingConfig::setFrequency>` to adjust how often steps are logged (default 1, every step).

Environment properties are logged with :func:`logEnvironment()<flamegpu::LoggingConfig::logEnvironment>`, specifying the property's name. Unlike most FLAME GPU variable and property methods, the type does not need to be specified here.

Agent data is logged according to agent state, so agent's with multiple states must have the config specified for each state required to be logged. The total number of agents in the state can be logged with :func:`logCount()<flamegpu::AgentLoggingConfig::logCount>`. Or variable reductions can be logged with; :func:`logMean()<flamegpu::AgentLoggingConfig::logMean>`, :func:`logStandardDev()<flamegpu::AgentLoggingConfig::logStandardDev>`, :func:`logMin()<flamegpu::AgentLoggingConfig::logMin>`, :func:`logMax()<flamegpu::AgentLoggingConfig::logMax>`, :func:`logSum()<flamegpu::AgentLoggingConfig::logSum>` specifying the variable's name and type (in the same form as used throughout the API).

Once setup, the logging configs are passed to the :class:`CUDASimulation<flamegpu::CUDASimulation>` using :func:`setStepLog()<flamegpu::CUDASimulation::setStepLog>` and :func:`setExitLog()<flamegpu::CUDASimulation::setExitLog>`.

.. tabs::

  .. code-tab:: cpp C++
    
    
    flamegpu::ModelDescription model("example model");
    
    // Fully define the model
    ... 
    
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
        // Include the mean of the boid agents population's variable 'speed', within the default state
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
    flamegpu::CUDASimulation cuda_sim(model);
    
    // Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg);
    // cuda_sim.setExitLog(exit_log_cfg);
    
    // Run the simulation as normal
    cuda_sim.simulate();

  .. code-tab:: py Python    
    
    model = pyflamegpu.ModelDescription("example model")
    
    # Fully define the model
    ...
    
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
    cuda_sim = flamegpu.CUDASimulation(model)
    
    # Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg)
    # cuda_sim.setExitLog(exit_log_cfg)
    
    # Run the simulation as normal
    cuda_sim.simulate()


Accessing Collected Data
========================

After configuring a :class:`CUDASimulation<flamegpu::CUDASimulation>` to use specific logging configs, and executing the simulation, the log can be accessed via code using :func:`getRunLog()<flamegpu::Simulation::getRunLog>`. This returns a :class:`RunLog<flamegpu::RunLog>` which contains the step and exit log data that was requested.

Performance data is always attached to the requested logs, so can be accessed if required.

.. tabs::

  .. code-tab:: cpp C++
    
    // Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg);
    cuda_sim.setExitLog(exit_log_cfg);
    
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

  .. code-tab:: py Python
  
    # Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg)
    cuda_sim.setExitLog(exit_log_cfg)
    
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
==============================

Instead of processing logged data at runtime, you can store it to file for post-processing at a later time.

Normally you would handle this via the :class:`Simulation::Config<flamegpu::Simulation::Config>` as detailed in the :ref:`earlier section<Configuring Execution>`. However, you can also call :func:`exportLog()<flamegpu::Simulation::exportLog>` on the :class:`CUDASimulation<flamegpu::CUDASimulation>`, to manually trigger the export.

.. tabs::

  .. code-tab:: cpp C++
    
    // Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg);
    cuda_sim.setExitLog(exit_log_cfg);
    
    // Run the simulation as normal
    cuda_sim.simulate();
    
    // Export the logged data to file
    cuda_sim.exportLog(
      "log.json", // The file to output (must end '.json' or '.xml')
      true,       // Whether the step log should be included in the log file
      true,       // Whether the exit log should be included in the log file
      true,       // Whether the step time should be included in the log file (treated as false if step log not included)
      true,       // Whether the simulation time should be included in the log file (treated as false if exit log not included)
      false       // Whether the log file should be minified or not
    );

  .. code-tab:: py Python
  
    # Attach the logging config/s
    cuda_sim.setStepLog(step_log_cfg)
    cuda_sim.setExitLog(exit_log_cfg)
    
    # Run the simulation as normal
    cuda_sim.simulate()
        
    # Export the logged data to file
    cuda_sim.exportLog(
      "log.json", # The file to output (must end '.json' or '.xml')
      True,       # Whether the step log should be included in the log file
      True,       # Whether the exit log should be included in the log file
      True,       # Whether the step time should be included in the log file (treated as false if step log not included)
      True,       # Whether the simulation time should be included in the log file (treated as false if exit log not included)
      False)      # Whether the log file should be minified or not
  

Accessing the Complete Agent State
----------------------------------

In some limited cases, you may want to directly access a full agent population. This can only be achieved in code, either by directly accessing the agent data or manually triggering the export to file.


Similar to specifying an initial agent population, you can fetch an agent state population to an :class:`AgentVector<flamegpu::AgentVector>`.

.. tabs::

  .. code-tab:: cpp C++
  
    flamegpu::ModelDescription model("example model");
    flamegpu::AgentDescription &boid_agent = model.newAgent("boid");
    
    // Fully define the model & setup the CUDASimulation
    ...
    
    // Run the simulation as normal
    // step() could also be used to access the agent state, on a per step basis
    cuda_sim.simulate();
    
    // Copy the boid agent data, from the default state, to an agent vector
    flamegpu::AgentVector out_pop(boid_agent);
    cuda_sim.getPopulationData(out_pop);
    
    // Iterate the agents, and print their speed
    for (flamegpu::AgentVector::Agent &boid : out_pop) {
        printf("Speed: %f\n", boid.getVariable<float>("speed"));
    }
    
  .. code-tab:: py Python
  
    model = pyflamegpu.ModelDescription("example model");
    boid_agent = model.newAgent("boid");
    
    # Fully define the model & setup the CUDASimulation
    ... 
    
    # Run the simulation as normal
    # step() could also be used to access the agent state, on a per step basis
    cuda_sim.simulate()
    
    # Copy the boid agent data, from the default state, to an agent vector
    out_pop = pyflamegpu.AgentVector(boid_agent)
    cuda_sim.getPopulationData(out_pop)
    
    # Iterate the agents, and print their speed
    for boid in out_pop:
        print("Speed: %f"%(boid.getVariableFloat("speed"))

Alternatively, :func:`exportData()<flamegpu::Simulation::exportData>` can be called to export the full simulation state to file (all agent variables and environment properties).

.. tabs::

  .. code-tab:: cpp C++
  
    flamegpu::ModelDescription model("example model");
    flamegpu::AgentDescription &boid_agent = model.newAgent("boid");
    
    // Fully define the model & setup the CUDASimulation
    ...
    
    // Run the simulation as normal
    // step() could also be used to access the agent state, on a per step basis
    cuda_sim.simulate();
    
    // Log the simulation state to JSON/XML file
    cuda_sim.exportData("end.json");
    
  .. code-tab:: py Python
  
    model = pyflamegpu.ModelDescription("example model");
    boid_agent = model.newAgent("boid");
    
    // Fully define the model & setup the CUDASimulation
    ...
    
    # Run the simulation as normal
    # step() could also be used to access the agent state, on a per step basis
    cuda_sim.simulate()
    
    # Log the simulation state to JSON/XML file
    cuda_sim.exportData("end.json")

Additional Notes
----------------

At the time of writing it is not possible to log or export Environment Macro Properties, doing so would require manually outputting them via an init, step or exit function.


Related Links
-------------
* User Guide Page: :ref:`Configuring Execution<Configuring Execution>`
* Full API documentation for :class:`LoggingConfig<flamegpu::LoggingConfig>`
* Full API documentation for :class:`AgentLoggingConfig<flamegpu::AgentLoggingConfig>`
* Full API documentation for :class:`StepLoggingConfig<flamegpu::StepLoggingConfig>`
* Full API documentation for :class:`RunLog<flamegpu::RunLog>`
* Full API documentation for :class:`AgentVector<flamegpu::AgentVector>`
* Full API documentation for :class:`AgentVector::Agent<flamegpu::AgentVector_Agent>`
* Full API documentation for :class:`AgentVector::CAgent<flamegpu::AgentVector_CAgent>` (Read-only superclass of :class:`AgentVector::Agent<flamegpu::AgentVector_Agent>`)
* Full API documentation for :class:`CUDASimulation<flamegpu::CUDASimulation>`
* Full API documentation for :class:`Simulation<flamegpu::Simulation>`
* Full API documentation for :class:`Simulation::Config<flamegpu::Simulation::Config>`