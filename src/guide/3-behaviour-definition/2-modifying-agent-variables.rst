Modifying Agent Variables
=========================

Each instance of an agent will have its own copy of each of the agent variables specified in the agent type defintion.
These can be accessed and modified within agent functions. 

Within an agent function, variables can be read with ``getVariable`` and written to with ``setVariable``.
These variables are accessed from higher latency device memory, so for the best performance, we recommended
that you avoid multiple reads or writes to the same variable in any agent functions and do as much as possible
with the local copy. The agent ID built-in variable can be accessed via the `getID` method.

To achieve the high performance of FLAMEGPU2, agent behaviours must be implemented using C++. 

.. tabs::

  .. code-tab:: cpp

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Get the value of agent variable 'x' and store it in local variable 'x'
        int x = FLAMEGPU->getVariable<int>("x");

        // Modify the variable in some way
        x = x + 1;

        // Store the updated value in the agent's 'x' variable
        FLAMEGPU->setVariable<int>("x", x);

        // Other behaviour code
        ...
    }

Agent variables can also be arrays, accessing these requires extra arguments. It is not possible to retrieve or set a full array
in a single function call, during agent functions, elements must be accessed individually.

.. tabs::

  .. code-tab:: cpp

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Return agent variable 'location[1]' and store it in local variable 'y'
        // The length of the array must be passed as the second template argument, in this example the array has a length of 3
        int y = FLAMEGPU->getVariable<int, 3>("location", 1);

        // Update the local copy
        y++;

        // Store the updated local copy in the agent's 'location[1]' variable
        FLAMEGPU->setVariable<int, 3>("location", y, 1);

        // Other behaviour code
        ...
    }