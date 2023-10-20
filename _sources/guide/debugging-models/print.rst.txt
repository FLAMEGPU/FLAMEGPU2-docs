.. _debugging_with_printf:

Using Print Statements
======================

.. Workaround for nested markup https://docutils.sourceforge.io/FAQ.html#is-nested-inline-markup-possible
.. |printf| replace:: ``printf()``
.. _printf: https://cplusplus.com/reference/cstdio/printf
.. |print| replace:: ``print()``
.. _print: https://docs.python.org/3/library/functions.html#print

Using |printf|_ (or |print|_ within python) is the usual first step towards debugging.

C++ and Python share very similar syntax

.. tabs::

  .. code-tab:: cpp C++

    // Note C++ does not implicitly terminate the string with a line-break
    printf("%f: %d\n", foo, bar);

.. tabs::

  .. code-tab:: py Python
  
    # Note Python implicitly terminates the string with a line-break
    print('%f: %d'%(foo, bar)) 
    
These statements can be used in C++ and Python host functions respectively to print messages to console.

Printing From Agent Functions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Agent C++ requires using the ``printf()`` syntax, :ref:`Agent Python<Python Agent Functions>` will not transform python ``print()`` statements to the Agent C++ equivalent.

However, as agent functions execute for potentially millions of agents in parallel there are some additional things which should be considered:

**Volume**

Attempting to ``printf()`` from millions of agents simultaneously *can lead to programs crashing*. There isn't a hard rule for how much is too much, but printing from agent functions should be limited to a subset of the agent population or performed with small agent populations.

**Performance**

Printing from agent functions, causes data to be copied from the GPU in order for it to be printed. Large amounts of printing can have a large performance impact

**Order**

Messages printed by different agents are likely to occur out of order, as CUDA threads are not guaranteed to execute in order. Therefore it may be useful to include an identifier of each message's source agent (e.g. using the ``%u`` returned by ``FLAMEGPU->getID()``).

**Environment Macro Properties**

Due to how ``printf()`` supports generic type arguments the implicit cast, normally performed when reading macro environment properties, is not performed. As such, attempting to print an environment macro property directly will lead to an undefined value being printed. The below code provides examples that should and should not be used.

.. tabs::

  .. code-tab:: cuda Agent C++
    
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Retrieve the macro property
        auto foo = FLAMEGPU->environment.getMacroProperty<int, 4>("foo");
        
        // These can be used to print a property
        printf("%d\n", (int)foo[0]);
        printf("%d\n", static_cast<int>(foo[1]));
        const int bar = foo[2];
        printf("%d\n", bar);
        
        
        // This should not be used, it will compile but produce bad output
        printf("%d\n", foo[3]);
    }

Related Links
-------------
* User Guide: :ref:`Python Agent Functions<Python Agent Functions>`