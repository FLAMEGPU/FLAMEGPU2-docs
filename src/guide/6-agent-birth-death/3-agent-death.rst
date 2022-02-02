Agent Death
===========

Enabling Agent Death
--------------------

By default in FLAMEGPU2 agents do not die. To enable death for a particular agent function, use the ``setAllowAgentDeath`` method of
the ``AgentFunctionDescription`` object:

.. tabs::
  
  .. code-tab:: cuda CUDA C++

    // Allow agent_fn1 to kill agents
    agent_fn1_description.setAllowAgentDeath(true);

  .. code-tab:: python

    # Allow agent_fn1 to kill agents
    agent_fn1_description.setAllowAgentDeath(true)


Agent Death
-----------

To have an agent die, simply ``return flamegpu::DEAD;`` instead of ``return flamegpu::ALIVE;`` at the end of a death-enabled agent function. You can use
conditionals to only have agents die according to a certain condition:

.. tabs::

  .. code-tab:: cuda CUDA C++
    
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Get the 'x' variable of the agent
        int x = FLAMEGPU->getVariable<int>("x");
        
        // Kill any agents with x < 25
        if (x < 25) {
            return flamegpu::DEAD;
        } else {
            return flamegpu::ALIVE;
        }
    }
