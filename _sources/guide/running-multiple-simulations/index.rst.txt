.. _ensembles:

Running Multiple Simulations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

FLAME GPU 2 provides :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>` as a facility for executing batch runs of multiple configurations of a model.


Creating a CUDAEnsemble
-----------------------

An ensemble is a group of simulations executed in batch, optionally using all available GPUs. To use an ensemble, construct a :class:`RunPlanVector<flamegpu::RunPlanVector>` and :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>` instead of a :class:`CUDASimulation<flamegpu::CUDASimulation>`.

First you must define a model as usual, followed by creating a :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>`:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    flamegpu::ModelDescription model("example model");
    
    // Fully define the model
    ...
    
    // Create a CUDAEnsemble
    flamegpu::CUDAEnsemble ensemble(model);
    // Handle any runtime args
    ensemble.initialise(argc, argv);

  .. code-tab:: python
  
    model = pyflamegpu.ModelDescription("example model")
    
    # Fully define the model
    ...
    
    # Create a CUDAEnsemble
    ensemble = pyflamegpu.CUDAEnsemble(model)
    # Handle any runtime args
    ensemble.initialise(sys.argv)


Creating a RunPlanVector
------------------------

:class:`RunPlanVector<flamegpu::RunPlanVector>` is a data structure which can be used to build run configurations, specifying; simulation speed, steps and initialising environment properties. These are a ``std::vector`` of :class:`RunPlan<flamegpu::RunPlan>` (which was introduced in the :ref:`previous chapter<RunPlan>`), with some additional methods included to enable easy configuration of batches of runs.

Operations performed on the vector, will apply to all elements, whereas individual elements can also be updated directly.

It is also possible to specify subdirectories for a particular runs' logging output to be sent to, this can be useful when constructing large batch runs or parameter sweeps:


.. tabs::

  .. code-tab:: cpp C++
  
    // Create a template run plan
    flamegpu::RunPlanVector runs_control(model, 128);
    // Ensure that repeated runs use the same Random values within the RunPlans
    runs_control.setRandomPropertySeed(34523);
    {  // Initialise values across the whole vector
        // All runs require 3600 steps
        runs_control.setSteps(3600);
        // Random seeds for each run should take the values (12, 13, 14, 15, etc)
        runs_control.setRandomSimulationSeed(12, 1);
        // Initialise environment property 'lerp_float' with values uniformly distributed between 1 and 128
        runs_control.setPropertyLerpRange<float>("lerp_float", 1.0f, 128.0f);
        
        // Initialise environment property 'random_int' with values uniformly distributed in the range [0, 10]
        runs_control.setPropertyUniformRandom<int>("random_int", 0, 10);
        // Initialise environment property 'random_float' with values from the normal dist (mean: 1, stddev: 2)
        runs_control.setPropertyNormalRandom<float>("random_float", 1.0f, 2.0f);
        // Initialise environment property 'random_double' with values from the log normal dist (mean: 2, stddev: 1)
        runs_control.setPropertyLogNormalRandom<double>("random_double", 2.0, 1.0);
        
        // Initialise environment property array 'int_array_3' with [1, 3, 5]
        runs_control.setProperty<int, 3>("int_array_3", {1, 3, 5});
        
        // Iterate vector to manually assign properties
        for (RunPlan &plan:runs_control) {
            // e.g. manually set all 'manual_float' to 32
            plan.setProperty<float>("manual_float", 32.0f);
        }        
    }
    // Create an empty RunPlanVector, that we will construct by mutating and copying runs_control several times  
    flamegpu::RunPlanVector runs(model, 0);
    for (const float &mutation : {0.2f, 0.5f, 0.8f, 1.5f, 1.9f, 2.5f}) {
        // Dynamically generate a name for mutation sub directory
        char subdir[24];
        sprintf(subdir, "mutation_%g", mutation);
        runs_control.setOutputSubdirectory(subdir);
        // Fill in specialised parameters
        runs_control.setProperty<float>("mutation", mutation);                    
        // Append to the main run plan vector
        runs += runs_control;
    }

  .. code-tab:: py Python
  
    # Create a template run plan
    runs_control = pyflamegpu.RunPlanVector(model, 128)
    # Ensure that repeated runs use the same Random values within the RunPlans
    runs_control.setRandomPropertySeed(34523)
    # Initialise values across the whole vector
    # All runs require 3600 steps
    runs_control.setSteps(3600)
    # Random seeds for each run should take the values (12, 13, 14, 15, etc)
    runs_control.setRandomSimulationSeed(12, 1)
    # Initialise environment property 'lerp_float' with values uniformly distributed between 1 and 128
    runs_control.setPropertyLerpRangeFloat("lerp_float", 1.0, 128.0)
    
    # Initialise environment property 'random_int' with values uniformly distributed in the range [0, 10]
    runs_control.setPropertyUniformRandomInt("random_int", 0, 10)
    # Initialise environment property 'random_float' with values from the normal dist (mean: 1, stddev: 2)
    runs_control.setPropertyNormalRandomFloat("random_float", 1.0, 2.0)
    # Initialise environment property 'random_double' with values from the log normal dist (mean: 2, stddev: 1)
    runs_control.setPropertyLogNormalRandomDouble("random_double", 2.0, 1.0)
    
    # Initialise environment property array 'int_array_3' with [1, 3, 5]
    runs_control.setPropertyArrayInt("int_array_3", (1, 3, 5))
    
    # Iterate vector to manually assign properties
    for plan in runs_control:
        # e.g. manually set all 'manual_float' to 32
        plan.setPropertyFloat("manual_float", 32.0)
  
    # Create an empty RunPlanVector, that we will construct by mutating and copying runs_control several times
    runs = pyflamegpu.RunPlanVector(model, 0)
    for mutation in [0.2, 0.5, 0.8, 1.5, 1.9, 2.5]:
        # Dynamically generate a name for mutation sub directory
        runs_control.setOutputSubdirectory("mutation_%g"%(mutation))
        # Fill in specialised parameters
        runs_control.setPropertyFloat("mutation", mutation)
        # Append to the main run plan vector
        runs += runs_control
    
Creating a Logging Configuration
--------------------------------
Next you need to decide which data will be collected, as it is not possible to export full agent states from a :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>`.

