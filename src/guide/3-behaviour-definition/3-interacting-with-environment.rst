Interacting with the Environment
================================

Agent functions can read environmental properties. If you wish to modify an environmental property, this must be done
through :ref:`Host Functions`.

Environmental properties are accessed as follows:

.. tabs::

  .. code-tab:: cuda CUDA C++

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Get the value of environment variable 'interaction_radius' and store it in local variable 'interaction_radius'
        int interaction_radius = FLAMEGPU->environment.getProperty<float>("interaction_radius");

        // Other behaviour code
        ...
    }