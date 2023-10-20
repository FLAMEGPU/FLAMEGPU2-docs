.. _Host Agent Operations:

Agent Operations
^^^^^^^^^^^^^^^^

Host agent operations are performed on a single agent state, via :class:`HostAgentAPI<flamegpu::HostAgentAPI>`, the state can be omitted if agents exist within the default state.

.. tabs::

  .. code-tab:: cpp C++
  
    FLAMEGPU_HOST_FUNCTION(example_agent_hostfn) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");
        // Retrieve the host agent tools for agent wolf in the hungry state
        flamegpu::HostAgentAPI hungry_wolf = FLAMEGPU->agent("wolf", "hungry");
    }

  .. code-tab:: py Python
  
    class example_agent_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Retrieve the host agent tools for agent sheep in the default state
        sheep = FLAMEGPU.agent("sheep");
        # Retrieve the host agent tools for agent wolf in the hungry state
        hungry_wolf = FLAMEGPU.agent("wolf", "hungry");


.. _Agent Variable Reductions:

Variable Reductions
-------------------

Various reduction operators are provided, to allow specific agent variables to be reduced across the population.


.. list-table:: HostAgentAPI Reduction Methods
   :widths: 11 25 64
   :header-rows: 1
   
   * - Method
     - Arguments
     - Description
   * - :func:`sum()<flamegpu::HostAgentAPI::sum>`
     - ``variable``
     - Returns the sum of the specified agent variable.
   * - :func:`meanStandardDeviation()<flamegpu::HostAgentAPI::meanStandardDeviation>`
     - ``variable``
     - Returns a pair of doubles, the first item being the mean, and the second the standard deviation of the specified agent variable.
   * - :func:`min()<flamegpu::HostAgentAPI::min>`
     - ``variable``
     - Returns the minimum value of the specified agent variable.
   * - :func:`max()<flamegpu::HostAgentAPI::max>`
     - ``variable``
     - Returns the maximum value of the specified agent variable.
   * - :func:`count()<template<typename InT> unsigned int flamegpu::HostAgentAPI::count(const std::string &, const InT &)>`
     - ``variable``, ``value``
     - Returns the number of agents with the specified value of the specified agent variable.
   * - :func:`histogramEven()<flamegpu::HostAgentAPI::histogramEven>`
     - ``variable``, ``histogramBins``, ``lowerBound``, ``upperBound``
     - Returns a histogram of the specified agent variable, with evenly spaced bins in the inclusive-exclusive range [lowerBounds, upperBound)

As with most variable operations, these require the variable type to be specified as a template argument (appended to the method name in Python).

The C++ interface optionally allows the output type for ``sum`` and ``histogramEven`` to be specified as a second template argument too.

.. tabs::

  .. code-tab:: cpp C++
  
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
        // Fetch the mean and standard deviation of sheep health
        std::pair<double, double> mean_sd = sheep.meanStandardDeviation<float>("health");
        double mean_health = mean_sd.first;
        double standard_dev_health = mean_sd.second;
    }

  .. code-tab:: py Python
  
    # Define an host function called reduce_hostfn
    class reduce_hostfn(pyflamegpu.HostFunction):
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
        # Fetch the mean and standard deviation of sheep health
        mean_health, standard_dev_health = sheep.meanStandardDeviationFloat("health");

The C++ API also has access to custom reduction and transform-reduction operations:

.. tabs::
  .. code-tab:: cpp C++
  
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
    
Sorting Agents
--------------
Agent populations can also be sorted according to a variable, the C++ API can additionally sort according to two variables. 

.. note::

  FLAME GPU 2 may automatically sort agent populations that are outputting spatial messages, as this can significantly improve performance when reading messages.

.. tabs::

  .. code-tab:: cpp C++
  
    FLAMEGPU_HOST_FUNCTION(reduce_hostfn) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");
        // Sort the sheep population according to their health variable
        sheep.sort<float>("health", HostAgentAPI::ASC);
        // Sort the sheep population according to their awake variables, those with equal awake variables are sub-sorted by health
        sheep.sort<int, float>("awake", HostAgentAPI::DESC, "health", HostAgentAPI::ASC);
    }

  .. code-tab:: py Python
    
    class reduce_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Retrieve the host agent tools for agent sheep in the default state
        sheep = FLAMEGPU.agent("sheep");
        # Sort the sheep population according to their health variable
        sheep.sortFloat("health", pyflamegpu.HostAgentAPI.ASC);

.. _Host Agent Creation:

Agent Creation
--------------

.. note::
  
  These agents are not created until after the layer has completed execution, so they will not affect reductions or sorts carried out in the same host function. 

It's also possible to create new agents with the :class:`HostAgentAPI<flamegpu::HostAgentAPI>`, this is the preferred method of host agent creation as it performs a single host-device memory copy.

:func:`newAgent()<flamegpu::HostAgentAPI::newAgent>` returns an instance of :class:`HostNewAgentAPI<flamegpu::HostNewAgentAPI>`, this can be used like other objects to set and get a new agent's variables via :func:`setVariable()<flamegpu::HostNewAgentAPI::setVariable>` and :func:`getVariable()<flamegpu::HostNewAgentAPI::getVariable>`. Additionally, :func:`getID()<flamegpu::HostNewAgentAPI::getID>` can be used to retrieve the ID which will be assigned to the new agent.

