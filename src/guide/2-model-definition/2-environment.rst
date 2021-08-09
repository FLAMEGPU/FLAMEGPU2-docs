Adding Environmental Properties
===============================

What is an Environment?
-----------------------

In FLAMEGPU2, an environment represents simulation parameters which are not tied to any particular instance of an agent. 
The model environment is represented as a set of properties. FLAMEGPU2 environments are represented by
an ``EnvironmentDescription`` object.

Creating an EnvironmentDescription Object
-----------------------------------------

An ``EnvironmentDescription`` is initialised as shown below:

.. tabs::

  .. code-tab:: cpp

    // Create an EnvironmentDescription object called env
    flamegpu::EnvironmentDescription env;

  .. code-tab:: python
    
    # Create an EnvironmentDescription object called env
    env = pyflamegpu.EnvironmentDescription()



Defining Environmental Properties
---------------------------------

Environment properties are values which are the same across the whole
simulation, these can be useful for storing mathematical constants and
system state information. Enviornment properties can only be updated
during host functions, however they can be read during agent functions.

To define Environment properties, they must be added to an
``EnvironmentDescription``, this must subsequently be added to the
``ModelDescription``. Environment properties can optionally be marked as
‘const’, this prevents them being changed after the simulation has been
initialised.

Any arithmetic or enum type can be used as an environment property
(e.g. ``bool``, ``int8_t``, ``uint8_t``, ``int16_t``, ``uint16_t``,
``int32_t``, ``uint32_t``, ``int64_t``, ``uint64_t``, ``float``,
``double``).

.. tabs::

  .. code-tab:: cpp

    // Define environmental properties and their initial values
    env.add<float>("f_prop", 12.0f);        // Create float property 'f_prop', with value of 12
    env.add<int, 3>("ia_prop", {1, 2, 3});  // Create int array property 'ia_prop', with value of [1, 2, 3]
    env.add<char>("c_prop", 'g', true);     // Create constant char property 'c_prop', with value 'g'

  .. code-tab:: python

    # Define environmental properties and their initial values
    env.newPropertyFloat("f_prop", 12.0)     # Create float property 'f_prop', with value of 12
    env.newPropertyArrayInt("ia_prop", 3, [1, 2, 3])  # Create int array property 'ia_prop', with value of [1, 2, 3]
    env.newPropertyChar("c_prop", 'g', True)  # Create constant char property 'c_prop', with value 'g'


Attaching the Environment to a Model
------------------------------------

An environment can be associated with a particular model using the ``setEnvironment`` method of a ``ModelDescription`` object:

.. tabs::

  .. code-tab:: cpp

    // Attach the EnvironmentDescription to a ModelDescription
    model.setEnvironment(env);

  .. code-tab:: python

    # Attach the EnvironmentDescription to a ModelDescription
    model.setEnvironment(env)

Full Example Code From This Page
--------------------------------

.. tabs::

  .. code-tab:: cpp

    // Create an EnvironmentDescription object called env
    flamegpu::EnvironmentDescription env;

    // Define environmental properties and their initial values
    env.add<float>("f_prop", 12.0f);        // Create float property 'f_prop', with value of 12
    env.add<int, 3>("ia_prop", {1, 2, 3});  // Create int array property 'ia_prop', with value of [1, 2, 3]
    env.add<char>("c_prop", 'g', true);     // Create constant char property 'c_prop', with value 'g'

    // Attach the EnvironmentDescription to a ModelDescription
    model.setEnvironment(env);

  .. code-tab:: python
    
    # Create an EnvironmentDescription object called env
    env = pyflamegpu.EnvironmentDescription()

    # Define environmental properties and their initial values
    env.newPropertyFloat("f_prop", 12.0)     # Create float property 'f_prop', with value of 12
    env.newPropertyArrayInt("ia_prop", 3, [1, 2, 3])  # Create int array property 'ia_prop', with value of [1, 2, 3]
    env.newPropertyChar("c_prop", 'g', True)  # Create constant char property 'c_prop', with value 'g'

    # Attach the EnvironmentDescription to a ModelDescription
    model.setEnvironment(env)

More Info 
---------
* Related User Guide Pages

  * `Interacting with the Environment <../3-behaviour-definition/3-interacting-with-environment.html>`_
  * `Random Number Generation <../8-advanced-sim-management/2-rng-seeds.html>`_

* Full API documentation for the ``EnvironmentDescription``: link
* Examples which demonstrate creating an environment

  * Boids Brute Force (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/boids_bruteforce/src/main.cu>`_)
  * Ensemble (`View on github <https://github.com/FLAMEGPU/FLAMEGPU2/blob/master/examples/ensemble/src/main.cu>`_)