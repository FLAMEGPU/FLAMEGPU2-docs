Environment Behaviour
=====================

Environment behaviour is defined using host functions, these can perform analysis over the whole agent population, create new agents and update the environmental properties.

Host Functions
--------------

Host functions within FLAMEGPU provide a means to execute model logic at
a higher level than individual agents, these are executed on the CPU (as
opposed to agent functions which are executed on the GPU), with a
different FLAMEGPU api than is available within agent functions.

Host functions are most commonly used for creating new agents, managing
environmental constants and performing analytics over the agent
population.

They can either be executed as part of a layer, similar to agent
functions, or called relative to the whole simulation (init function,
exit function) or each time step (step function)

Types of Host Function
~~~~~~~~~~~~~~~~~~~~~~

There are two forms of host function, functions and conditions, whereby
conditions must return a value.

These are added to a FLAMEGPU model as one of the below types: \*
**Init:** Executes once at the start of the simulation. \* **Step:**
Executes at the end of each simulation step. \* **Exit:** Executes once
at the end of the simulation. \* **Host (Layer):** Executes as part of
the specified layer. \* **Exit Condition:** Executes at the end of each
simulation step, after step functions.

The only differences between them are how they are defined and if they
have any return value.

============== =========================== ========================
Type           Macro                       Return
============== =========================== ========================
Init           ``FLAMEGPU_INIT_FUNCTION``  n/a
Step           ``FLAMEGPU_STEP_FUNCTION``  n/a
Exit           ``FLAMEGPU_EXIT_FUNCTION``  n/a
Host (Layer)   ``FLAMEGPU_HOST_FUNCTION``  n/a
Exit Condition ``FLAMEGPU_EXIT_CONDITION`` ``CONTINUE`` or ``EXIT``
============== =========================== ========================

Using Host Functions
~~~~~~~~~~~~~~~~~~~~

First the host function must be defined with one of the above listed
preprocessor macros, these expand to declare the function taking a
single argument ``FLAMEGPU_HOST_API* FLAMEGPU``.

The two below examples show how host functions might be declared. ####
Example of a Host Function

.. code:: cpp

   FLAMEGPU_STEP_FUNCTION(my_step_function) {
       // Do something on the host!
   }

Example of a Host Condition
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: cpp

   FLAMEGPU_EXIT_CONDITION(my_exit_condition) {
       if (someCondition)
           return EXIT;  // End the simulation here
       return CONTINUE;  // Continue the simulation
   }

Most host functions can then be added directly to your ``Simulation``
e.g.:

.. code:: cpp

   Simulation simulation(flame_model);
   simulation.addInitFunction(&my_init_function);
   simulation.addStepFunction(&my_step_function);
   simulation.addExitFunction(&my_exit_function);
   simulation.addExitCondition(&my_exit_condition);

Host (layer) functions are the exception to this, as they must be added
to a layer like agent functions:

.. code:: cpp

   SimulationLayer my_layer(simulation, "my_layer");
   my_layer.addAgentFunction("some_agent_function");
   my_layer.addHostFunction(&my_host_function);
   simulation.addSimulationLayer(my_layer);

**Note:** *``FLAMEGPU_***_FUNCTION`` macros can be used interchangeably,
if a host function is required in multiple locations (e.g. Init and
Step). The naming simply ensures improved visibility of function
purpose.*

FLAMEGPU Host API
-----------------

The FLAMEGPU Host API provides functionality within host functions for
managing the simulation, usage of this functionality is described below.

Environment Property Access
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Environment properties can be read and updated during host functions and
conditions (with the exception of properties that were marked as
constant, they cannot be changed), these can then be read during agent
functions.

The Host API’s methods for accessing environmental vars is very similar
to that used to initial the environment properties via
``EnvironmentDescription``.

.. code:: cpp

   FLAMEGPU_HOST_FUNCTION(my_host_function) {
       // Get property 'f_prop', type 'float'
       float float_prop = FLAMEGPU->environment.get<float>('f_prop');
       // Get property array 'ia_prop', length 4, type 'int'
       std::array<int, 4> int_prop = FLAMEGPU->environment.get<int, 4>('ia_prop');
       // Get the 2nd element, from property array `ia_prop`, type 'int'
       int ia_prop1 = FLAMEGPU->environment.get<int, 4>('ia_prop', 1);  // Elements are 0-indexed
       // Set 'fprop'
       FLAMEGPU->environment.set<float>('f_prop', 12.0f);    
       // Set 'ia_prop'
       FLAMEGPU->environment.set<int, 4>('ia_prop', {12, 13, 14, 15});    
       // Set 'ia_prop[1]'
       FLAMEGPU->environment.set<int>('ia_prop', 1, 13);
   }

Environment properties can also be created and removed during
simulations, however this is discouraged as it may impact performance.

Example usage:

Random Number Generation
~~~~~~~~~~~~~~~~~~~~~~~~

