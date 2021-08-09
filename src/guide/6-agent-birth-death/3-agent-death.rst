Agent Death
===========

Enabling Agent Death
--------------------

By default in FLAMEGPU2 agents do not die. To enable death for a particular agent function, use the ``setAllowAgentDeath`` method of
the ``AgentFunctionDescription`` object:

.. tabs::
  
  .. code-tab:: cpp

    // Allow agent_fn1 to kill agents
    agent_fn1_description.setAllowAgentDeath(true);

  .. code-tab:: python

    # Allow agent_fn1 to kill agents
    agent_fn1_description.setAllowAgentDeath(true)


Agent Death
-----------

To have an agent die, simply ``return DEAD;`` instead of ``return ALIVE;`` at the end of a death-enabled agent function. You can use
conditionals to only have agents die according to a certain condition:

.. tabs::

  .. code-tab:: cpp
    
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

More Info 
---------

* Related User Guide Pages

  * `Interacting with the Environment <../3-behaviour-definition/3-interacting-with-environment.html>`_
  * `Random Number Generation <../8-advanced-sim-management/2-rng-seeds.html>`_

* Full API documentation for the ``EnvironmentDescription``: link
* Examples which demonstrate creating an environment

  * Boids Brute Force (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/boids_bruteforce/src/main.cu>`__)
  * Ensemble (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/ensemble/src/main.cu>`__)