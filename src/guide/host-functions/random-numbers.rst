.. _host random:

Random Numbers
^^^^^^^^^^^^^^

Usage of the :class:`HostAPI<flamegpu::HostAPI>` random methods matches that of the :class:`DeviceAPI<flamegpu::DeviceAPI>`. The :class:`HostRandom<flamegpu::HostRandom>` instance can be accessed in agent functions via ``FLAMEGPU->random``.

These random numbers are seeded according to the simulation's random seed specified at runtime. This can be read and updated via host functions (see :ref:`further down this page<host seed random>`).

=================== ==================== =======================================================================================================
Name                Arguments            Description
=================== ==================== =======================================================================================================
``uniform``                              Returns a uniformly distributed floating point number in the inclusive-exclusive range [0, 1).
``uniform``         ``min``, ``max``     Returns a uniformly distributed integer in the inclusive range [min, max].
``normal``                               Returns a normally distributed floating point number with mean 0.0 and standard deviation 1.0.
``logNormal``       ``mean``, ``stddev`` Returns a log-normally distributed floating point number with the specified mean and standard deviation
=================== ==================== =======================================================================================================

When calling any of these methods the type must be specified. Most methods only support floating point types (e.g. ``float``, ``double``), with the exception of the parametrised ``uniform`` method which is restricted to integer types:

.. tabs::

  .. code-tab:: cpp C++
  
    // Define an host function called random_hostfn
    FLAMEGPU_HOST_FUNCTION(random_hostfn) {
        // Generate a uniform random float [0, 1)
        const float uniform_float = FLAMEGPU->random.uniform<float>();
        // Generate a uniform random integer [1, 10]
        const int uniform_int = FLAMEGPU->random.uniform<int>(1, 10);
    }

  .. code-tab:: py python
  
    # Define an host function called random_hostfn
    class random_hostfn(pyflamegpu.HostFunction):
      def run(self, FLAMEGPU):
        # Generate a uniform random float [0, 1)
        uniform_float = FLAMEGPU.random.uniformFloat()
        # Generate a uniform random integer [1, 10]
        uniform_int = FLAMEGPU.random.uniformInt(1, 10)


.. _host seed random:

Seeding the Random State
------------------------
        
Additionally the :class:`HostAPI<flamegpu::HostAPI>` random object has the ability to retrieve and update the seed used for random generation during the current model execution. However, for most users this will likely be unnecessary as the random seed can be configured before simulations are executed.

.. tabs::

  .. code-tab:: cpp C++
  
    // Define an host function called random_hostfn2
    FLAMEGPU_HOST_FUNCTION(random_hostfn2) {
        // Retrieve the current random seed
        const unsigned int old_seed = FLAMEGPU->random.getSeed();
        // Change the random seed to 12
        FLAMEGPU.random->setSeed(12);
    }

  .. code-tab:: py python
  
    # Define an host function called random_hostfn2
    class random_hostfn2(pyflamegpu.HostFunction):
      def run(self, FLAMEGPU):
        # Retrieve the current random seed
        old_seed = FLAMEGPU.random.getSeed()
        # Change the random seed to 12
        FLAMEGPU.random.setSeed(12)

Related Links
-------------
* User Guide Page: :ref:`Random Numbers<device random>` (Agent Functions)
* User Guide Page: :ref:`Configuring Execution<Configuring Execution>`
* Full API documentation for :class:`HostRandom<flamegpu::HostRandom>`