Building with Visualisation
===========================

To use the visualisation features you must ensure that you are using a build of FLAME GPU with visualisation enabled.

Visualisation is enabled at build time by enabling the `VISUALISATION` during CMake configure. See  :ref:`Building FLAME GPU from Source`.

FLAME GPU visualisation support can be detected within models:

.. tabs::

  .. code-tab:: cuda CUDA C++

    #ifdef VISUALISATION
        // Visualisation specific code
    #endif

  .. code-tab:: python

    if pyflamegpu.VISUALISATION:
        # Visualisation specific code

If you prefer to use 3rd party tools for visualising models, you can save the simulation state to disk as described in :ref:`Collecting Data`. 

Default Visualisation
---------------------

The default visualisation will render agents based on their `x`, `y` and `z` variables.