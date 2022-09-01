Agent Function Conditions (Conditional Behaviours)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Agent function conditions are primarily used to split agent populations, allowing them to diverge between agent states. As such, when creating an :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` the initial and end states for the executing agent should be specified if using more than the default agent state. Following this, all agents in the specified initial state will execute the agent function and move to the end state. In order to allow agents in the same state to diverge an agent function condition must be added to the function.

Agent function conditions are executed by all agents in the input state before the main agent function, and each agent must return either ``true``
or ``false``. Agents which return ``true`` pass the condition and continue to execute the agent function and transition
to the end state, agents which return ``false`` fail the condition, do not execute the agent function and remain in the input state.

Agent function conditions are specified using the :c:macro:`FLAMEGPU_AGENT_FUNCTION_CONDITION` in C++, this differs from the normal agent function macro as only the function condition name must be specified. Within Python, agent function conditions are specified using the ``@agent_function_condition`` attribute and then translated to C++ using the code generator. The Python function must have a return type annotation of `bool` and is not permitted to have any function arguments.

Within agent function conditions a reduced read-only Device API, :class:`ReadOnlyDeviceAPI<flamegpu::ReadOnlyDeviceAPI>`, is available. This only permits reading agent variables, reading environment variables and random number generation.

Example definition of an agent function condition:

.. tabs::

  .. code-tab:: cuda Agent C++

      // This agent function condition only allows agents who's 'x' variable equals '1' to progress
      FLAMEGPU_AGENT_FUNCTION_CONDITION(x_is_1) {
          return FLAMEGPU->getVariable<int>("x") == 1;
      }

  .. code-tab:: py Agent Python

      # This agent function condition only allows agents who's 'x' variable equals '1' to progress
      @pyflamegpu.agent_function_condition
      def py_x_is_1() -> bool :
          return pyflamegpu.getVariableInt("x") == 1

        
Much like regular agent functions the Python API must use the RTC interface so that the agent function conditions can be compiled at runtime.

Example definition of how the above agent function condition would be attached to an agent function:
    
.. tabs::

  .. code-tab:: cpp C++

      // A model is defined
      ModelDescription m("model");
      // It contains an agent with 'variable 'x' and two states 'foo' and 'bar'
      AgentDescription &a = m.newAgent("agent");
      a.newVariable<int>("x");
      a.newState("foo");
      a.newState("bar");
      // The agent has an agent function which transitions agents from state 'foo' to 'bar'
      AgentFunctionDescription &af1 = a.newFunction("example_function", ExampleFn);
      af1.setInitialState("foo");
      af1.setEndState("bar");
      // Only agents that pass function condition 'x_is_1' may execute the function and transition
      af1.setFunctionCondition(x_is_1);

  .. code-tab:: py Python
    
      # A model is defined
      m = pyflamegpu.ModelDescription("model")
      # It contains an agent with 'variable 'x' and two states 'foo' and 'bar'
      a = m.newAgent("agent")
      a.newVariableInt("x")
      a.newState("foo")
      a.newState("bar")
      # The agent has an agent function which transitions agents from state 'foo' to 'bar'
      af1 = a.newRTCFunction("example_function", ExampleFn_source)
      af1.setInitialState("foo")
      af1.setEndState("bar")
      # Only agents that pass function condition 'x_is_1' may execute the function and transition
      x_is_1_translated = pyflamegpu.codegen.translate(x_is_1)
      af1.setRTCFunctionCondition(x_is_1_translated)

  .. code-tab:: py Python (with Agent C++ Strings)
    
      # A model is defined
      m = pyflamegpu.ModelDescription("model")
      # It contains an agent with 'variable 'x' and two states 'foo' and 'bar'
      a = m.newAgent("agent")
      a.newVariableInt("x")
      a.newState("foo")
      a.newState("bar")
      # The agent has an agent function which transitions agents from state 'foo' to 'bar'
      af1 = a.newRTCFunction("example_function", ExampleFn_source)
      af1.setInitialState("foo")
      af1.setEndState("bar")
      # Only agents that pass function condition 'x_is_1' may execute the function and transition
      af1.setRTCFunctionCondition(x_is_1_cpp_source)    

.. note::
  
    If you wish to store C++ RTC agent function conditions in separate files :func:`setRTCFunctionCondition()<flamegpu::AgentFunctionDescription::setRTCFunctionCondition>` can be replaced with :func:`setRTCFunctionConditionFile()<flamegpu::AgentFunctionDescription::setRTCFunctionConditionFile>`, instead passing the path to the agent function conditions source file (relative to the working directory at runtime). This will allow them to be developed in a text editor with C++/CUDA syntax highlighting.
      
Related Links
-------------
* User Guide Page: :ref:`Defining Agent Functions<Defining Agent Functions>`
* Full API documentation for :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`
* Full API documentation for :c:macro:`FLAMEGPU_AGENT_FUNCTION_CONDITION`
* Full API documentation for :class:`ReadOnlyDeviceAPI<flamegpu::ReadOnlyDeviceAPI>`