A short example is shown below, however you should refer to the :ref:`previous chapter<Configuring Data to be Logged>` for the comprehensive guide.

One benefit of using :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>` to carry out experiments, is that the specific :class:`RunPlan<flamegpu::RunPlan>` data is included in each log file, allowing them to be automatically processed and used for reproducible research. However, this does not identify the particular version or build of your model. 

 Agent data is logged according to agent state, so agents with multiple states must have the config specified for each state required to be logged.

.. tabs::

  .. code-tab:: cpp C++
  
    // Specify the desired LoggingConfig or StepLoggingConfig
    flamegpu::StepLoggingConfig step_log_cfg(model);
    {
        // Log every step (not available to LoggingConfig, for exit logs)
        step_log_cfg.setFrequency(1);
        step_log_cfg.logEnvironment("random_float");
        // Include the current number of 'boid' agents, within the 'default' state
        step_log_cfg.agent("boid").logCount();
        // Include the current mean speed of 'boid' agents, within the 'alive' state
        step_log_cfg.agent("boid", "alive").logMean<float>("speed");
    }
    flamegpu::LoggingConfig exit_log_cfg(model);
    exit_log_cfg.logEnvironment("lerp_float");
    
    // Pass the logging configs to the CUDAEnsemble
    cuda_ensemble.setStepLog(step_log_cfg);
    cuda_ensemble.setExitLog(exit_log_cfg);

  .. code-tab:: py Python
  
    # Specify the desired LoggingConfig or StepLoggingConfig
    step_log_cfg = pyflamegpu.StepLoggingConfig(model);

    #Log every step (not available to LoggingConfig, for exit logs)
    step_log_cfg.setFrequency(1);
    step_log_cfg.logEnvironment("random_float");
    # Include the current number of 'boid' agents, within the "default" state
    step_log_cfg.agent("boid").logCount();
    # Include the current mean speed of 'boid' agents, within the 'alive' state
    step_log_cfg.agent("boid", "alive").logMeanFloat("speed");

    exit_log_cfg = pyflamegpu.LoggingConfig (model)
    exit_log_cfg.logEnvironment("lerp_float")
    
    # Pass the logging configs to the CUDAEnsemble
    cuda_ensemble.setStepLog(step_log_cfg)
    cuda_ensemble.setExitLog(exit_log_cfg)
    
Configuring & Running the Ensemble
----------------------------------

Now you can execute the :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>` from the command line, using the below parameters, it will execute the runs and log the collected data to file.

============================== =========================== ========================================================
Long Argument                  Short Argument              Description
============================== =========================== ========================================================
``--help``                     ``-h``                      Print the command line guide and exit.
``--devices`` <device ids>     ``-d`` <device ids>         Comma separated list of GPU ids to be used to execute the ensemble.
                                                           By default all devices will be used.
``--concurrent`` <runs>        ``-c`` <runs>               The number of concurrent simulations to run per GPU.
                                                           By default 4 concurrent simulations will run per GPU.
``--out`` <directory> <format> ``-o`` <directory> <format> Directory and format (JSON/XML) for ensemble logging.
``--quiet``                    ``-q``                      Don't print ensemble progress to console.
``--verbose``                  ``-v``                      Print config, progress and timing (-t) information to console.
``--timing``                   ``-t``                      Output timing information to console at exit.
``--silence-unknown-args``     ``-u``                      Silence warnings for unknown arguments passed after this flag.
``--error``                    ``-e`` <error level>        The :enum:`ErrorLevel<flamegpu::CUDAEnsemble::EnsembleConfig::ErrorLevel>` to use: 0, 1, 2, "off", "slow" or "fast".
                                                           By default the :enum:`ErrorLevel<flamegpu::CUDAEnsemble::EnsembleConfig::ErrorLevel>` will be set to "slow" (1).
