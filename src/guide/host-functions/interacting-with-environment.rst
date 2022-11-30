.. _host environment:

Accessing the Environment
^^^^^^^^^^^^^^^^^^^^^^^^^

As detailed in the earlier chapter detailing the :ref:`defining of environmental properties<defining environmental properties>`, there are two types of environment property which can be interacted with in host functions. Unlike :ref:`agent functions<device environment>`, host functions have full mutable access to both forms of environment property.

The :class:`HostEnvironment<flamegpu::HostEnvironment>` instance can be accessed in host functions via ``FLAMEGPU->environment``.


Environment Properties
----------------------

Host functions can both read and update environment properties using :func:`setProperty()<flamegpu::HostEnvironment::setProperty>` and :func:`getProperty()<flamegpu::HostEnvironment::getProperty>` respectively.

Unlike agent functions, host functions are able to access environment property arrays in a single transaction, rather than individually accessing each element. Otherwise, the syntax matches that found in agent functions.

Environmental properties are accessed, using :class:`HostEnvironment<flamegpu::HostEnvironment>`, as follows:

.. tabs::

  .. code-tab:: cpp C++

    FLAMEGPU_HOST_FUNCTION(ExampleHostFn) {
        // Get the value of scalar environment property 'scalar_f' and store it in local variable 'scalar_f'
        float scalar_f = FLAMEGPU->environment.getProperty<float>("scalar_f");
        // Set the value of the scalar environment property 'scalar_f'
        FLAMEGPU->environment.setProperty<float>("scalar_f", scalar_f + 1.0f);
    
        // Get the value of array environment property 'array_i3' and store it in local variable 'array_i3'
        std::array<int, 3> array_i3 = FLAMEGPU->environment.getProperty<int, 3>("array_i3");
        // Set the value of the array environment property 'array_i3'
        FLAMEGPU->environment.setProperty<int, 3>("array_i3", std::array<int, 3>{0, 0, 0});
        
        // Get the value of the 2nd element of the array environment property 'array_u4'
        unsigned int array_u4_1 = FLAMEGPU->environment.getProperty<unsigned int>("array_u4", 1);
        // Set the value of the 3rd element of the array environment property 'array_u4'
        FLAMEGPU->environment.setProperty<unsigned int>("array_u4", 2, array_u4_1 + 2u);
    }

  .. code-tab:: py Python

    class ExampleHostFn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Get the value of scalar environment property 'scalar_f' and store it in local variable 'scalar_f'
        scalar_f = FLAMEGPU.environment.getPropertyFloat("scalar_f")
        # Set the value of the scalar environment property 'scalar_f'
        FLAMEGPU.environment.setPropertyFloat("scalar_f", scalar_f + 1.0)
    
        # Get the value of array environment property 'array_i3' and store it in local variable 'array_i3'
        array_i3 = FLAMEGPU.environment.getPropertyArrayInt("array_i3")
        # Set the value of the array environment property 'array_i3'
        FLAMEGPU.environment.setPropertyArrayInt("array_i3", [0, 0, 0])
        
        # Get the value of the 2nd element of the array environment property 'array_u4'
        array_u4_1 = FLAMEGPU.environment.getPropertyUInt("array_u4", 1)
        # Set the value of the 3rd element of the array environment property 'array_u4'
        FLAMEGPU.environment.setPropertyUInt("array_u4", 2, array_u4_1 + 2)
        
.. note:
  There are inconsistencies as to when an environment property array's length must be specified.
  It is only required here when accessing a whole array via the C++ API.
    
.. _host macro property:

Environment Macro Properties
----------------------------

Similar to regular environment properties, macro environment properties can be read and updated within host functions.

Environmental macro properties can be read via the returned :class:`HostMacroProperty<flamegpu::HostMacroProperty>`, as follows:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called read_env_hostfn
    FLAMEGPU_HOST_FUNCTION(read_env_hostfn) {
        // Retrieve the environment macro property foo of type float
        const float foo = FLAMEGPU->environment.getMacroProperty<float>("foo");
        // Retrieve the environment macro property bar of type int array[3][3][3]
        auto bar = FLAMEGPU->environment.getMacroProperty<int, 3, 3, 3>("bar");
        const int bar_1_1_1 = bar[1][1][1];
    }

  .. code-tab:: python
  
    # Define an host function called read_env_hostfn
    class read_env_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Retrieve the environment macro property foo of type float
        foo = FLAMEGPU->environment.getMacroPropertyFloat("foo");
        # Retrieve the environment macro property bar of type int array[3][3][3]
        bar = FLAMEGPU.environment.getMacroPropertyInt("bar");
        bar_1_1_1 = bar[1][1][1];

Macro properties in host functions are designed to behave as closely to their representative data type as possible. So most assignment and arithmetic operations should behave as expected.

Python has several exceptions to this rule:

* The assignment operator is only available when it maps to ``__setitem__(index, val)`` (e.g. ``foo[0] = 10``)
* The increment/decrement operators are not available, as they cannot be overridden.

Below are several examples of how environment macro properties can be updated in host functions:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called write_env_hostfn
    FLAMEGPU_HOST_FUNCTION(write_env_hostfn) {
        // Retrieve the environment macro property foo of type float
        auto foo = FLAMEGPU->environment.getMacroProperty<float>("foo");
        // Retrieve the environment macro property bar of type int array[3][3][3]
        auto bar = FLAMEGPU->environment.getMacroProperty<int, 3, 3, 3>("bar");
        // Update some of the values
        foo = 12.0f;
        bar[0][0][0]+= 1;
        bar[0][1][0] = 5;
        ++bar[0][0][2];
    }

  .. code-tab:: python
  
    # Define an host function called write_env_hostfn
    class write_env_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
      # Retrieve the environment macro property foo of type float
      foo = FLAMEGPU->environment.getMacroPropertyFloat("foo");
      # Retrieve the environment macro property bar of type int array[3][3][3]
      bar = FLAMEGPU.environment.getMacroPropertyInt("bar");
      # Update some of the values
      # foo = 12.0; is not allowed
      foo.set(12.0);
      foo[0] = 12.0; # This is the same as calling set()
      bar[0][0][0]+= 1;
      bar[0][1][0] = 5;
      bar[0][0][2]+= 1; # Python does not allow the increment operator to be overridden
      
.. warning::
  Be careful when using :class:`HostMacroProperty<flamegpu::HostMacroProperty>` via the C++ API. When you retrieve an element e.g. ``bar[0][0][0]`` (from the example above), it is of type :class:`HostMacroProperty<flamegpu::HostMacroProperty>` not ``int``. Therefore you cannot pass it directly to functions which take generic arguments such as ``printf()``, as it will be interpreted incorrectly. You must either store it in a variable of the correct type which you instead pass, or explicitly cast it to the correct type when passing it e.g. ``(int)bar[0][0][0]`` or ``static_cast<int>(bar[0][0][0])``.
    
Related Links
-------------

* User Guide Page: :ref:`Defining Environmental Properties<defining environmental properties>`
* User Guide Page: :ref:`Agent Functions: Accessing the Environment<device environment>`
* Full API documentation for :class:`HostEnvironment<flamegpu::HostEnvironment>`
* Full API documentation for :class:`HostMacroProperty<flamegpu::HostMacroProperty>`