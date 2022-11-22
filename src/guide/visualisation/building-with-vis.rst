Enabling Visualisation
======================

To use the visualisation features you must ensure that you are using a build of FLAME GPU with visualisation enabled.

Visualisation is enabled by setting the ``FLAMEGPU_VISUALISATION`` CMake option to ``ON`` during CMake Configuration. See  :ref:`building-flamegpu-from-source`.

Once visualisation support is enabled, it is still necessary to provide some configuration in order to select which agents to visualise and how.

If you prefer to use 3rd party tools for visualising models, you can save the simulation state to disk as described in a :ref:`previous chapter<Collecting Data>`. 

Detecting Visualisation Support
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

FLAME GPU visualisation support can be detected within models:

.. tabs::

  .. code-tab:: cpp C++

    #ifdef FLAMEGPU_VISUALISATION
        // Visualisation specific code
    #endif

  .. code-tab:: py Python

    if pyflamegpu.VISUALISATION:
        # Visualisation specific code




Related Links
-------------

* User Guide Page: :ref:`Building FLAME GPU From Source<building-flamegpu-from-source>`