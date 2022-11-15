.. _Defining Host Functions:

Defining Host Functions
^^^^^^^^^^^^^^^^^^^^^^^

Unlike agent functions, host Functions are implemented natively, in C++ if using the C++ API, or in Python if using the Python API.

In the C++ API a host function is defined using the :c:macro:`FLAMEGPU_HOST_FUNCTION` macro, similarly a host condition is defined using the :c:macro:`FLAMEGPU_HOST_CONDITION`. This takes a single argument, a unique name identifying the function.

In the Python API a host function is defined as a subclass of :class:`HostFunctionCallback<flamegpu::HostFunctionCallback>`, similarly a host condition is defined as a subclass of :class:`HostFunctionConditionCallback<flamegpu::HostFunctionConditionCallback>`.


.. tabs::

  .. code-tab:: cpp C++
     
    // Define a host function called host_fn1
    FLAMEGPU_HOST_FUNCTION(host_fn1) {
        // Behaviour goes here
    }
    
    // Define a host condition called host_cdn1
    FLAMEGPU_HOST_CONDITION(host_cdn1) {
        // Behaviour goes here
        return flamegpu::CONTINUE;
    }

  .. code-tab:: py Python

    # Define a host function called host_fn1
    class host_fn1(pyflamegpu.HostFunctionCallback):
      '''
         The explicit __init__() is optional, however if used the superclass __init__() must be called
      '''
      def __init__(self):
        super().__init__()

      def run(self,FLAMEGPU):
        # Behaviour goes here
        
        
    # Define a host condition called host_cdn1
    class host_cdn1(pyflamegpu.HostFunctionConditionCallback):
      '''
         The explicit __init__() is optional, however if used the superclass __init__() must be called
      '''
      def __init__(self):
        super().__init__()

      def run(self, FLAMEGPU):
        # Behaviour goes here
        return pyflamegpu.CONTINUE
        
        
.. warning::

    Although python Host functions and conditions are classes, the class should not utilise any additional stateful information (e.g. `self`). When executed via ensembles, Python host function instances are shared between concurrent simulation runs, which may lead to race conditions where stateful information is present.
    

Types of Host Function
----------------------

FLAME GPU currently has 4 types of host function, they are all fundamentally the same besides at which point during a simulation they are executed.

Within the C++ API they have optional macro synonyms which can be used to improve the clarity of code.

================ ================================== ====================================================================================================================
Type             C++ Macro                          Description
================ ================================== ====================================================================================================================
Initialisation   :c:macro:`FLAMEGPU_INIT_FUNCTION`  Execute once before the main simulation, useful for creating agents and initialising dynamic/derived agent variables.
Exit             :c:macro:`FLAMEGPU_EXIT_FUNCTION`  Execute once after the main simulation, useful for reducing the full simulation state to important data to be logged.
Step             :c:macro:`FLAMEGPU_STEP_FUNCTION`  Execute after each step of the main simulation, useful for updating the environment based on agent reductions.
Host-Layer       :c:macro:`FLAMEGPU_HOST_FUNCTION`  Execute anywhere specified during the main simulation, useful for updating the environment based on agent reductions.
================ ================================== ====================================================================================================================

FLAME GPU currently has 1 type of host condition, within the C++ API it's macro synonym can optionally be used.

================ =================================== ===================================================================================================================
Type             C++ Macro                           Description
================ =================================== ===================================================================================================================
Exit             :c:macro:`FLAMEGPU_EXIT_CONDITION`  Execute once each step of the main simulation, useful for controlling when a model or submodel should exit early. Must return either :enumerator:`CONTINUE<flamegpu::CONDITION_RESULT::CONTINUE>` or :enumerator:`EXIT<flamegpu::CONDITION_RESULT::EXIT>`.
================ =================================== ===================================================================================================================

Adding Host Functions to a Model
--------------------------------

Host functions and conditions are predominantly added to a model via their respective methods on :class:`ModelDescription<flamegpu::ModelDescription>`. They will execute in the order in which they are added.
The exception to this rule are host-layer functions, details on how to specify their position in the execution order can be found :ref:`here<Execution Order>`.

======================== ========================================================================= =======================================================================
Type                     C++ Method                                                                Python Method
======================== ========================================================================= =======================================================================
Initialisation Function  :func:`addInitFunction()<flamegpu::ModelDescription::addInitFunction>`    :func:`addInitFunctionCallback()<flamegpu::ModelDescription::addInitFunctionCallback>`
Exit Function            :func:`addStepFunction()<flamegpu::ModelDescription::addStepFunction>`    :func:`addStepFunctionCallback()<flamegpu::ModelDescription::addStepFunctionCallback>`
Step Function            :func:`addExitFunction()<flamegpu::ModelDescription::addExitFunction>`    :func:`addExitFunctionCallback()<flamegpu::ModelDescription::addExitFunctionCallback>`
Host-Layer Function      :ref:`n/a<Execution Order>`                                               :ref:`n/a<Execution Order>`
Exit Condition           :func:`addExitCondition()<flamegpu::ModelDescription::addExitCondition>`  :func:`addExitConditionCallback()<flamegpu::ModelDescription::addExitConditionCallback>`
======================== ========================================================================= =======================================================================

The below example shows how an init function would be added to a model:

.. tabs::

  .. code-tab:: cpp C++
     
    // Define an init function called init_fn
    FLAMEGPU_INIT_FUNCTION(init_fn) {
        ... // Behaviour goes here
    }
    
    int main() {    
        // Define a new model
        flamegpu::ModelDescription model("Test Model");
        ... // Rest of model definition
        // Add the init function init_fn to Test Model
        model.addInitFunction(init_fn);
        ...    
    }

  .. code-tab:: py Python

    # Define a host function called init_fn
    class init_fn(pyflamegpu.HostFunctionCallback):
      '''
         The explicit __init__() is optional, however if used the superclass __init__() must be called
      '''
      def __init__(self):
        super().__init__()

      def run(self, FLAMEGPU):
        # Behaviour goes here
        
        

    # Define a new model
    model = pyflamegpu.ModelDescription("Test Model")
    ... # Rest of model definition
    # Add the exit function init_fn to Test Model
    model.addInitFunctionCallback(init_fn())
    ...


Related Links
-------------
* Full API documentation for :c:macro:`FLAMEGPU_INIT_FUNCTION`
* Full API documentation for :c:macro:`FLAMEGPU_EXIT_FUNCTION`
* Full API documentation for :c:macro:`FLAMEGPU_STEP_FUNCTION`
* Full API documentation for :c:macro:`FLAMEGPU_HOST_FUNCTION` (Python: :class:`HostFunctionCallback<flamegpu::HostFunctionCallback>`)
* Full API documentation for :c:macro:`FLAMEGPU_EXIT_CONDITION`
* Full API documentation for :c:macro:`FLAMEGPU_HOST_CONDITION` (Python: :class:`HostFunctionConditionCallback<flamegpu::HostFunctionConditionCallback>`)
* Full API documentation for :class:`ModelDescription<flamegpu::ModelDescription>`
* Full API documentation for :class:`LayerDescription<flamegpu::LayerDescription>`