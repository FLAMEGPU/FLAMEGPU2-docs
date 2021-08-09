Creating a Model
================

What is a Model?
----------------

A model in FLAMEGPU2 is equivalent to a model in agent-based modelling terms. It is composed of agents, environmental properties,
a set of behaviours which govern how the simulation evolves, and a dependency graph specifying which order the behaviours should occur in.
In FLAMEGPU2, models are represented by a ``ModelDescription`` object.

Creating a ModelDescription Object
----------------------------------

A ``ModelDescription`` is initialised with a name:

.. tabs::

  .. code-tab:: cpp

    // Create a ModelDescription object called model, initialised with the name "some_model"
    flamegpu::ModelDescription model("some_model");

  .. code-tab:: python
    
    # Create a ModelDescription object called model, initialised with the name "some_model"
    model = pyflamegpu.ModelDescription("some_model")


More Info 
---------
* Full API documentation for the ``ModelDescription``: link
* Examples which demonstrate creating a model

  * Boids Brute Force (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/boids_bruteforce/src/main.cu>`_)
  * Ensemble (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/ensemble/src/main.cu>`_)
