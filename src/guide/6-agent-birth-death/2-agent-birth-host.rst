Agent Birth from Host Functions
===============================

Agents can be created using host step functions. 

.. tabs::
  
  .. code-tab:: cpp

    FLAMEGPU_STEP_FUNCTION(BasicOutput) {
        // Get the agent type 'agent'
        auto t = FLAMEGPU->agent("agent");

        // Create NEW_AGENT_COUNT new 'agent' agents with 'x' set to 1.0f
        for (unsigned int i = 0; i < NEW_AGENT_COUNT; ++i)
            t.newAgent().setVariable<float>("x", 1.0f);
    }