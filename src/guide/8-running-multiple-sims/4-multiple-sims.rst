Launching Ensembles
===================

An ensemble is a group of simulations which are run concurrently. To use an ensemble, construct a ``RunPlanVec`` and ``CUDAEnsemble`` instead of a ``CUDASimulation``:


.. tabs::

  .. code-tab:: python

    **TODO: python ensembles**

  .. code-tab:: cpp
     
    // Create a RunPlanVec object from the model, specifying we wish to run 20 simulations
    RunPlanVec runplan(model, 20);

    // Run each simulation for 1000 steps
    runplan.setSteps(1000);

    // Create a CUDAEnsemble to run the runplan
    CUDAEnsemble ensemble(model, argc, argv);

    // Run the ensemble
    ensemble.simulate();