``--standby``                                              Allow the operating system to enter standby during ensemble execution.
                                                           The standby blocking feature is currently only supported on Windows, where it is enabled by default.
============================== =========================== ========================================================

You may also wish to specify your own defaults, by setting the values prior to calling :func:`initialise()<flamegpu::CUDAEnsemble::initialise>`:

.. tabs::

  .. code-tab:: cpp C++
  
    // Fully declare a ModelDescription, RunPlanVector and LoggingConfig/StepLoggingConfig
    ...
    
    // Create a CUDAEnsemble to run the RunPlanVector
    flamegpu::CUDAEnsemble ensemble(model);
    
    // Override config defaults
    ensemble.Config().out_directory = "results";
    ensemble.Config().out_format = "json";
    ensemble.Config().concurrent_runs = 1;
    ensemble.Config().timing = true;
    ensemble.Config().error_level = CUDAEnsemble::EnsembleConfig::Fast;
    ensemble.Config().devices = {0};
    
    // Handle any runtime args 
    // If this is instead performed before overriding defaults, overridden args will be ignored from command line
    ensemble.initialise(argc, argv);
    
    // Pass the logging configs to the CUDAEnsemble
    cuda_ensemble.setStepLog(step_log_cfg);
    cuda_ensemble.setExitLog(exit_log_cfg);
    
    // Execute the ensemble using the specified RunPlans
    const unsigned int errs = ensemble.simulate(runs);

  .. code-tab:: py Python
    
    # Fully declare a ModelDescription, RunPlanVector and LoggingConfig/StepLoggingConfig
    ...
    
    # Create a CUDAEnsemble to execute the RunPlanVector
    ensemble = pyflamegpu.CUDAEnsemble(model);
    
    # Override config defaults
    ensemble.Config().out_directory = "results"
    ensemble.Config().out_format = "json"
    ensemble.Config().concurrent_runs = 1
    ensemble.Config().timing = True
    ensemble.Config().error_level = pyflamegpu.CUDAEnsembleConfig.Fast
    ensemble.Config().devices = pyflamegpu.IntSet([0])
    
    # Handle any runtime args 
    # If this is instead performed before overriding defaults, overridden args will be ignored from command line
    ensemble.initialise(sys.argv)
    
    # Pass the logging configs to the CUDAEnsemble
    cuda_ensemble.setStepLog(step_log_cfg)
    cuda_ensemble.setExitLog(exit_log_cfg)
    
    # Execute the ensemble using the specified RunPlans
    errs = ensemble.simulate(runs)
    
Error Handling Within Ensembles
-------------------------------

:class:`CUDAEnsemble<flamegpu::CUDAEnsemble>` has three supported levels of error handling.

====== ===== ==========================================================================================================
Level  Name  Description
====== ===== ==========================================================================================================
0      Off   Runs which fail do not cause an exception to be raised.
1      Slow  If any runs fail, an :class:`EnsembleError<flamegpu::exception::EnsembleError>` will be raised after all runs have been attempted.
2      Fast  An :class:`EnsembleError<flamegpu::exception::EnsembleError>` will be raised as soon as a failed run is detected, cancelling remaining runs.
====== ===== ==========================================================================================================

The default error level is "Slow" (1), which will cause an exception to be raised if any of the simulations fail to complete. However, all simulations will be attempted first, so partial results will be available.

Alternatively, calls to :func:`simulate()<flamegpu::CUDAEnsemble::simulate>` return the number of errors, when the error level is set to "Off" (0). Therefore, failed runs can be probed manually via checking that the return value of :func:`simulate()<flamegpu::CUDAEnsemble::simulate>` does not equal zero.

  
Related Links
-------------
* User Guide: :ref:`Overriding the Initial Environment<RunPlan>` (:class:`RunPlan<flamegpu::RunPlan>` guide)
* User Guide: :ref:`Configuring Data to be Logged<Configuring Data to be Logged>`
* Full API documentation for :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>`
* Full API documentation for :class:`CUDAEnsemble::EnsembleConfig<flamegpu::CUDAEnsemble::EnsembleConfig>`
* Full API documentation for :class:`CUDASimulation<flamegpu::CUDASimulation>`
* Full API documentation for :class:`RunPlanVector<flamegpu::RunPlanVector>`
* Full API documentation for :class:`RunPlan<flamegpu::RunPlan>`
* Full API documentation for :class:`LoggingConfig<flamegpu::LoggingConfig>`
* Full API documentation for :class:`AgentLoggingConfig<flamegpu::AgentLoggingConfig>`
* Full API documentation for :class:`StepLoggingConfig<flamegpu::StepLoggingConfig>`
