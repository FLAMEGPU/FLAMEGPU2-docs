Launching Ensembles
===================

An ensemble is a group of simulations which are run concurrently. To use an ensemble, construct a ``RunPlanVector`` and ``CUDAEnsemble`` instead of a ``CUDASimulation``:


.. tabs::

  .. code-tab:: cuda CUDA C++
     
    // Create a RunPlanVector object from the model, specifying we wish to run 20 simulations
    flamegpu::RunPlanVector runplan(model, 20);

    // Run each simulation for 1000 steps
    runplan.setSteps(1000);

    // Create a CUDAEnsemble to run the runplan
    flamegpu::CUDAEnsemble ensemble(model, argc, argv);

    // Run the ensemble
    ensemble.simulate();
