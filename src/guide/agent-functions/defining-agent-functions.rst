.. _Defining Agent Functions:

Defining Agent Functions
^^^^^^^^^^^^^^^^^^^^^^^^

Agent Functions can be specified as CUDA functions, built at compile time when using the C++ API, or they can be specified as Run-Time Compiled (RTC) function strings when using the both the C++ and Python APIs.

An agent function is defined using the :c:macro:`FLAMEGPU_AGENT_FUNCTION` macro. 
This takes three arguments: a unique name identifying the function, an input message communication strategy, and an output message communication strategy.
We will discuss messages in more detail later, so for now don't worry about the second and third parameters. :class:`flamegpu::MessageNone` is specified when not requiring message input or output, so this is used.
Similarly, agent functions should return :enumerator:`flamegpu::ALIVE<flamegpu::AGENT_STATUS::ALIVE>` by default, agent death is explained in a :ref:`later section<agent birth death>` of this chapter.

For Non-RTC functions, when using the C++ API, the :c:macro:`FLAMEGPU_AGENT_FUNCTION` macro can be used to declare and define the agent function, which can then be associated with the :class:`AgentDescription<flamegpu::AgentDescription>` object using the :func:`newFunction()<flamegpu::AgentDescription::newFunction>` method.


.. tabs::

  .. code-tab:: cpp C++
     
    // Define an agent function called agent_fn1 - specified ahead of main function
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Behaviour goes here
        return flamegpu::ALIVE;
    }

    int main() {
        // ...

        // Attach a function called agent_fn1, defined by the symbol agent_fn1 to the AgentDescription object agent.
        flamegpu::AgentFunctionDescription &agent_fn1_description = agent.newFunction("agent_fn1", agent_fn1);

        // ...
    }

When using the Run-Time Compiled (RTC) functions, optionally in the C++ API or required by the Python API, the function must be defined in a string and associated with the :class:`AgentDescription<flamegpu::AgentDescription>` using the :func:`newRTCFunction()<flamegpu::AgentDescription::newRTCFunction>` method.

.. cpp syntax highlighting due to issues with the cuda highlighter and raw strings.
.. tabs::

  .. code-tab:: cpp C++

    const char* agent_fn1_source = R"###(
    // Define an agent function called agent_fn1 - specified ahead of main function
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Behaviour goes here
    }
    )###";

    int main() {
        ...

        // Attach a function called agent_fn1, defined in the string variable agent_fn1_source to the AgentDescription object agent.
        flamegpu::AgentFunctionDescription& agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

        ...
    }

  .. code-tab:: py Python

    # Define an agent function called agent_fn1
    agent_fn1_source = r"""
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, MessageNone, MessageNone) {
        # Behaviour goes here
    }
    """

    ...

    # Attach a function called agent_fn1 to an agent represented by the AgentDescription agent 
    # The AgentFunctionDescription is stored in the agent_fn1_description variable
    agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

    ...
    
.. note::

    If you wish to store RTC agent functions in separate files :func:`newRTCFunction()<flamegpu::AgentDescription::newRTCFunction>` can be replaced with :func:`newRTCFunctionFile()<flamegpu::AgentDescription::newRTCFunctionFile>`, instead passing the path to the agent function's source file (relative to the working directory at runtime). This will allow them to be developed in a text editor with C++/CUDA syntax highlighting.

FLAME GPU Device Functions
--------------------------

If you wish to define regular functions which can be called from agent functions, you can use the :c:macro:`FLAMEGPU_DEVICE_FUNCTION` macro:

.. tabs::

  .. code-tab:: cuda CUDA C++

    // Define a function for adding two integers which can be called inside agent functions.
    FLAMEGPU_DEVICE_FUNCTION int add(int a, int b) {
        return a + b;
    }
    


FLAME GPU Host Device Functions
-------------------------------

If you wish to define regular functions which can be called from within agent and host functions, you can use the :c:macro:`FLAMEGPU_HOST_DEVICE_FUNCTION` macro:

.. tabs::

  .. code-tab:: cuda CUDA C++

    // Define a function for subtracting two integers which can be called inside agent functions, or in host code
    FLAMEGPU_HOST_DEVICE_FUNCTION int subtract(int a, int b) {
        return a - b;
    }
    
    
Related Links
-------------
* Full API documentation for :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`
* Full API documentation for :c:macro:`FLAMEGPU_AGENT_FUNCTION`
* Full API documentation for :c:macro:`FLAMEGPU_DEVICE_FUNCTION`
* Full API documentation for :c:macro:`FLAMEGPU_HOST_DEVICE_FUNCTION`