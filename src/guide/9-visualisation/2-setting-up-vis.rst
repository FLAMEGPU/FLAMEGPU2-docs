Configuring a Visualisation
===========================

To create a FLAME GPU visualisation, you must configure and activate the visualisation.

.. tabs::

  .. code-tab:: cuda CUDA C++

    // Create CUDASimulation as normal
    flamegpu::CUDASimulation cudaSimulation(model);
    // Only enable vis if visualisation support is present
    #ifdef VISUALISATION
        // Configure the visualisation
        flamegpu::visualiser::ModelVis &visualisation = cudaSimulation.getVisualisation();
        ...
        // Activate the visualisation
        visualisation.activate();
    #endif

  .. code-tab:: python

    # Create CUDASimulation as normal
    cudaSimulation = pyflamegpu.CUDASimulation(model);
    # Only enable vis if visualisation support is present
    if pyflamegpu.VISUALISATION:
        # Configure the visualisation
        visualisation = cudaSimulation.getVisualisation();
        ...
        # Activate the visualisation
        visualisation.activate();


Visualisation Options
---------------------
There are many options available within ``ModelVis`` to control how the visualisation works.

The most important of these settings are presented below:

========================= ============================ ======================================================
Method                    Parameters                       Description
========================= ============================ ======================================================
setWindowTitle            ``title``                    Sets the string displayed in the visualisation window's title bar. (Defaults to the model name)
setWindowDimensions       ``width``, ``height``        Sets the initial dimensions of the visualisation window. (Defaults to 1280x720)
setClearColor             ``red``, ``green``, ``blue`` Sets the background colour of the visualisation. (Defaults to black [0,0,0])
setInitialCameraLocation  ``x``, ``y``, ``z``          Sets the initial location for the visualisation's 'camera'. (Defaults to the [1.5, 1.5, 1.5])
setInitialCameraTarget    ``x``, ``y``, ``z``          Sets the initial target that the visualisation's 'camera' faces. (Defaults to the origin [0,0,0])
setCameraSpeed            ``speed``                    Sets the speed of camera movement, in units travelled per millisecond. (Defaults to 0.05)
setSimulationSpeed        ``stepsPerSecond``           Sets a limit for the speed at which the model being visualised executes. The visualisation executes in a seperate thread, so this will not affect the framerate. (Defaults to 0, which disables the limit)
setBeginPaused            ``beginPaused``              If true, the model begins in a paused state and must be unpaused to continue execution (Defaults to false)
========================= ============================ ======================================================

More advanced settings are also available, full documentation can be found in the ``ModelVis`` API documentation.

Visualising After Simulation Exit
---------------------------------

By default, when the ``CUDASimulation`` returns from the call to `simulate()` after the model has completed, the program will continue and likely exit.
If you would prefer to prevent this, and keep the visualisation open, so the final state of the model can be explored, the visualisation can be joined to prevent program execution continuing until the visualisation window has been closed.

.. tabs::

  .. code-tab:: cuda CUDA C++

    // Execute simulation
    cudaSimulation.simulate();
    // Join the visualisation after simulation returns to prevent the window closing
    #ifdef VISUALISATION
        visualisation.join();
    #endif

  .. code-tab:: python

    # Execute simulation
    cudaSimulation.simulate();
    # Join the visualisation after simulation returns to prevent the window closing
    if pyflamegpu.VISUALISATION:
        visualisation.join();