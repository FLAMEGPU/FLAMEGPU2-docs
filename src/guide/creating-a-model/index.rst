.. _defining a model:

Creating a Model
================

In order to create a FLAME GPU 2 simulation, you must first describe the model.


What is a Model?
^^^^^^^^^^^^^^^^

In FLAME GPU 2, a model is represented by a :class:`ModelDescription<flamegpu::ModelDescription>` object, this contains information specifying the agents, messages and environment properties within the model and how they interact.

The hierarchy of a :class:`ModelDescription<flamegpu::ModelDescription>` is shown below.

.. mermaid::

    graph TD;
        %%Simulation-->Population;
        %%Simulation-->Model;
        Model-->Agent;
        Model-->Message;
        Model-->Environment;
        Model-->Layer;
        Model-->e["Init/Step/Exit Function"];
        Message-->Variable;
        Agent-->a["Variable"];
        Agent-->b["Agent Function"];
        Agent-->State;
        Environment-->Property;
        Environment-->MacroProperty;
        %%Environment-->StaticGraph;
        Layer-->c[Agent Function];
        Layer-->d[Host Function];
        Layer-->SubModel;

:ref:`Agents<Defining Agents>` are the executors of primary model behaviour. All agents of the same type and state execute in parallel, where they can update their internal variables based on messages from other agents and the environment's properties. 

:ref:`Messages<Defining Messages>` are what agents share to communicate with one another. Due to the parallel nature of a FLAME GPU model, they must be input in a separate agent function to the one they are output from. There are a wide range of message types supported, to enable the most efficient communication strategy for any purpose.

:ref:`The Environment<defining environmental properties>` holds global state information in the form of properties and macro properties. The environment is primarily mutated via :ref:`host functions<Defining Host Functions>`, which execute serially at the global level. New to FLAME GPU 2, :ref:`macro properties<Define Macro Environmental Properties>` support upto 4-dimensional arrays and provide a limited set of mutators so that they can be updated during agent functions.

:ref:`Layers<Layers>` are FLAME GPUs original method of defining the control flow of a model, layers are each executed in sequence and all functions within a layer may execute in parallel. FLAME GPU 2 alternatively provides a new intuitive :ref:`dependency graph API<Dependency Graph>`, where instead dependencies between functions are defined, the layers are then automatically generated based on the dependencies. Additionally, FLAME GPU 2 introduces the concept of :ref:`submodels<Defining a Submodel>` which allow iterative algorithms (typically parallel conflict resolution) to be modelled within a single model step by nesting a model with shared agents.

:ref:`Init, Step and Exit functions<Types of Host Function>` are host functions which execute either at the start of the simulation, end of each step or after the simulation has finished. Otherwise, they are exactly the same as host functions attached to layers or the dependency graph. Additionally, FLAME GPU 2 provides a specialised :ref:`Exit Condition<Exit Conditions>` host function, which can end a simulation early if a user-defined condition is met.

Once the :class:`ModelDescription<flamegpu::ModelDescription>` has been completely described, it is used to construct either a :class:`CUDASimulation<flamegpu::CUDASimulation>` or :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>` to execute simulations of the model.


Creating a ModelDescription Object
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:class:`ModelDescription<flamegpu::ModelDescription>` objects can be initialised directly, requiring only a single argument specifying the model's name. Currently this name is only used to generate the default window title within the visualiser.

.. tabs::

  .. code-tab:: cpp C++

    #include "flamegpu/flamegpu.h"
    
    int main(int argc, const char **argv) {
        // Define a new FLAME GPU model
        flamegpu::ModelDescription model("My Model");
    }

  .. code-tab:: py Python

    import pyflamegpu
    
    # Define a new FLAME GPU model
    model = pyflamegpu.ModelDescription("My Model")

The :class:`ModelDescription<flamegpu::ModelDescription>` class has various methods for specifying components of the model, these are used to fully describe a model to be simulated.

.. list-table::
   :widths: 25 75
   :header-rows: 1
   
   * - Method
     - Returns
   * - :func:`Environment()<flamegpu::ModelDescription::Environment>`
     - :class:`EnvironmentDescription<flamegpu::EnvironmentDescription>`
   * - :func:`newAgent()<flamegpu::ModelDescription::newAgent>`
     - :class:`AgentDescription<flamegpu::AgentDescription>`
   * - :func:`newMessage()<flamegpu::ModelDescription::newMessage>`
     - Specialised message description type, e.g. :class:`MessageBruteForce::Description<flamegpu::MessageBruteForce::Description>`, :class:`MessageSpatial2D::Description<flamegpu::MessageSpatial2D::Description>`, etc
   * - :func:`newSubModel()<flamegpu::ModelDescription::newSubModel>`
     - :class:`SubModelDescription<flamegpu::SubModelDescription>`
   * - :func:`addInitFunction()<flamegpu::ModelDescription::addInitFunction>`
     - n/a
   * - :func:`addStepFunction()<flamegpu::ModelDescription::addStepFunction>`
     - n/a
   * - :func:`addExitFunction()<flamegpu::ModelDescription::addExitFunction>`
     - n/a
   * - :func:`addExitCondition()<flamegpu::ModelDescription::addExitCondition>`
     - n/a
   * - :func:`newLayer()<flamegpu::ModelDescription::newLayer>`
     - :class:`LayerDescription<flamegpu::LayerDescription>`
     
.. note::
  
    :func:`newMessage()<flamegpu::ModelDescription::newMessage>` take a template argument, so it is called in the format ``newMessage<flamegpu::MessageBruteForce>()``. As the Python API lacks templates, they are instead called in the format ``newMessageBruteForce()``.

The subsequent chapters of this guide explore their usage in greater detail.

.. _Supported Types:

Supported Types
^^^^^^^^^^^^^^^

As FLAME GPU 2 is a C++ library, variable/property types within models must be specified. Throughout the API many methods rely on C++ templates where the type of a variable or property must be provided. If using the Python API the type is instead appended as a suffix to the method's identifier.

Only primitive numeric types are currently supported, the full list of supported types is provided below.

====================================== ===============================================
C++ Template type                      Python Type Suffix
====================================== ===============================================
``char`` [1]_                          ``Char`` [1]_
``signed char`` ``int8_t``             ``Int8``
``unsigned char`` ``uint8_t``          ``UChar`` ``UInt8``
``signed short`` ``int16_t`` ``short`` ``Int16``
``unsigned short`` ``uint16_t``        ``UInt16``
``signed int`` ``int32_t`` ``int``     ``Int32`` ``Int``
``unsigned int`` ``uint32_t``          ``UInt32`` ``UInt``
``int64_t`` [2]_                       ``Int64``
``uint64_t`` [2]_                      ``UInt64``
``float``                              ``Float``
``double``                             ``Double``
:type:`flamegpu::id_t` [3]_            ``ID`` [3]_
====================================== ===============================================

The subsequent chapters introduce all the relevant methods.

.. note::
  
    If a boolean variable is required, a character type should be used.
    
.. [1] Within C++ ``char`` is is distinct from both ``signed char`` and ``unsigned char``.
.. [2] ``long`` / ``long long`` type names are supported, however the corresponding integer length differs between compilers.
.. [3] FLAME GPUs ID type is currently a 32 bit unsigned integer (``uint32_t`` / ``UInt32``).