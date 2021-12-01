Launching Ensembles
===================

An ensemble is a group of simulations executed in batch, optionally using all available GPUs. To use an ensemble, construct a ``RunPlanVector`` and ``CUDAEnsemble`` instead of a ``CUDASimulation``.

``RunPlanVector`` is a data structure which can be used to build run configurations, specifying; simulation speed, steps and initialising environment properties. These vectors can be combined


First you must define a model as usual, followed by creating a ``CUDAEnsemble``:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    flamegpu::ModelDescription model("example model");
    
    ... // Fully define the model
    
    // Create a CUDAEnsemble to run the runplan
    flamegpu::CUDAEnsemble ensemble(model);
    // Handle any runtime args
    ensemble.initialise(argc, argv);

  .. code-tab:: python
  
    model = pyflamegpu.ModelDescription("example model")
    
    ... # Fully define the model
    
    # Create a CUDAEnsemble to run the runplan
    ensemble = flamegpu.CUDAEnsemble(model)
    # Handle any runtime args
    ensemble.initialise(argc, argv);


Then you construct the ``RunPlanVector`` that will be executed.

Operations performed on the vector, will apply to all elements, whereas individual elements can also be updated directly.
It is also possible to specify subdirectories for particular runs' logging output to be sent to, this can be useful when constructing large batch runs or parameter sweeps:


.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Create a vector of 128 RunPlans
    flamegpu::RunPlanVector runs(model, 128);
    {  // Initialise values across the whole vector
        // All runs require 50 steps
        runs.setSteps(50);
        // Random seeds for each run should take the values (12, 13, 14, 15, etc)
        runs.setRandomSimulationSeed(12, 1);
        // Initialise environment property 'static_int', to 25 across all runs
        runs.setProperty<int>("static_int", 25);
        // Initialise environment property 'lerp_float' with values uniformly distributed between 1 and 128
        runs.setPropertyUniformDistribution<float>("lerp_float", 1.0f, 128.0f);
        
        // Seed the internal random generator used to seed random properties
        runs.setRandomPropertySeed(12345);
        // Initialise environment property 'random_int' with values uniformly distributed in the range [0, 10]
        runs.setPropertyUniformRandom<int>("random_int", 0, 10);
        // Initialise environment property 'random_float' with values from the normal distribution (mean: 1, stddev:2)
        runs.setPropertyNormalRandom<float>("random_float", 1.0f, 2.0f);
        // Initialise environment property 'random_double' with values from the log normal distribution (mean: 2, stddev:1)
        runs.setPropertyLogNormalRandom<double>("random_double", 2.0, 1.0);
        
        // Iterate vector to manually assign properties
        for (RunPlan &plan:runs) {
            // e.g. manually set all 'manual_float' to 32
            plan.setProperty<float>("manual_float", 32.0f);
            
            // Split the runs' outputs across 2 subdirectories
            plan.setOutputSubDirectory(plan.getProperty<int>("random_int")%2==0?"sub_a":"sub_b");
        }        
    }

  .. code-tab:: python
  
    # Create a vector of 128 RunPlans
    runs = pyflamegpu.RunPlanVector(model, 128)
    
    # Initialise values across the whole vector
    # All runs require 50 steps
    runs.setSteps(50)
    # Random seeds for each run should take the values (12, 13, 14, 15, etc)
    runs.setRandomSimulationSeed(12, 1)
    # Initialise environment property 'static_int', to 25 across all runs
    runs.setPropertyInt("static_int", 25)
    # Initialise environment property 'lerp_float' with values uniformly distributed between 1 and 128
    runs.setPropertyUniformDistributionFloat("lerp_float", 1, 128)
    
    # Seed the internal random generator used to seed random properties
    runs.setRandomPropertySeed(12345)
    # Initialise environment property 'random_int' with values uniformly distributed in the range [0, 10]
    runs.setPropertyUniformRandomInt("random_int", 0, 10);
    # Initialise environment property 'random_float' with values from the normal distribution (mean: 1, stddev:2)
    runs.setPropertyNormalRandomFloat("random_float", 1.0, 2.0)
    # Initialise environment property 'random_double' with values from the log normal distribution (mean: 2, stddev:1)
    runs.setPropertyLogNormalRandomDouble("random_double", 2.0, 1.0)
    
    # Iterate vector to manually assign properties
    for plan in runs:
        # e.g. manually set all 'manual_float' to 32
        plan.setProperty<float>("manual_float", 32.0)
        
        # Split the runs' outputs across 2 subdirectories
        dir = "sub_a" if (plan.getPropertyInt("random_int")%2==0) else "sub_b"
        plan.setOutputSubDirectory(dir)

    
