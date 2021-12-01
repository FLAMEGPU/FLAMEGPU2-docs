Defining a Submodel
===================
A submodel acts as a full model nested inside a parent model, the only requirement is that the model contains atleast one exit condition. Agent variables can be mapped between the two models, with each model also having private agent variables (or even private agents). The agent ID of bound agents will always be mapped. Unbound agents which are recreated in each submodel run are not guaranteed to have the same ID between runs. Environment properties can also be shared with submodels, with the ability to mark them as constant within the submodel.

Where an agent variable is mapped between model and submodel, the parent model's default value will always be used when creating new agents.

A submodel must exist independently within a layer of the parent model, it cannot execute simultaneously with other agent or host functions.

Models may contain multiple submodels, and submodels may contain sub-submodels. The only limitation to submodel nested, is that circular dependencies are not permitted (e.g. a submodel adding it's parent model as a submodel).

Submodel Definition
--------------------
A submodel as defined the same as a regular model, via a `ModelDescription`. It must then be added to the model which should host the submodel. Mappings between agent states, agent variables and environment properties can then be created. When mapping variables and properties, they must be of the same type and length.

When calling `SubAgentDescription::bindAgent()`, it is also possible to automatically bind compatible states and variables.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
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
          agent_map.mapState("foo", "bar")
          agent_map.mapVariable("x", "y")
          // Add the submodel to a layer
          m.newLayer().addSubModel(smd);
      }
    
    
Environment properties are also mapped similarly. It is not possible to map a non-const environment property within a submodel, to a const property in the parent model.

.. tabs::

  .. code-tab:: cuda CUDA C++
  
      // Define a submodel
      flamegpu::ModelDescription sub_m("submodel");
      // As this property will be mapped, it's value is redundant as it will always be inherited
      sub_m.Environment().add<float>("foo", 0);
      sub_m.Environment().add<float>("foo2", 0, true);
      
      // Define the parent model
      flamegpu::ModelDescription m("model");
      m.Environment().add<float>("bar", 12.0f);
      m.Environment().add<float>("bar2", 21.0f);
      
      // Setup the mapping
      flamegpu::SubModelDescription &smd = m.newSubModel("sub", sub_m);
      flamegpu::SubEnvironmentDescription &senv = smd.SubEnvironment();
      senv.mapProperty("foo", "bar");
      senv.mapProperty("foo2", "bar2");