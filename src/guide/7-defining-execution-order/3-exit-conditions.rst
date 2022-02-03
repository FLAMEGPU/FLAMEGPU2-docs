.. _Exit Conditions:
Exit Conditions
^^^^^^^^^^^^^^^

Normally a simulation is executed for a specified number of steps. However, some models may reach and end state early (e.g. if the population dies out).

In order to manage these conditional exit's FLAME GPU 2 provides exit conditions, via the :c:macro:`FLAMEGPU_EXIT_CONDITION` macro. These are implemented the same as host functions, that were introduced in the :ref:`earlier chapter<Host Functions and Conditions>`, with the exception they must return either  :enumerator:`CONTINUE<flamegpu::CONDITION_RESULT::CONTINUE>` or :enumerator:`EXIT<flamegpu::CONDITION_RESULT::EXIT>`. 

In particular, submodels which are introduced in the :ref:`following section<Defining a Submodel>`, require an exit condition as they cannot have their number of steps specified in the normal manner.

.. tabs::

  .. code-tab:: cpp C++

    FLAMEGPU_EXIT_CONDITION(my_exit_condition) {
        // A simple exit condition which forces the model to exit after 100 steps
        if (FLAMEGPU->getStepCounter() >= 100) {
            return flamegpu::EXIT;      // End the simulation here
        } else {
            return flamegpu::CONTINUE;  // Continue the simulation
        }
    }

    // Fully define the model
    ModelDescription model("example model");
    ...

    // Add 'my_exit_condition' to 'model'
    model.addExitCondition(my_exit_condition);

  .. code-tab:: py Python

    class my_exit_condition(pyflamegpu.HostFunctionConditionCallback):
        def run(self, FLAMEGPU):
            # A simple exit condition which forces the model to exit after 100 steps
            if FLAMEGPU.getStepCounter() >= 100: 
                return pyflamegpu.EXIT      # End the simulation here
            else
                return pyflamegpu.CONTINUE  # Continue the simulation

    # Fully define the model
    model = pyflamegpu.ModelDescription("example model")
    ...
    
    # Add 'my_exit_condition' to 'model'
    model.addExitConditionCallback(my_exit_condition().__disown__())

If a model has multiple exit conditions, they will be executed in the order that they were added to the model. 
When multiple exit conditions are defined, conditions are only executed if earlier exit condition functions return :enumerator:`CONTINUE<flamegpu::CONDITION_RESULT::CONTINUE>`.

Related Links
-------------
* User Guide Page: :ref:`Host Functions and Conditions<Host Functions and Conditions>`
* User Guide Page: :ref:`Configuring Execution<Configuring Execution>`
* User Guide Page: :ref:`Submodels<Defining a Submodel>`
* Full API documentation for :c:macro:`FLAMEGPU_EXIT_CONDITION` (Python: :class:`HostFunctionConditionCallback<flamegpu::HostFunctionConditionCallback>`)
* Full API documentation for :enum:`flamegpu::CONDITION_RESULT<flamegpu::CONDITION_RESULT>` (:enumerator:`CONTINUE<flamegpu::CONDITION_RESULT::CONTINUE>` and :enumerator:`EXIT<flamegpu::CONDITION_RESULT::EXIT>`
