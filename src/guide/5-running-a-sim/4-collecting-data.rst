Collecting Data
===============

Saving Agent State
------------------

The state of the simulation can be periodically saved in either XML or JSON format. To save the state, supply the **TODO: which switch** switch 
to the program, followed by the output period. For example

**TODO: Example**

runs program '...' and will output its state every 5 steps in the JSON format.

Collecting Other Information
----------------------------

Custom information can be collected using step functions. These run at the end of each step. The FLAMEGPU2 API provides a 
set of functions which can be used to collect information about agents and their variables.

.. tabs::

  .. code-tab:: cuda CUDA C++
    
    // Define a step function called 'step_function'
    FLAMEGPU_STEP_FUNCTION(step_function) {
        auto agent = FLAMEGPU->agent("agent");
        
        // Compute the sum of all the 'a' variables of agent type 'agent'
        int sum_a = agent.sum<int>("a");

        // Apply a custom function, 'customSum' to the variables 'a' of agent type 'agent'
        int custom_sum_a = agent.reduce<int>("a", customSum, 0);

        // Count the number of agents whose 'a' variable is set to '1'
        unsigned int count_a = agent.count<int>("a", 1);

        // Sum the values of the 'a' variables of agent type 'agent', whose 'a' value meets the criteria defined in 'customTransform' 
        unsigned int countif_a = agent.transformReduce<int, unsigned int>("a", customTransform, customSum, 0u);

        // Print out the collected information
        printf("Step Function! (AgentCount: %u, Sum: %d, CustomSum: %d, Count: %u, CustomCountIf: %u)\n", agent.count(), sum_a, custom_sum_a, count_a, countif_a);
    }