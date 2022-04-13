.. _defining a model:
Creating a Model
================

In order to create a FLAME GPU 2 simulation, you must first describe the model.


What is a Model?
^^^^^^^^^^^^^^^^

In FLAME GPU 2, a model is represented by a :class:`ModelDescription<flamegpu::ModelDescription>` object, this contains information specifying the agents, messages and environment properties within the model and how they interact.

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
     - :class:`EnvironmentDescription&<flamegpu::EnvironmentDescription>`
   * - :func:`newAgent()<flamegpu::ModelDescription::newAgent>`
     - :class:`AgentDescription&<flamegpu::AgentDescription>`
   * - :func:`newMessage()<flamegpu::ModelDescription::newMessage>`
     - Specialised message description type, e.g. :class:`MessageBruteForce::Description&<flamegpu::MessageBruteForce::Description>`, :class:`MessageSpatial2D::Description&<flamegpu::MessageSpatial2D::Description>`, etc
   * - :func:`newSubModel()<flamegpu::ModelDescription::newSubModel>`
     - :class:`SubModelDescription&<flamegpu::SubModelDescription>`
   * - :func:`addInitFunction()<flamegpu::ModelDescription::addInitFunction>`
     - n/a
   * - :func:`addStepFunction()<flamegpu::ModelDescription::addStepFunction>`
     - n/a
   * - :func:`addExitFunction()<flamegpu::ModelDescription::addExitFunction>`
     - n/a
   * - :func:`addExitCondition()<flamegpu::ModelDescription::addExitCondition>`
     - n/a
   * - :func:`newLayer()<flamegpu::ModelDescription::newLayer>`
     - :class:`LayerDescription&<flamegpu::LayerDescription>`
     
.. note::
  
    :func:`newMessage()<flamegpu::ModelDescription::newMessage>` take a template argument, so it is called in the format ``newMessage<flamegpu::MessageBruteForce>()``. As the Python API lacks templates, they are instead called in the format ``newMessageBruteForce()``.

.. note::
  
    The host function methods e.g. :func:`addInitFunction()<flamegpu::ModelDescription::addInitFunction>`, :func:`addExitCondition()<flamegpu::ModelDescription::addExitCondition>` etc are named slightly different in the Python API. Instead they are called ``addInitFunctionCallback()``, ``addExitConditionCallback()`` etc.

The subsequent chapters of this guide explore their usage in greater detail.