.. tabs::
  
  .. code-tab:: cpp C++

    FLAMEGPU_HOST_FUNCTION(CreateNewSheep) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");

        // Create 10 new 'sheep' agents
        for (int i = 0; i < 10; ++i) {
            flamegpu::HostNewAgentAPI new_sheep = sheep.newAgent();
            new_sheep.setVariable<int>("awake", 1);
            new_sheep.setVariable<float>("health", 100.0f - i);
            new_sheep.setVariable<int, 3>("genes", {12, 2, 45});
        }
    }

  .. code-tab:: py Python
    
    class CreateNewSheep(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Retrieve the host agent tools for agent sheep in the default state
        sheep = FLAMEGPU.agent("sheep");
        
        # Create 10 new 'sheep' agents
        for i in range(10):
            new_sheep = sheep.newAgent()
            new_sheep.setVariableInt("awake", 1)
            new_sheep.setVariableFloat("health", 100 - i)
            new_sheep.setVariableArrayInt("genes", [12, 2, 45])

.. _Direct Agent Access:

Direct Agent Access
-------------------

For raw access to agent data, :class:`DeviceAgentVector<flamegpu::DeviceAgentVector_impl>` can be used. This has an interface similar to :class:`AgentVector<flamegpu::AgentVector>` (and hence ``std::vector``), however automatically synchronises data movement between host and device. This should only be used in limited circumstances as copying memory between host and device has high latency (although the implementation attempts to minimise unnecessary data transfers).

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    FLAMEGPU_HOST_FUNCTION(deviceagentvector_hostfn) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");
        // Get DeviceAgentVector to the sheep population
        flamegpu::DeviceAgentVector sheep_vector = sheep.getPopulationData();
        // Set all sheep's health back to 100
        for(auto s : sheep_vector)
            s.setVariable<float>("health", 100.0f);
    }
    
  .. code-tab:: python

    class deviceagentvector_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Retrieve the host agent tools for agent sheep in the default state
        sheep = FLAMEGPU.agent("sheep")
        # Get DeviceAgentVector to the sheep population
        sheep_vector = sheep.getPopulationData()
        # Set all sheep's health back to 100
        for s in sheep_vector:
            s.setVariableFloat("health", 100)
            
:class:`DeviceAgentVector<flamegpu::DeviceAgentVector_impl>` can also be used to create and remove agents. However, this level of interaction with agent populations is discouraged and is likely to impact performance if used regularly (e.g. as a step or host-layer function). The host agent creation method :ref:`demonstrated above<Host Agent Creation>` should be used where possible.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
    FLAMEGPU_HOST_FUNCTION(deviceagentvector_hostfn) {
        // Retrieve the host agent tools for agent sheep in the default state
        flamegpu::HostAgentAPI sheep = FLAMEGPU->agent("sheep");
        // Remove the first agent
        av.erase(0);
        // Add a default initialised agent to the end of the vector
        av.push_back();
        // Initialise the new agent's non-default variables
        av.back().setVariable<float>("health", 50.0f);
        av.back().setVariable<int, 3>("genes", {12, 2, 45});        
    }
    
  .. code-tab:: python

    class deviceagentvector_hostfn(pyflamegpu.HostFunction):
      def run(self,FLAMEGPU):
        # Retrieve the host agent tools for agent sheep in the default state
        sheep = FLAMEGPU.agent("sheep")
        // Remove the first agent
        av.erase(0)
        // Add a default initialised agent to the end of the vector
        av.push_back()
        // Initialise the new agent's non-default variables
        av.back().setVariableFloat("health", 50.0f)
        av.back().setVariableArrayInt("genes", [12, 2, 45])
        
Additionally, :func:`syncChanges()<flamegpu::DeviceAgentVector_impl::syncChanges>` can be called, to explicitly push any changes back to device. Allowing changes to impact :ref:`agent reductions<Agent Variable Reductions>`.

Miscellaneous Methods
---------------------
These other methods are also available within :class:`HostAgentAPI<flamegpu::HostAgentAPI>` for use within host functions:

.. list-table::
   :widths: 15 15 70
   :header-rows: 1
   
   * - Method
     - Return
     - Description
   * - :func:`count()<flamegpu::HostAgentAPI::count>` 
     - ``unsigned int``  
     - Returns the number of agents within the selected agent (state) population. Not to be confused with the :func:`count()<template<typename InT> unsigned int flamegpu::HostAgentAPI::count(const std::string &, const InT &)>` reduction method, this version takes no arguments.



Related Links
-------------

* User Guide Page: :ref:`Defining Agents<Defining Agents>`
* Full API documentation for :class:`HostAgentAPI<flamegpu::HostAgentAPI>`
* Full API documentation for :class:`HostNewAgentAPI<flamegpu::HostNewAgentAPI>`
* Full API documentation for :class:`DeviceAgentVector<flamegpu::DeviceAgentVector_impl>`
