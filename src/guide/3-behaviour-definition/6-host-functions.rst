.. _Host Functions:

Host Functions
==============

Not all model behaviours can be achieved with agent functions. Some behaviours need to operate over at a level above agents, host functions provide this functionality. If you need to perform a reduction over an agent population, sort agents or update environment properties a host function can deliver.

Defining Host Functions
-------------------------
Host functions have a similar interface to agent functions, however the core difference is that Python API host functions are implemented in Python.

Example definition:

.. tabs::

  .. code-tab:: cuda CUDA C++
     
    // Define an host function called host_fn1
    FLAMEGPU_HOST_FUNCTION(host_fn1) {
        // Behaviour goes here
    }

    int main() {
    ... // Rest of code

  .. code-tab:: python

    # Define an host function called host_fn1
    class host_fn1(pyflamegpu.HostFunctionCallback):
      '''
         The explicit __init__() is optional, however if used the superclass __init__() must be called
      '''
      def __init__(self):
        super().__init__()

      def run(self,FLAMEGPU):
        # Behaviour goes here
    
Adding Host Functions to a Model
---------------------------------

There are several ways that host functions can be added to a model; init, exit, step and layer.

They can be added as init functions, which execute once at the start when ``CUDASimulation::simulate()`` is called.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define a new model
    flamegpu::ModelDescription model("Test Model");
    ... // Rest of model definition
    // Add the init function host_fn1 to Test Model
    model.addInitFunction(host_fn1);

  .. code-tab:: python
  
    # Define a new model
    model = pyflamegpu.ModelDescription("Test Model");
    ... # Rest of model definition
    # Add the init function host_fn1 to Test Model
    model.addInitFunctionCallback(host_fn1().__disown__());




They can be added as exit functions, which execute once after all steps have completed when ``CUDASimulation::simulate()`` is called.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define a new model
    flamegpu::ModelDescription model("Test Model");
    ... // Rest of model definition
    // Add the exit function host_fn1 to Test Model
    model.addExitFunction(host_fn1);

  .. code-tab:: python
  
    # Define a new model
    model = pyflamegpu.ModelDescription("Test Model");
    ... # Rest of model definition
    # Add the exit function host_fn1 to Test Model
    model.addExitFunctionCallback(host_fn1().__disown__());
    


They can be added as step functions, which execute each model step after all layers have executed.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define a new model
    flamegpu::ModelDescription model("Test Model");
    ... // Rest of model definition
    // Add the step function host_fn1 to Test Model
    model.addStepFunction(host_fn1);

  .. code-tab:: python
  
    # Define a new model
    model = pyflamegpu.ModelDescription("Test Model");
    ... # Rest of model definition
    # Add the step function host_fn1 to Test Model
    model.addStepFunctionCallback(host_fn1().__disown__());


    
    
They can also be added to individual layers, so that they can execute between agent functions each model step.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define a new model
    flamegpu::ModelDescription model("Test Model");
    ... // Rest of model definition
    // Define a new layer
    flamegpu::Layer Description &layer1 = model.newLayer();
    // Add the host function host_fn1 to the layer
    layer1.addHostFunction(host_fn1);

  .. code-tab:: python
  
    # Define a new model
    model = pyflamegpu.ModelDescription("Test Model");
    ... # Rest of model definition
    # Define a new layer
    layer1 = model.newLayer();
    # Add the host function host_fn1 to the layer
    layer1.addHostFunctionCallback(host_fn1().__disown__());
    

Writing Host Functions
---------------------------------
Host functions have access to the ``HostAPI``. This has similarities to the ``DeviceAPI`` available within agent functions, however different functionality is available.

**Agent Tools**

Host agent operations are performed on a single agent state, the state can be omitted if agents exist within the default state.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called read_env_hostfn
    FLAMEGPU_HOST_FUNCTION(read_env_hostfn) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");
        // Retrieve the host agent tools for agent wolf in the hungry state
        flamegpu::HostAgentAPI hungry_wolf = FLAMEGPU->agent("wolf", "hungry");
    }

  .. code-tab:: python
  
    class read_env_hostfn(pyflamegpu.HostFunctionCallback):
      def run(self,FLAMEGPU):
        # Retrieve the host agent tools for agent sheep in the default state
        sheep = FLAMEGPU.agent("sheep");
        # Retrieve the host agent tools for agent wolf in the hungry state
        hungry_wolf = FLAMEGPU.agent("wolf", "hungry");

Various reduction operators are provided, to allow specific agent variables to be reduced across the population.

=================== ================================================================== ===================================================================================================================
Name                Arguments                                                          Description
=================== ================================================================== ===================================================================================================================
``sum``             ``variable``                                                       Returns the sum of the specified agent variable.
``sum``             ``variable``                                                       Returns the sum of the specified agent variable.
``min``             ``variable``                                                       Returns the minimum value of the specified agent variable.
``max``             ``variable``                                                       Returns the maximum value of the specified agent variable.
``count``           ``variable``, ``value``                                            Returns the number of agents with the specified value of the specified agent variable.
``histogramEven``   ``variable``, ``histogramBins``, ``lowerBound``, ``upperBound``    Returns a histogram of the specified agent variable, with evenly spaced bins in the range [lowerBounds, upperBound)
=================== ================================================================== ===================================================================================================================

