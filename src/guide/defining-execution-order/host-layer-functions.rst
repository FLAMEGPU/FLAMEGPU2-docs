.. _Host Layer Functions:

Host Layer Functions
^^^^^^^^^^^^^^^^^^^^

In order to add a host layer function to the dependency graph, a :class:`HostFunctionDescription<flamegpu::HostFunctionDescription>` object must be created to wrap it:

.. tabs::

  .. code-tab:: cpp C++
     
    // Define a host function called host_fn1
    FLAMEGPU_HOST_FUNCTION(host_fn1) {
        // Behaviour goes here
    }
    
    // ... other code ...

    // Wrap it in a HostFunctionDescription, giving it the name "HostFunction1"
    HostFunctionDescription hf("HostFunction1", host_fn1);

    // Specify that it depends on an agent function "f" 
    hf.dependsOn(f);
    

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
        
    # ... other code ...

    # Wrap it in a HostFunctionDescription, giving it the name "HostFunction1"
    hf = pyflamegpu.HostFunctionDescription("HostFunction1", host_fn1)

    # Specify that it depends on an agent function "f" 
    hf.dependsOn(f)
    
If you are using the layers API directly, you do not need to wrap your host layer functions in :class:`HostFunctionDescription` objects.

Related Links
-------------
* Full API documentation for :c:macro:`FLAMEGPU_HOST_FUNCTION` (Python: :class:`HostFunctionCallback<flamegpu::HostFunctionCallback>`)
* Full API documentation for :c:macro:`FLAMEGPU_HOST_CONDITION` (Python: :class:`HostFunctionConditionCallback<flamegpu::HostFunctionConditionCallback>`)
* Full API documentation for :class:`DependencyGraph<flamegpu::DependencyGraph>`
        
        
