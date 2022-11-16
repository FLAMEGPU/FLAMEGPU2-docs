.. _Defining a Submodel:

Submodels
^^^^^^^^^
A submodel acts as a full model nested inside a parent model, the only requirement is that the submodel contains atleast one :ref:`exit condition<Defining Host Functions>`. Agent variables can be mapped between the two models, with each model also having private agent variables (or even private agents). The agent ID of bound agents will always be mapped. Unbound agents which are recreated in each time the submodel is executed are not guaranteed to have the same ID between runs. Environment properties can also be shared with submodels, with the ability to mark them as constant within the submodel.

Where an agent variable is mapped between model and submodel, the parent model's default value will always be used when creating new agents.

A submodel must exist independently within a layer of the parent model, it cannot execute simultaneously with other agent or host functions.

Models may contain multiple submodels, and submodels may contain sub-submodels. The only limitation to nested submodels is that circular dependencies are not permitted (e.g. a submodel adding it's parent model as a submodel), if one is detected an exception will be raised.

Defining a Submodel
-------------------
A submodel as defined the same as a regular model, via a :class:`ModelDescription<flamegpu::ModelDescription>`. It must then be added to the model which should host the submodel using :func:`newSubModel()<flamegpu::ModelDescription::newSubModel>` which returns a :class:`SubModelDescription<flamegpu::SubModelDescription>`.

Mappings between agent states, agent variables and environment properties can then be created using :func:`bindAgent()<flamegpu::SubModelDescription::bindAgent>` which returns a :class:`SubAgentDescription<flamegpu::SubAgentDescription>`. When mapping variables and properties, they must be of the same type and length.

When calling :func:`bindAgent()<flamegpu::SubModelDescription::bindAgent>`, it is also possible to automatically bind compatible variables and states with matching names by passing ``true`` to the second and third arguments respectively.

.. tabs::

  .. code-tab:: cpp C++
  
      // Define a submodel
      flamegpu::ModelDescription sub_m("submodel");
      {
          // Define a simple agent with variable 'x' and state 'foo'
          flamegpu::AgentDescription &a = sub_m.newAgent("subagent");
          a.newVariable<int>("x");
          a.newState("foo");
          // Add an agent function to the model
          flamegpu::AgentFunctionDescription &af1 = a.newFunction("example_function", ExampleFn);
          sub_m.newLayer().addFunction(af1);
          // Give the model an exit condition, this is required for all submodels
          sub_m.addExitCondition(ExitCdn);
      }
      // Define the parent model
      flamegpu::ModelDescription m("model");
      {
          // Define a simple agent with variable 'y' and state 'bar'
          flamegpu::AgentDescription &a = m.newAgent("agent");
          a.newVariable<int>("y");
          a.newState("bar");
          // Add the submodel
          flamegpu::SubModelDescription &smd = m.newSubModel("sub", sub_m);
          // Map agent's foo and bar
          // We pass false, as we don't wish for matching variables and states to be automatically mapped
          flamegpu::SubAgentDescription &agent_map = smd.bindAgent("subagent", "agent", false, false);
          // Map the agent variables and states
          agent_map.mapState("foo", "bar");
          agent_map.mapVariable("x", "y");
          // Add the submodel to a layer
          m.newLayer().addSubModel(smd);
      }
      
  .. code-tab:: py Python
  
      # Define a submodel
      sub_m = pyflamegpu.ModelDescription("submodel")
      # Define a simple agent with variable 'x' and state 'foo'
      s_a = sub_m.newAgent("subagent")
      s_a.newVariableInt("x")
      s_a.newState("foo")
      # Add an agent function to the model
      s_af1 = s_a.newRTCFunction("example_function", ExampleFn)
      sub_m.newLayer().addFunction(s_af1)
      # Give the model an exit condition, this is required for all submodels
      sub_m.addExitConditionCallback(ExitCdn());

      # Define the parent model
      m = pyflamegpu.ModelDescription("model")
      # Define a simple agent with variable 'y' and state 'bar'
      a = m.newAgent("agent")
      a.newVariableInt("y")
      a.newState("bar")
      # Add the submodel
      smd = m.newSubModel("sub", sub_m)
      # Map agent's foo and bar
      # We pass false, as we don't wish for matching variables and states to be automatically mapped
      agent_map = smd.bindAgent("subagent", "agent", False, False)
      # Map the agent variables and states
      agent_map.mapState("foo", "bar")
      agent_map.mapVariable("x", "y")
      # Add the submodel to a layer
      m.newLayer().addSubModel(smd)
    

Environment properties can also be mapped in a similar manner by calling :func:`mapProperty()<flamegpu::SubEnvironmentDescription::mapProperty>` on the :class:`SubEnvironmentDescription<flamegpu::SubEnvironmentDescription>`.

It is not possible to map a non-const environment property within a submodel, to a const property in the parent model.

.. tabs::

  .. code-tab:: cpp C++
  
      // Define a submodel
      flamegpu::ModelDescription sub_m("submodel");
      // As these properties will be mapped, their initial values are redundant as they will always be inherited
      sub_m.Environment().newProperty<float>("foo", 0);
      // This property is const in the sub model, so it can only be updated by the parent model
      sub_m.Environment().newProperty<float>("foo2", 0, true);
      
      // Define the parent model
      flamegpu::ModelDescription m("model");
      m.Environment().newProperty<float>("bar", 12.0f);
      m.Environment().newProperty<float>("bar2", 21.0f);
      
      // Setup the mapping
      flamegpu::SubModelDescription &smd = m.newSubModel("sub", sub_m);
      flamegpu::SubEnvironmentDescription &senv = smd.SubEnvironment();
      senv.mapProperty("foo", "bar");
      senv.mapProperty("foo2", "bar2");

  .. code-tab:: py Python
  
      # Define a submodel
      sub_m = pyflamegpu.ModelDescription("submodel")
      # As these properties will be mapped, their initial values are redundant as they will always be inherited
      sub_m.Environment().newPropertyFloat("foo", 0)
      # This property is const in the sub model, so it can only be updated by the parent model
      sub_m.Environment().newPropertyFloat("foo2", 0, True)
      
      # Define the parent model
      m = pyflamegpu.ModelDescription("model")
      m.Environment().newPropertyFloat("bar", 12.0)
      m.Environment().newPropertyFloat("bar2", 21.0)
      
      # Setup the mapping
      smd = m.newSubModel("sub", sub_m)
      senv = smd.SubEnvironment()
      senv.mapProperty("foo", "bar")
      senv.mapProperty("foo2", "bar2")

Related Links
-------------
* UserGuide Page: :ref:`Exit Conditions<Exit Conditions>`
* UserGuide Chapter: :ref:`Host Functions & Conditions<Host Functions and Conditions>`
* Full API documentation for :class:`SubModelDescription<flamegpu::SubModelDescription>`
* Full API documentation for :class:`SubAgentDescription<flamegpu::SubAgentDescription>`
* Full API documentation for :class:`SubEnvironmentDescription<flamegpu::SubEnvironmentDescription>`
* Full API documentation for :c:macro:`FLAMEGPU_HOST_CONDITION` (Python: :class:`HostFunctionConditionCallback<flamegpu::HostFunctionConditionCallback>`)
* Full API documentation for :class:`ModelDescription<flamegpu::ModelDescription>`