As with most variable operations, these require the variable type to be specified as a template argument (appended to the method name in Python). The C++ interface optionally the output type for ``sum`` and ``histogramEven`` to be specified too.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called reduce_hostfn
    FLAMEGPU_HOST_FUNCTION(reduce_hostfn) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");
        // Reduce for the min, max of the sheep agent's health variable
        float min_health = sheep.min<float>("health");
        float max_health = sheep.max<float>("health");
        // Reduce for the sum of the sheep agent's health variable with the output type double
        double sum_health = sheep.sum<float, double>("health");
        // Count the number of sheep with a health variable equal to 0
        unsigned int empty_health = sheep.count<float>("health", 0.0f);
        // Create a histogram of sheep health
        std::vector<unsigned int> health_hist = sheep.histogramEven<float>("health", 5, 0.0f, 100.001f);
    }

  .. code-tab:: python
  
    # Define an host function called reduce_hostfn
    class reduce_hostfn(pyflamegpu.HostFunctionCallback):
      def run(self,FLAMEGPU):
        # Retrieve the host agent tools for agent sheep in the default state
        sheep = FLAMEGPU.agent("sheep");
        # Reduce for the min, max, sum of the sheep agent's health variable
        min_health = sheep.minFloat("health");
        max_health = sheep.maxFloat("health");
        sum_health = sheep.sumFloat("health");
        # Count the number of sheep with a health variable equal to 0
        empty_health = sheep.countFloat("health", 0);
        # Create a histogram of sheep health
        health_hist = sheep.histogramEven("health", 5, 0, 100.001);

The C++ API also has access to custom reduction and transform-reduction operations:

.. tabs::
  .. code-tab:: cuda CUDA C++
  
    // Define a bespoke reduction operator sum
    FLAMEGPU_CUSTOM_REDUCTION(sum, a, b) {
        return a + b;
    }
    // Define a bespoke reduction operator
    FLAMEGPU_CUSTOM_TRANSFORM(is_even, a) {
        return static_cast<int>(a)%2 == 0 ? a : 0;
    }
  
    // Define an host function called customreduce_hostfn
    FLAMEGPU_HOST_FUNCTION(customreduce_hostfn) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");
        // Reduce for the sum of the sheep agent's health variable, the input value is 0
        double sum_health = sheep.reduce<float>("health", sum, 0.0f);
        // Reduce for the sum of the sheep agent's health variable's that are even, the input value is 0
        double sum_even_health = sheep.transformReduce<float, double>("health", is_even, sum, 0.0f);
    }

Agent populations can also be sorted according to a variable, the C++ API can additionally sort according to two variables. FLAMEGPU2 may automatically sort agent populations that are outputting spatial messages, as this can significantly improve performance when reading messages.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called reduce_hostfn
    FLAMEGPU_HOST_FUNCTION(reduce_hostfn) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");
        // Sort the sheep population according to their health variable
        sheep.sort<float>("health", HostAgentAPI::ASC);
        // Sort the sheep population according to their awake variables, those with equal awake variables are sub-sorted according by health
        sheep.sort<int, float>("awake", flamegpu.DESC, "health", flamegpu.ASC);
    }

  .. code-tab:: python
    
    # Define an host function called reduce_hostfn
    class reduce_hostfn(pyflamegpu.HostFunctionCallback):
      def run(self,FLAMEGPU):
        # Retrieve the host agent tools for agent sheep in the default state
        sheep = FLAMEGPU.agent("sheep");
        # Sort the sheep population according to their health variable
        sheep.sortFloat("health", flamegpu.ASC);


It's also possible to create new agents with the ``HostAgentAPI``, this is covered in `Section 6.2. <../6-agent-birth-death/2-agent-birth-host.html>`_. These agents are not created until after the layer has completed execution, so they will not affect reductions or sorts carried out in the same host function. This is the preferred method of host agent birth as it performs a single host-device memory copy.

For raw access to agent data, ``DeviceAgentVector`` can be used. This has an interface similar to ``AgentVector``, however automatically synchronises data movement between host and device. This should only be used in limited circumstances as copying memory between host and device has high latency.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called deviceagentvector_hostfn
    FLAMEGPU_HOST_FUNCTION(deviceagentvector_hostfn) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");
        // Get DeviceAgentVector to the sheep population
        flamegpu::DeviceAgentVector sheep_vector = sheep.getPopulationData();
        // Set all sheep's health back to 100
        for(auto s : sheep_vector)
            s.setVariable<float>("health", 100.0);

  .. code-tab:: python

    # Define an host function called deviceagentvector_hostfn
    class deviceagentvector_hostfn(pyflamegpu.HostFunctionCallback):
      def run(self,FLAMEGPU):
        # Retrieve the host agent tools for agent sheep in the default state
        sheep = FLAMEGPU.agent("sheep");
        # Get DeviceAgentVector to the sheep population
        sheep_vector = sheep.getPopulationData();
        # Set all sheep's health back to 100
        for s in sheep_vector:
            s.setVariableFloat("health", 100.0);
        