The Host API’s random interface is identical to that available from the
Device API. It is also seeded according to the random seed provided at
model execution, making it preferable to external random libraries.

Example usage:

.. code:: cpp

   FLAMEGPU_HOST_FUNCTION(my_host_function) {
       // uniformly distributed float in the range [0-1)
       float uniform_real = FLAMEGPU->random.uniform<float>();
       // uniformly distributed int in the range [1-10]
       int uniform_int = FLAMEGPU->random.uniform<int>(1, 10);
       // normally distributed float with mean==1, std_dev=1
       float normal = FLAMEGPU->random.normal<float>();
       // log normally distributed float with mean==1, std_dev=1
       float logNormal = FLAMEGPU->random.logNormal<float>(1, 1);
   }

``float`` may be replaced with ``double``, similarly ``int`` may be
replaced with any suitable integer type (e.g. signed/unsigned:
``int8_t``, ``int16_t``, ``int32_t``, ``int_64_t``).

Reduction
~~~~~~~~~

The Host API offers several types of reduction which can be performed
over agent variables.

-  **Min:** Find the minimum value.
-  **Max:** Find the maximum value.
-  **Sum:** Sum all of the values.
-  **Count:** Count occurences of a specific value.
-  **Reduce:** Perform a reduction with a custom binary operator.
-  **TransformReduce:** Perform a transformation + reduction with custom
   unary and binary operators.
-  **Histogram Even:** Generate a histogram of all values, with evenly
   spaced bin boundaries.
   
   Min/Max are performed by specifying the agent name, variable name and
variable’s type:

.. code:: cpp

   FLAMEGPU_HOST_FUNCTION(my_host_function) {
       auto myAgent = FLAMEGPU->agent("red");
       // min/max of agent 'red's float variable `x`
       float minResult = myAgent.min<float>("x");
       float maxResult = myAgent.max<float>("x");
   }

Sum is performed similarly, however a second template argument can be
used if the result is likely to require a greater type to avoid
overflow:

.. code:: cpp

   FLAMEGPU_HOST_FUNCTION(my_host_function) {
       auto myAgent = FLAMEGPU->agent("red");
       // sum of agent 'red's int16_t variable `y`
       int16_t int16_result = myAgent.sum<int16_t>("y");
       // sum int16 into int_64
       int64_t int64_result = myAgent.sum<int16_t, int64_t>("y");
   }

Count takes a second argument, this provides the value to be tested for
equality, it always returns an ``unsigned int``.

.. code:: cpp

   FLAMEGPU_HOST_FUNCTION(my_host_function) {
       auto myAgent = FLAMEGPU->agent("red");
       // count occurences of '0' within of agent 'red's int variable `z`
       unsigned int countResult = myAgent.count<int>("z", 0);
   }

Custom reduce’s are useful if you require a binary operation not
provided natively by FLAMEGPU, the final argument specifies the initial
value for the reduction:

.. code:: cpp

   FLAMEGPU_CUSTOM_REDUCTION(customMin, a, b) {
       // return minimum value above 0
       if (a <= 0) return b;
       if (b <= 0) return a;
       return a < b ? a : b;
   }
   FLAMEGPU_HOST_FUNCTION(my_host_function) {
       auto myAgent = FLAMEGPU->agent("red");
       // apply 'customMin' reduction to agent 'red's variable 'x'
       // INT_MAX is the initial value provided to the reduction
       int myMinResult = myAgent.reduce<int>("z", customMin, INT_MAX);
   }

Custom transform-reduce’s are useful if you require a binary operation,
preceded by a transformation. Like the custom reduce, the final argument
specifies the initial value for the reduction. It is also possible for
the transform operator to change the type of the variable:

.. code:: cpp

   FLAMEGPU_CUSTOM_TRANSFORMATION(customEqualsIf, a) {
       // return false if greater than 0
       return a <= 0;
   }
   FLAMEGPU_CUSTOM_REDUCTION(customSum, a, b) {
       // return sum of values
       return a + b;
   }
   FLAMEGPU_HOST_FUNCTION(my_host_function) {
       auto myAgent = FLAMEGPU->agent("red");
       // apply 'customEqualsIf' transformation to agent 'red's variable 'x'
       // following, apply `customSum` reduction
       // 0 is the initial value provided to the reduction
       uint16_t countIf_out = myAgent.transformReduce<float, uint16_t>("z", customEqualsIf, customSum, 0);
   }
   
A histogram of values held by an agent variable can also be produced,
this requires additional arguments to specify the number of bins and
bounds of the histogram:

.. code:: cpp

   FLAMEGPU_HOST_FUNCTION(my_host_function) {
       auto myAgent = FLAMEGPU->agent("red");
       // Create a histogram of agent 'red's variable 'z'
       // 10 bins, inclusive lower bound 0, exclusive upper bound 100
       std::vector<int> hist = myAgent.histogramEven<int, int>("z", 10, 0, 100);
   }