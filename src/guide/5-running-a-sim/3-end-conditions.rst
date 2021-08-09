Simulation Exit Conditions
==========================

Simulations can exit either after a specified number of steps, or when a particular condition is met.

Max Steps
---------

The number of steps can be set through the ``SimulationConfig`` method of a ``CUDASimulation`` object:

.. tabs::

  .. code-tab:: python

    # Set the simulation to run for 500 steps
    simulation.SimulationConfig().steps = 500

  .. code-tab:: cpp
     
    // Set the simulation to run for 500 steps
    simulation.SimulationConfig().steps = 500;

Conditional Exit
----------------

Conditional exit from the simulation can be controlled through the use of the ``FLAMEGPU_EXIT_CONDITION`` macro. These are specified in the same way
as other host functions, but return either ``CONTINUE`` or ``EXIT``:

.. tabs::

    .. code-tab:: cpp

      FLAMEGPU_EXIT_CONDITION(my_exit_condition) {
        if (someCondition)
          return flamegpu::EXIT;  // End the simulation here
        else
          return flamegpu::CONTINUE;  // Continue the simulation
      }

The exit condition can be added to the model:

.. tabs::

    .. code-tab:: python

        # Add 'my_exit_condition' to 'model'
        model.addExitCondition(my_exit_condition)

    .. code-tab:: cpp

        // Add 'my_exit_condition' to 'model'
        model.addExitCondition(my_exit_condition);