**Environment Tools**

``HostAPI`` access to environment properties goes further than the ``DeviceAPI``, allowing environment properties to be updated too. Only environment properties marked const, during model definition cannot be updated.

Reading environment properties:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called read_env_hostfn
    FLAMEGPU_HOST_FUNCTION(read_env_hostfn) {
        // Retrieve the environment property foo of type float
        const float foo = FLAMEGPU->environment.getProperty<float>("foo");
        // Retrieve the environment property bar of type int array[3]
        const std::array<float, 3> bar = FLAMEGPU->environment.getProperty<int, 3>("bar");
    }

  .. code-tab:: python
  
    # Define an host function called read_env_hostfn
    class read_env_hostfn(pyflamegpu.HostFunctionCallback):
      def run(self,FLAMEGPU):
        # Retrieve the environment property foo of type float
        foo = FLAMEGPU.environment.getPropertyFloat("foo");
        # Retrieve the environment property bar of type int array[3]
        bar = FLAMEGPU.environment.getPropertyArrayInt("bar");

Updating environment properties:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called write_env_hostfn
    FLAMEGPU_HOST_FUNCTION(write_env_hostfn) {
        // Update the environment property foo of type float
        FLAMEGPU->environment.setProperty<float>("foo", 12.0f);
        // Update the environment property bar of type int array[3]
        FLAMEGPU->environment.setProperty<int, 3>("bar", {1, 2, 3});
    }

    .. code-tab:: python
  
      # Define an host function called write_env_hostfn
      class write_env_hostfn(pyflamegpu.HostFunctionCallback):
        def run(self,FLAMEGPU):
          # Update the environment property foo of type float
          FLAMEGPU.environment.setPropertyFloat("foo", 12.0);
          # Update the environment property bar of type int array[3]
          FLAMEGPU.environment.setPropertyArrayInt("bar", [1, 2, 3]);


**Random Generation**

Usage of the ``HostAPI`` random methods matches that of the ``DeviceAPI``.

=================== ==================== =======================================================================================================
Name                Arguments            Description
=================== ==================== =======================================================================================================
``uniform``         -                    Returns a uniformly distributed floating point number in the inclusive-exclusive range [0, 1).
``uniform``         ``min``, ``max``     Returns a uniformly distributed integer in the inclusive range [min, max].
``normal``          -                    Returns a normally distributed floating point number with mean 0.0 and standard deviation 1.0.
``logNormal``       ``mean``, ``stddev`` Returns a log-normally distributed floating point number with the specified mean and standard deviation
=================== ==================== =======================================================================================================

When calling any of these methods the type must be specified. Most methods only support floating point types (e.g. ``float``, ``double``), with the exception of tha parameterised `uniform`` method which is restricted to integer types:

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called random_hostfn
    FLAMEGPU_HOST_FUNCTION(random_hostfn) {
        // Generate a uniform random float [0, 1)
        const float uniform_float = FLAMEGPU->random.uniform<float>();
        // Generate a uniform random integer [1, 10]
        const int uniform_int = FLAMEGPU->random.uniform<int>(1, 10);
    }

  .. code-tab:: python
  
    # Define an host function called random_hostfn
    class random_hostfn(pyflamegpu.HostFunctionCallback):
      def run(self,FLAMEGPU):
        # Generate a uniform random float [0, 1)
        uniform_float = FLAMEGPU.random.uniformFloat();
        # Generate a uniform random integer [1, 10]
        uniform_int = FLAMEGPU.random.uniformInt(1, 10);

Additionally the ``HostAPI`` random object has the ability to retrieve and update the seed used for random generation during the current model execution. However, for most users this will likely be unnecessary as the random seed can be configured before simulations are executed.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    // Define an host function called random_hostfn2
    FLAMEGPU_HOST_FUNCTION(random_hostfn2) {
        // Retrieve the current random seed
        const unsigned int old_seed = FLAMEGPU->random.getSeed();
        // Change the random seed to 12
        FLAMEGPU.random->setSeed(12);
    }

  .. code-tab:: python
  
    # Define an host function called random_hostfn2
    class random_hostfn2(pyflamegpu.HostFunctionCallback):
      def run(self,FLAMEGPU):
        # Retrieve the current random seed
        old_seed = FLAMEGPU.random.getSeed();
        # Change the random seed to 12
        FLAMEGPU.random.setSeed(12);

**Misc**

These other methods are also available within ``HostAPI`` for use within host functions:

===================== =========================== ===========================================================
Method                Return                      Description
===================== =========================== ===========================================================
``getStepCounter()``  ``unsigned int``            Returns the current step index, the first step has index 0.
===================== =========================== ===========================================================
