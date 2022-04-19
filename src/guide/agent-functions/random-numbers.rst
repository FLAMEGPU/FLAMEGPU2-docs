.. _device random:

Random Numbers
^^^^^^^^^^^^^^

Usage of the :class:`DeviceAPI<flamegpu::DeviceAPI>` random methods matches that of the :class:`HostAPI<flamegpu::HostAPI>`. The :class:`AgentRandom<flamegpu::AgentRandom>` instance can be accessed in agent functions via ``FLAMEGPU->random``.

These random numbers are seeded according to the simulation's random seed specified at runtime. This can be read and updated via host functions.

=================== ==================== =======================================================================================================
Name                Arguments            Description
=================== ==================== =======================================================================================================
``uniform``                              Returns a uniformly distributed floating point number in the exclusive-inclusive range (0, 1].
``uniform``         ``min``, ``max``     Returns a uniformly distributed integer in the inclusive range [min, max].
``normal``                               Returns a normally distributed floating point number with mean 0.0 and standard deviation 1.0.
``logNormal``       ``mean``, ``stddev`` Returns a log-normally distributed floating point number with the specified mean and standard deviation
=================== ==================== =======================================================================================================

When calling any of these methods the type must be specified. Most methods only support floating point types (e.g. ``float``, ``double``), with the exception of the parametrised ``uniform`` method which is restricted to integer types:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Generate a uniform random float [0, 1)
        const float uniform_float = FLAMEGPU->random.uniform<float>();
        // Generate a uniform random integer [1, 10]
        const int uniform_int = FLAMEGPU->random.uniform<int>(1, 10);
        
        ...
    }

Related Links
-------------
* User Guide Page: :ref:`Random Numbers<host random>` (Host Functions)
* User Guide Page: :ref:`Configuring Execution<Configuring Execution>`
* Full API documentation for :class:`AgentRandom<flamegpu::AgentRandom>`