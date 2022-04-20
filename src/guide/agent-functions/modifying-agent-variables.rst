Accessing Agent Variables
^^^^^^^^^^^^^^^^^^^^^^^^^

Each instance of an agent will have its own variables as specified in the agent's description.
These can be accessed and modified within agent functions. 

Within an agent function, agent variables can be read via the :class:`DeviceAPI<flamegpu::DeviceAPI>` with :func:`getVariable()<flamegpu::DeviceAPI::getVariable>` and written to with :func:`setVariable()<flamegpu::DeviceAPI::setVariable>`.
These variables are accessed from higher latency device memory, so for the best performance, we recommended
that you avoid multiple reads or writes to the same variable in any agent functions and do as much as possible
with the local copy.


.. tabs::

  .. code-tab:: cuda CUDA C++

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Fetch the agent's ID
        flamegpu::id_t ID = FLAMEGPU->getID();
        
        // Get the value of agent variable 'x' and store it in local variable 'x'
        int x = FLAMEGPU->getVariable<int>("x");

        // Modify the variable in some way
        x += 2;

        // Store the updated value in the agent's 'x' variable
        FLAMEGPU->setVariable<int>("x", x);

        // Other behaviour code
        ...
    }

Agent variables can also be arrays, accessing these requires extra arguments. It is not possible to retrieve or set a full array
in a single function call, during agent functions elements can only be accessed individually.

.. tabs::

  .. code-tab:: cuda CUDA C++

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Return agent variable 'location[1]' and store it in local variable 'y'
        // The length of the array must be passed as the second template argument, in this example the array has a length of 3
        int y = FLAMEGPU->getVariable<int, 3>("location", 1);

        // Update the local copy
        y++;

        // Store the updated local copy in the agent's 'location[1]' variable
        FLAMEGPU->setVariable<int, 3>("location", 1, y);

        // Other behaviour code
        ...
    }
    
Reading an Agent's ID
---------------------

The built-in agent ID variable, which is unique to each agent instance, can also be accessed via the :func:`getID()<flamegpu::DeviceAPI::getID>` method. 
    
.. tabs::

  .. code-tab:: cuda CUDA C++

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Fetch the agent's ID, id_t is an unsigned int variable
        flamegpu::id_t ID = FLAMEGPU->getID();

        // Other behaviour code
        ...
    }

    
.. note ::
    To achieve the high performance of FLAME GPU 2, agent behaviours must be implemented as agent functions which execute on the GPU, rather than in host functions which run on the CPU. 

Related Links
-------------

* User Guide Page: :ref:`Defining Agents<defining agents>`
* Full API documentation for :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`