After which, you configure which data will be logged (see `Collecting Data <../5-running-a-sim/4-collecting-data.html>`_ for a more detailed guide on configuring logging):

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Specify the desired LoggingConfig or StepLoggingConfig
    flamegpu::StepLoggingConfig step_log_cfg(model);
    {
        // Log every step (not available to LoggingConfig, for exit logs)
        step_log_cfg.setFrequency(1);
        step_log_cfg.logEnvironment("random_float");
        step_log_cfg.agent("boid").logCount();
        step_log_cfg.agent("boid").logMean<float>("speed");
    }
    flamegpu::LoggingConfig exit_log_cfg(model);
    exit_log_cfg.logEnvironment("lerp_float");
    // Pass the logging configs to the CUDAEnsemble
    cuda_ensemble.setStepLog(step_log_cfg);
    cuda_ensemble.setExitLog(exit_log_cfg);

  .. code-tab:: python
  
    # Specify the desired LoggingConfig or StepLoggingConfig
    step_log_cfg = pyflamegpu.StepLoggingConfig(model);

    #Log every step (not available to LoggingConfig, for exit logs)
    step_log_cfg.setFrequency(1);
    step_log_cfg.logEnvironment("random_float");
    step_log_cfg.agent("boid").logCount();
    step_log_cfg.agent("boid").logMeanFloat("speed");

    exit_log_cfg = pyflamegpu.LoggingConfig (model)
    exit_log_cfg.logEnvironment("lerp_float")
    # Pass the logging configs to the CUDAEnsemble
    cuda_ensemble.setStepLog(step_log_cfg)
    cuda_ensemble.setExitLog(exit_log_cfg)
    
Finally you can execute/run the ensemble of simulations using the ``RunPlanVector``:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
        // Execute the ensemble using the specified RunPlans
        cuda_ensemble.simulate(runs);

  .. code-tab:: python
  
        # Execute the ensemble using the specified RunPlans
        cuda_ensemble.simulate(runs)


Now when you execute the CUDAEnsemble from the command line, using the below parameters, it will execute the runs and log the collected data to file.

============================== =========================== ============================
Long Argument                  Short Argument              Description
============================== =========================== ============================
``--help``                     ``-h``                      Print the command line guide and exit.
``--devices`` <device ids>     ``-d`` <device ids>         Comma separated list of GPU ids to be used to execute the ensemble.
                                                           By default all devices will be used.
``--concurrent`` <runs>        ``-c`` <runs>               The number of concurrent simulations to run per GPU.
                                                           By default 4 concurrent simulations will run per GPU.
``--out`` <directory> <format> ``-o`` <directory> <format> Directory and format (JSON/XML) for ensemble logging.
``--quiet``                    ``-q``                      Don't print ensemble progress to console.
``--timing``                   ``-t``                      Output timing information to console at exit.
============================== =========================== ============================

You may also wish to override the defaults, by setting the values prior to calling `initialise()`:

.. tabs::

  .. code-tab:: cuda CUDA C++
    
    // Create a CUDAEnsemble to run the RunPlanVector
    flamegpu::CUDAEnsemble ensemble(model);
    
    // Override config defaults
    ensemble.Config().concurrent_runs = 1;
    ensemble.Config().timing = true;
    
    // Handle any runtime args 
    // If this is instead performed before overriding defaults, overridden args will be ignored from command line
    ensemble.initialise(argc, argv);

  .. code-tab:: python
    
    # Create a CUDAEnsemble to execute the RunPlanVector
    ensemble = pyflamegpu.CUDAEnsemble(model);
    
    # Override config defaults
    ensemble.Config().concurrent_runs = 1
    ensemble.Config().timing = true
    
    # Handle any runtime args 
    # If this is instead performed before overriding defaults, overridden args will be ignored from command line
    ensemble.initialise(argc, argv)