The Model Environment
=====================

The model environment is represented as properties. Agent's have read-only access to these property during the simulation, however they can be updated during the simulation via host functions.

Properties
----------

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

.. code:: cpp

   ModelDescription model("some_model");
   EnvironmentDescription env;
   env.add<float>("f_prop", 12.0f);        // Create float property 'f_prop', with value of 12
   env.add<int, 3>("ia_prop", {1, 2, 3});  // Create int array property 'ia_prop', with value of [1, 2, 3]
   env.add<char>("c_prop", 'g', true);     // Create constant char property 'c_prop', with value 'g'
   model.setEnvironment(env);