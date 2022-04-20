.. _device environment:

Accessing the Environment
^^^^^^^^^^^^^^^^^^^^^^^^^

As detailed in the earlier chapter detailing the :ref:`defining of environmental properties<defining environmental properties>`, there are two types of environment property which can be interacted with in agent functions. The :class:`DeviceEnvironment<flamegpu::DeviceEnvironment>` instance can be accessed, to interact with both of these, via ``FLAMEGPU->environment``.

Environment Properties
----------------------

Agent functions can only read environmental properties. If you wish to modify an environmental property, this must be done
via :ref:`host functions<host environment>`.

Environmental properties are accessed, using :class:`DeviceEnvironment<flamegpu::DeviceEnvironment>`, as follows:

.. tabs::

  .. code-tab:: cuda CUDA C++

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Get the value of environment property 'interaction_radius' and store it in local variable 'interaction_radius'
        float interaction_radius = FLAMEGPU->environment.getProperty<float>("interaction_radius");

        // Other behaviour code
        ...
    }
    

Environment Macro Properties
----------------------------

Agent functions have much greater access to environmental macroscopic properties, however they still cannot be directly written to, or both updated and read in the same layer.

Environmental macro properties can be read, via the returned :class:`DeviceMacroProperty<flamegpu::DeviceMacroProperty>`, as follows:

.. tabs::

  .. code-tab:: cuda CUDA C++

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Get the single float from environment macro property 'float1' and store it in local variable 'test_float'
        float test_float = FLAMEGPU->environment.getMacroProperty<float>("float1");
        // Get the root of the 3x3x3x3 environment macro property 'big_prop' and store it in a variable of the same name
        auto bigprop = FLAMEGPU->environment.getMacroProperty<int, 3, 3, 3, 3>("big_prop");
        // Copy the value from location [1,1,1,1] to the variable t
        int t = big_prop[1][1][1][1];

        // Other behaviour code
        ...
    }
    
They can also be updated with a selection of functions, which execute atomically. These functions will update a single variable and return information related to it's old or new state. This can be useful, for simple actions such as conflict resolution and counting. However, if a basic read is subsequently required, a separate host or agent function in a following layer must be used (otherwise there would be a race condition). If running with ``SEATBELTS`` error checking enabled, an exception should be thrown where potential race conditions are detected.

Macro properties support the normal :func:`+<flamegpu::DeviceMacroProperty::operator+>`, :func:`-<flamegpu::DeviceMacroProperty::operator->`, :func:`+=<flamegpu::DeviceMacroProperty::operator+=>`, :func:`-=<flamegpu::DeviceMacroProperty::operator-=>`, :func:`++<flamegpu::DeviceMacroProperty::operator++>`, :func:`--<flamegpu::DeviceMacroProperty::operator-->` operations. They also have access to a limited set of additional functions, explained in the table below.

.. note::

  :class:`DeviceMacroProperty<flamegpu::DeviceMacroProperty>` update support is limited to specific variable types. This varies between functions however ``uint32_t`` has the widest support, for full explanation check the API docs.


================================================================== ===================================================== ============================
Method                                                             Supported Types                                       Description
================================================================== ===================================================== ============================
:func:`min(val)<flamegpu::DeviceMacroProperty::min>`               ``int32_t``, ``uint32_t``, ``uint64_t``               Update property according to ``val < old ? val : old`` and return it's new value.
:func:`max(val)<flamegpu::DeviceMacroProperty::max>`               ``int32_t``, ``uint32_t``, ``uint64_t``               Update property according to ``val > old ? val : old`` and return it's new value.
:func:`CAS(compare, val)<flamegpu::DeviceMacroProperty::CAS>`      ``int32_t``, ``uint32_t``, ``uint64_t``, ``uint16_t`` Update property according to ``old == compare ? val : old`` and return ``old``.
:func:`exchange(val)<flamegpu::DeviceMacroProperty::exchange>`     ``int32_t``, ``uint32_t``, ``float``                  Update property to match val, and return ``old``.
================================================================== ===================================================== ============================


Example usage is shown below:

.. tabs::

  .. code-tab:: cuda CUDA C++

    FLAMEGPU_AGENT_FUNCTION(ExampleFn, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Get the root of the 3x3x3 environment macro property 'location' and store it in a variable of the same name
        auto location = FLAMEGPU->environment.getMacroProperty<unsigned int, 3, 3, 3>("location");
        // Notify our location, of our presence and store how many other agents were there before us in `location_count`
        unsigned int location_count = location[0][1][2]++;
        
        
        // Get the root of the float environment macro property 'swap' and store it in a variable of the same name
        auto swap = FLAMEGPU->environment.getMacroProperty<float>("swap");
        // Fetch and replace the value present in swap
        float location_count = swap.exchange(12.0f);
        
        // Directly accessing the value of either macro property now in the same agent function would cause a race condition
        // unsigned int location_val = location[0][0][0]; // DeviceError!
        // float swap_val = swap; // DeviceError!

        // Other behaviour code
        ...
    }
    
    
Related Links
-------------

* User Guide Page: :ref:`Defining Environmental Properties<defining environmental properties>`
* User Guide Page: :ref:`Host Functions: Accessing the Environment<host environment>`
* User Guide Page: :ref:`What is SEATBELTS?<SEATBELTS>`
* Full API documentation for :class:`DeviceEnvironment<flamegpu::DeviceEnvironment>`
* Full API documentation for :class:`DeviceMacroProperty<flamegpu::DeviceMacroProperty>`