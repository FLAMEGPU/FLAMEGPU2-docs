Tutorial
========

This tutorial presents a brief overview of FLAME GPU 2 and a worked example demonstrating how to implement the `Circles example <https://github.com/FLAMEGPU/FLAMEGPU2/tree/master/examples/circles_spatial3D>`_, a simple model provided with FLAME GPU 2.

In order to follow the tutorial, you will need to be using a machine with a CUDA capable GPU which meets the :ref:`prerequisites<quickstart-prerequisites>` for (compiling and) running either C++ or Python FLAME GPU projects.

An alternate, in-browser, tutorial using Google Collab is available `here <https://colab.research.google.com/github/FLAMEGPU/FLAMEGPU2-tutorial-python/blob/google-colab/FLAME_GPU_2_python_tutorial.ipynb>`_, this should work on any machine with a modern web browser and an internet connection. However, limitations of iPython notebooks prevent demonstration of all features (e.g. Visualisations).



FLAME GPU Design Philosophy
---------------------------

FLAME GPU has the aim of accelerating the performance and scale of agent-based simulation by targeting readily available parallelism in the form of Graphics Processing Units (GPUs). A central idea behind FLAME GPU is to abstract the GPU away from modellers so that modellers can build models without having to worry about writing parallel code. FLAME GPU also separates a model description from the model implementation. This simplifies the processes of validating and verifying models as the simulator code is tested in isolation from the model itself.

FLAME GPU started in the early days of general purpose computing on GPUs. GPU hardware and software development approaches have changed significantly since the inception of FLAME GPU, as such version 2.0 is a complete re-write of the library. It shifts from the FLAME GPU 1 architecture of template driven agent based modelling towards a modern C++ API with a cleaner interface for the specification of agent behaviour. It also adds a range of new features which ensure performant model simulation. E.g.

* Support for Big GPUs - Support for concurrent execution of agents functions which ensures that heterogeneous models do not necessarily result in poor device utilisation.
* Model Ensembles - The ability to run ensembles of models. I.e. the same model with different parameters or random seeds. This is necessary within stochastic simulation and FLAME GPU allows the specification of ensembles to occupy multiple devices on a single computing node.
* Sub models - Certain behaviours in FLAME GPU require iterative processes to ensure reproducibility with serial counterparts (e.g. conflict resolution for resources). FLAME GPU 2 allows re-usable sub models to be described for such behaviours so that it can be abstracted from the rest of the model function.

Creating a Project
------------------

To create your own FLAME GPU 2 model, we recommend that you use one of the provided FLAME GPU 2 example template repositories. These provide you with all the build scripts to build a standalone FLAME GPU 2 model. They begin with an implementation of the Circles example, however in the tutorial below we will clear that file and start with it empty.

* If you wish to use the CUDA/C++ interface, use `FLAME GPU 2 example template <https://github.com/FLAMEGPU/FLAMEGPU2-example-template>`_
* If you wish to use the Python 3 interface, use `FLAME GPU 2 python example template <https://github.com/FLAMEGPU/FLAMEGPU2-python-example-template>`_


Structure of a FLAME GPU 2 Program
----------------------------------

FLAME GPU 2 programs are composed of 4 sections:

* Agent/Host function definitions
* Model Declaration
* Initialisation
* Execution

Agent/Host Function Definitions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These functions define the actual behaviours of your model and are normally defined before the ``main`` function, however larger models can use more advanced techniques to split the model definition across multiple files. Refer to the respective full guides, for more information regarding :ref:`agent functions<Defining Agent Functions>` and :ref:`host functions<Defining Host Functions>`.

Model Declaration
^^^^^^^^^^^^^^^^^

Normally inside the ``main`` function or simply the main file if using Python, your model structure is declared. This includes declaration of the required agent and message types for your model. We recommend the following structure for model declaration:

* :ref:`ModelDescription<defining a model>`
* :ref:`MessageDescriptions<Defining Messages>`
* :ref:`AgentDescriptions<Defining Agents>`
* :ref:`EnvironmentDescription<defining environmental properties>`
* :ref:`Function execution order<Execution Order>`

Initialisation
^^^^^^^^^^^^^^

In order to execute your model it requires an initial state, this normally means some initial agents and environment properties may need to be setup. There are several ways this can be achieved:

* Init Function(s), host functions which run once when the simulation begins.
* Input files, a simulation can load agent populations, and environment properties from an input file when it begins.
* :class:`AgentVector<flamegpu::AgentVector>`, Agent populations and environment properties can be defined externally and set within the :class:`CUDASimulation<flamegpu::CUDASimulation>` prior to execution, however this technique is not recommend.

Execution
^^^^^^^^^

Finally, to run your simulation you must create a :class:`CUDASimulation<flamegpu::CUDASimulation>` by providing it your :class:`ModelDescription<flamegpu::ModelDescription>`. At this stage you can configure the :func:`simulation<flamegpu::Simulation::SimulationConfig>` and :func:`CUDA<flamegpu::CUDASimulation::CUDAConfig>` settings, alternatively you can provide the :ref:`command line arguments<Configuring Execution>`. If required, you can also :ref:`setup the visualisation<Configuring Visualisation>` for the model.

When ready, you then call :func:`simulate()<flamegpu::CUDASimulation::simulate>`, to execute your model!


.. _Circles Model:

Tutorial: Creating the Circles Model
------------------------------------
Hopefully at this point you have downloaded and set up one of the example templates.

Introducing The Circles Model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Circles model is a simple agent model, where a single type of point agent exists in a 2D or 3D continuous space environment.

The agents observe their neighbours locations, to decide how to move.

The model resolves towards a steady state where agents have formed circular or spherical clusters.

The video below provides a demonstration of the Circles model.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/ZedroqmOaHU" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Configuring CMake
^^^^^^^^^^^^^^^^^

*This stage is only required if you are using C++, or are building pyflamegpu from source.*

FLAME GPU 2 uses CMake to manage the build process, so we use CMake to generate a build directory which it will fill with build scripts. It can also assist by downloading certain missing dependencies.

The basic commands differ slightly between Linux and Windows, however in both cases they should be executed in the directory which the template was cloned into.

Visualisation support is disabled by default, and must be enabled at CMake configure time if required.

A more detailed guide, regarding building FLAME GPU 2 from source can be found :ref:`here<q-compiling flamegpu>`.

.. tabs::

  .. code-tab:: sh Linux (.sh)
  
    # Create the build directory and change into it
    mkdir -p build && cd build

    # Configure CMake from the command line passing configure-time options. 
    # Optionally include -DFLAMEGPU_VISUALISATION=ON below if you want to use visualisations
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_ARCHITECTURES=75

  .. code-tab:: bat Windows (.bat)
  
    :: Create the build directory 
    mkdir build
    cd build

    :: Configure CMake from the command line, specifying the -A and -G options. Alternatively use the GUI (see Quickstart guide)
    :: Optionally include -DFLAMEGPU_VISUALISATION=ON below if you want to use visualisations
    cmake .. -G "Visual Studio 17 2022" -DCMAKE_CUDA_ARCHITECTURES=75

    :: You can then open Visual Studio manually from the .sln file, or via:
    cmake --open . 


.. note::
  
  ``-DCMAKE_CUDA_ARCHITECTURES=75``, configures the build for Turing GPUs of ``SM_75``, you may wish to change this to match your available GPU. Omitting it entirely will produce a larger binary suitable for all current architectures, which essentially multiplies the compile time by the number of architectures. In general, GPUs of newer architecture than specified will run but be limited to the features of the earlier architecture that the program was compiled for.


The build files for the project should now be created inside the directory ``build``.

Opening the Project
^^^^^^^^^^^^^^^^^^^ 

Linux C++ users should now open ``src/main.cu`` in their preferred  text editor or IDE.

Windows C++ users should now open ``build/example.vcxproj`` with Visual Studio, and subsequently open ``main.cu`` via the solution explorer panel.

Python users should now open ``model.py`` in their preferred text editor or IDE.

In every case, we will clear the file only keeping the FLAME GPU include/import statement. This statement allows the file access to the full FLAME GPU 2 library.


.. tabs::

  .. code-tab:: cpp C++

    #include "flamegpu/flamegpu.h"

  .. code-tab:: py Python

    import pyflamegpu
    
Model Description
^^^^^^^^^^^^^^^^^

The first step to creating a FLAME GPU model is to define the model, this begins by creating a :class:`ModelDescription<flamegpu::ModelDescription>`. This will be used to describe the entire model, by adding descriptions of messages, agents and the environment.

The only argument which the constructor :func:`ModelDescription()<flamegpu::ModelDescription::ModelDescription>` takes is a string representing the name of the model. *Currently the name is only used as the default title of the window if a visualisation is created.*

Normally the :class:`ModelDescription<flamegpu::ModelDescription>` is defined at the start of program flow. In C++ this means within the ``main()`` method, whereas in Python this can simply be within the main file (Python does allow an entry function to be specified).

Before the model description, we will also define two (constant) variables, to define the environment dimensions and the number of agents. These values will be used in a few places, so it is useful name them.

.. tabs::

  .. code-tab:: cpp C++

    ...
    // All code examples are assumed to be implemented within a main function.
    // E.g. int main(int argc, const char *argv[])

    // Define some useful constants
    const unsigned int AGENT_COUNT = 16384;
    const float ENV_WIDTH = static_cast<float>(floor(cbrt(AGENT_COUNT)));
    
    // Define the FLAME GPU model
    flamegpu::ModelDescription model("Circles Tutorial");
    ...

  .. code-tab:: py Python

    ...
    # Define some useful constants
    AGENT_COUNT = 16384
    ENV_WIDTH = int(AGENT_COUNT**(1/3))

    # Define the FLAME GPU model
    model = pyflamegpu.ModelDescription("Circles Tutorial")
    ...


Message Description
^^^^^^^^^^^^^^^^^^^

Next we must decide how the agents will communicate. This is normally completed before agents, as agent functions refer back to messages, so they must be described first.

As the agents within the Circles model exist in a continuous space and want to find their local neighbours, there are three potential message types suited to the model:

* :class:`MessageBruteForce<flamegpu::MessageBruteForce>`: Every agent reads every message, this is very expensive with a large number of messages/agents.
* :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>`: Each agent outputs a message at a specific location in 2D space, agents only read messages located close to a particular search origin.
* :class:`MessageSpatial3D<flamegpu::MessageSpatial3D>`: Each agent outputs a message at a specific location in 3D space, agents only read messages located close to a particular search origin.

We will implement the Circles model in 2D during this tutorial, therefore :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>` will be the most appropriate message type. Although, later extending the model to 3D should require minimal changes.

In order to create a :class:`MessageSpatial2D::Description<flamegpu::MessageSpatial2D::Description>`, :func:`newMessage()<flamegpu::ModelDescription::newMessage>` must be called on the previously created :class:`ModelDescription<flamegpu::ModelDescription>`. This is a templated function, so it must be called with the template argument of the name of the desired message type, in our case :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>`. Additionally, the sole argument is a string representing the name of the message, this can be used later on when attaching the message as an input or output to an :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`.

.. note::
  
    The Python interface does not support C++'s templates and nested classes so there are differences in naming style. :ref:`In almost all cases the template argument is simply appended to the name.<Python Types>`.
      
      
    .. list-table::
       :widths: 50 50
       :header-rows: 1
       
       * - C++
         - Python
       * - :func:`newMessage\<flamegpu::MessageSpatial2D\>()<flamegpu::ModelDescription::newMessage>`
         - ``newMessageSpatial2D()``
       * - :class:`MessageSpatial2D::Description<flamegpu::MessageSpatial2D::Description>`
         - ``MessageSpatial2DDescription``
       * - :func:`newVariable\<flamegpu::id_t\>()<template<typename T> void flamegpu::MessageBruteForce::Description::newVariable(const std::string &)>`
         - ``newVariableID()``
       * - :func:`message.newVariable\<int, 3\>("vector3");<template<typename T, MessageNone::size_type N> void flamegpu::MessageBruteForce::Description::newVariable(const std::string &)>`
         - ``message.newVariableArrayInt("vector3", 3)``

Spatial messages have some settings which must be specified prior to use.

The environment bounds must be specified using :func:`setMin()<flamegpu::MessageSpatial2D::Description::setMin>` and :func:`setMax()<flamegpu::MessageSpatial2D::Description::setMax>`. Spatial messages can be emit at any location, however for best performance the specified bounds should encapsulate all messages. For this reason, we will make the bounds of the environment run from ``0`` to ``ENV_WIDTH``, that we declared in the previous step.

A search radius must also be specified, using :func:`setRadius()<flamegpu::MessageSpatial2D::Description::setRadius>`, this is the distance from the search origin that messages must be within to be returned. This radius is used to subdivide the covered environmental area into a discrete grid, messages are then stored according to their position within the grid. For the purposes of this tutorial we will use a radius of ``2``, however you can experiment with changing the value later. 

As messages are used for communication, you will normally want to add variables to them too. As the Circles model is simple, the location implicitly provided by the message is enough. However, we will also add a variable to store the sending agent's ID. This can be used, to ensure agent's don't handle their own messages. Variables are added using :func:`newVariable()<template<typename T> void flamegpu::MessageBruteForce::Description::newVariable(const std::string &)>`, again this is a templated function where the template argument is the type to be used for the variable, and the only regular argument to the function is the variable's name.

.. note ::
    
    FLAME GPU 2 messages (and agents) may also have array variables.
    
    In C++, a second template argument is passed to ``newVariable()``, e.g. ``message.newVariable<int, 3>("vector3");``. 
    
    In Python, a second argument is passed to ``newVariableArray()``, e.g. ``message.newVariableArrayInt("vector3", 3)``.
    

FLAME GPU provides a special type for agent IDs, this is referred to as :type:`flamegpu::id_t` and ``ID`` in the C++ and Python interfaces respectively.


.. tabs::

  .. code-tab:: cpp C++

    ...          
    {   // (optional local scope block for cleaner grouping)
        // Define a message of type MessageSpatial2D named location
        flamegpu::MessageSpatial2D::Description message = model.newMessage<flamegpu::MessageSpatial2D>("location");
        // Configure the message list
        message.setMin(0, 0);
        message.setMax(ENV_WIDTH, ENV_WIDTH);
        message.setRadius(1.0f);
        // Add extra variables to the message
        // X Y (Z) are implicit for spatial messages
        message.newVariable<flamegpu::id_t>("id");
    }
    ...

  .. code-tab:: py Python

    ...
    # Define a message of type MessageSpatial2D named location
    message = model.newMessageSpatial2D("location")
    # Configure the message list
    message.setMin(0, 0)
    message.setMax(ENV_WIDTH, ENV_WIDTH)
    message.setRadius(1)
    # Add extra variables to the message
    # X Y (Z) are implicit for spatial messages
    message.newVariableID("id")
    ...
    

Agent Description
^^^^^^^^^^^^^^^^^

Now it's time to define the agents. In FLAME GPU agents are a collection of variables, agent functions and optionally states. The Circles model is not stateful so their usage will not be covered here, however you can read more about agent states :ref:`here<Agent States>`.

In order to define a new :class:`AgentDescription<flamegpu::AgentDescription>` type, similar to defining a new message type, :func:`newAgent()<flamegpu::ModelDescription::newAgent>` must be called on the previously created :class:`ModelDescription<flamegpu::ModelDescription>`. The sole argument is a string representing the name of the agent, this name is used when referring to the agent type later on (e.g. in host functions). For the Circles model, we will simply name the sole agent type ``"point"``.

Adding variables to an agent is very similar to adding variables to a message, :func:`newVariable()<template<typename T> void flamegpu::AgentDescription::newVariable(const std::string &, const T &)>` is called providing the variable's type, name and optionally a default value. If provided, this default value will be assigned to any newly created/birthed agents. Adding array variables to agent's follows the some rules as explained in the previous section, however they may also have default values specified.

The Circles model requires a location, so we can add three ``float`` variables to represent this. Additionally, we will add a fourth ``float`` named ``"drift"``, this isn't required but can be used to provide us something measurable if not using the visualisation.

.. tabs::

  .. code-tab:: cpp C++

    ...
        
    // Define an agent named point
    flamegpu::AgentDescription agent = model.newAgent("point");
    // Assign the agent some variables (ID is implicit to agents, so we don't define it ourselves)
    agent.newVariable<float>("x");
    agent.newVariable<float>("y");
    agent.newVariable<float>("drift", 0.0f);
    ...

  .. code-tab:: py Python

    ...
    message.newVariableID("id")
    
    # Define an agent named point
    agent = model.newAgent("point")
    # Assign the agent some variables (ID is implicit to agents, so we don't define it ourselves)
    agent.newVariableFloat("x")
    agent.newVariableFloat("y")
    agent.newVariableFloat("drift", 0)
    ...

We'll return to this block of code when we work on the agent functions.

Environment Description
^^^^^^^^^^^^^^^^^^^^^^^

In FLAME GPU, the environment represents state outside of the agents. Agent's have read-only access to the environment's properties, they can only be updated by :ref:`host functions<Host Functions and Conditions>`. Additionally, FLAME GPU 2 adds environment macro properties for representing larger environmental data which agent's have limited access to update, this advanced feature is not covered in the tutorial but can be explored :ref:`here<Define Macro Environmental Properties>`.

Before we can add properties to the environment, we need to fetch the :class:`EnvironmentDescription<flamegpu::EnvironmentDescription>` from the :class:`ModelDescription<flamegpu::ModelDescription>` using :func:`Environment()<flamegpu::ModelDescription::Environment>`.

Following this, much like with messages and agents, :func:`newProperty()<template<typename T> void flamegpu::EnvironmentDescription::newProperty(const std::string &, T, bool)>` is used to add properties to the model's environment. However, an initial value **must** be specified as the second argument.

The Circles model only requires a single environmental property which we will call repulse, this ``float`` property is merely a constant for tuning the force (indirectly the resolution speed) of the model. Initially, it can be set to ``0.05``.

Additionally, we will add the two constants we defined earlier so that they are made available within the model.

.. note ::
    
    FLAME GPU 2 allows environment properties to be marked as ``const``, this prevents them from ever being updated accidentally. This intended for use with values such as mathematical constants. This can be enabled by passing ``true`` (C++) or ``True`` (Python) as the 3rd argument to :func:`newProperty()<template<typename T> void flamegpu::EnvironmentDescription::newProperty(const std::string &, T, bool)>`.

.. tabs::

  .. code-tab:: cpp C++

    ...       
    {   // (optional local scope block for cleaner grouping)
        // Define environment properties
        flamegpu::EnvironmentDescription env = model.Environment();
        env.newProperty<unsigned int>("AGENT_COUNT", AGENT_COUNT);
        env.newProperty<float>("ENV_WIDTH", ENV_WIDTH);
        env.newProperty<float>("repulse", 0.05f);
    }       
    ...

  .. code-tab:: py Python

    ...       
    # Define environment properties
    env = model.Environment()
    env.newPropertyUInt("AGENT_COUNT", AGENT_COUNT)
    env.newPropertyFloat("ENV_WIDTH", ENV_WIDTH)
    env.newPropertyFloat("repulse", 0.05)
    ...


Agent Function Description  Implementation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now that we've defined the messages, agents and environment for the Circles model, it's time to implement the behaviours of our agents and make use of them.


In FLAME GPU 2, agent functions can be implemented using the C++ :c:macro:`FLAMEGPU_AGENT_FUNCTION(name, input_message, output_message)<FLAMEGPU_AGENT_FUNCTION>` macro function. It is expanded by the compiler, to produce the full definition of an agent function (see it's API documentation for an example of it's expansion). However, for our usage we simply need to provide it three parameters; the function's name, the function's message input style and the function's message output style. Then the function can be implemented from this, with the macro call being treated as the function's prototype.

The C++ format of agent function description can be compiled at runtime by specifying the function as a C++ string. This enables models specified in Python to compile on the fly. Runtime compilation adds a small additional cost to the initial execution of an agent function, due to compilation. However, FLAME GPU caches compiled agent functions to remove this for repeated runs (if the agent function/model has not changed). 

When using Python it is possible to specify agent functions using the C++ format as well as via a native Python (a subset of Python referred to as *Agent Python*) description which is shown in this tutorial. Agent functions in Python must be defined as having a ``@pyflamegpu.agent_function`` decorator and using the following syntax ``def outputdata(message_in: pyflamegpu.MessageNone, message_out: pyflamegpu.MessageNone):`` which includes the specification of the name and type (using type annotations) of the output and input message. The Python implementation will translate the Python to C++ at runtime prior to compilation through a process known as transpiling.

To describe our behaviour, we will start by implementing the agent function, whereby each agent outputs a message sharing their location.

We will name the function ``output_message`` (the name should not be wrapped in quotes), it does not have a message input so :class:`flamegpu::MessageNone` (``pyflamegpu.MessageNone`` in Agent Python) is used for the input message argument and we're outputting the spatial 2D message we defined above so :class:`flamegpu::MessageSpatial2D` (``pyflamegpu.MessageSpatial2D`` in Agent Python) is used for the output message argument.

Following this, we can implement the agent function body. Agent functions are provided a single input argument, ``FLAMEGPU`` which is a pointer to the :class:`DeviceAPI<flamegpu::DeviceAPI>`, this object provides access to all available FLAME GPU features (agent variables, message input/output, environment properties, agent output, random) within agent functions.

To implement the output message agent function we need to read the agents location (``"x"``, ``"y"``) variables and ID, and then set the message's location and ``"id"`` variable.

To read an agent's variables the :func:`FLAMEGPU->getVariable()<template<typename T, unsigned int N> __device__ T flamegpu::DeviceAPI::getVariable(const char(&)[N]) const>` function is used in C++. As you may expect by now, the variable's type must be passed as a template argument, and it's name is the only argument. To read an agent's ID, :func:`FLAMEGPU->getID()<flamegpu::DeviceAPI::getID>` is called, this special function requires no additional arguments. The Python implementation uses the same format of appending types to the function name. The functions are accessible via the ``pyflamegpu`` module. E.g. ``pyflamegpu.getVariableInt()`` for an ``int`` type.

Functionality for the message output is accessed via ``FLAMEGPU->message_out`` (or named ``message_out`` variable in Agent Python), this object is specialised depending on the output message type originally specified in the :c:macro:`FLAMEGPU_AGENT_FUNCTION<FLAMEGPU_AGENT_FUNCTION>` macro (or via the Python type annotation). The spatial 2D specialisation, :class:`flamegpu::MessageSpatial2D::Out`, has two available functions; :func:`setVariable()<template<typename T, unsigned int N> __device__ void flamegpu::MessageBruteForce::Out::setVariable(const char(&)[N], T) const>` which is common to all message output types, and :func:`setLocation()<flamegpu::MessageSpatial2D::Out::setLocation>` which takes two ``float`` arguments specifying the location of the message in 2D space. The Python equivalents are of the same format as in other places (e.g. ``setVariableInt`` for the ``int`` type).

Finally, all agent functions must return either :enumerator:`flamegpu::ALIVE<flamegpu::AGENT_STATUS::ALIVE>` or :enumerator:`flamegpu::DEAD<flamegpu::AGENT_STATUS::DEAD>` (``pyflamegpu.ALIVE`` or ``pyflamegpu.DEAD`` respectively in Agent Python). Unless the agent function is specified to support agent death inside the :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` via :func:`setAllowAgentDeath()<flamegpu::AgentFunctionDescription::setAllowAgentDeath>`, :enumerator:`flamegpu::ALIVE<flamegpu::AGENT_STATUS::ALIVE>` should be returned. If :enumerator:`flamegpu::DEAD<flamegpu::AGENT_STATUS::DEAD>` is returned, without agent death being enabled, an exception will be raised if ``FLAMEGPU_SEATBELTS`` error checking is enabled.

    

Below you can see how the message output function may be assembled. Normally, agent functions would be implemented near the top of the source file directly after any includes.

.. tabs::

  .. code-tab:: cpp Agent C++

    ...
    // Agent Function to output the agents ID and position in to a 2D spatial message list
    FLAMEGPU_AGENT_FUNCTION(output_message, flamegpu::MessageNone, flamegpu::MessageSpatial2D) {
        FLAMEGPU->message_out.setVariable<int>("id", FLAMEGPU->getID());
        FLAMEGPU->message_out.setLocation(
            FLAMEGPU->getVariable<float>("x"),
            FLAMEGPU->getVariable<float>("y"));
        return flamegpu::ALIVE;
    }
    ...

  .. code-tab:: py Python with Agent C++

    ...
    # Agent Function to output the agents ID and position in to a 2D spatial message list
    output_message = r"""
    FLAMEGPU_AGENT_FUNCTION(output_message, flamegpu::MessageNone, flamegpu::MessageSpatial2D) {
        FLAMEGPU->message_out.setVariable<flamegpu::id_t>("id", FLAMEGPU->getID());
        FLAMEGPU->message_out.setLocation(
            FLAMEGPU->getVariable<float>("x"),
            FLAMEGPU->getVariable<float>("y"));
        return flamegpu::ALIVE;
    }
    """
    ...

  .. code-tab:: py Agent Python

    ...
    # Agent Function to output the agents ID and position in to a 2D spatial message list
    @pyflamegpu.agent_function
    def output_message(message_in: pyflamegpu.MessageNone, message_out: pyflamegpu.MessageSpatial2D):
        message_out.setVariableUInt("id", pyflamegpu.getID())
        message_out.setLocation(
            pyflamegpu.getVariableFloat("x"),
            pyflamegpu.getVariableFloat("y"))
        return pyflamegpu.ALIVE
    ...
    
Next the message input agent function is implemented, two new concepts are introduced here: the message input iterator and accessing environment properties.

Each FLAME GPU message type provides unique methods for accessing messages, in this case we are using the :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>` type. Refer to the :ref:`agent communication guide<Device Agent Communication>` for details of other messaging format's usage.

The only way to access spatial messaging types is via an iterator, which returns all messages in a Moore neighbourhood (discretised by the message radius) about the provided search location. This means, that all messages within the originally specified search radius will be returned, however it is necessary for the user to filter out messages which are contained within the Moore neighbour but fall outside of this radius. Furthermore, agents will also receive their own message, so may wish to filter the messages by checking the originating agent's id.

The spatial message iterator is accessed using :func:`FLAMEGPU->message_in()<flamegpu::MessageSpatial2D::In::operator()>` (or via the ``message_in`` agent function argument in Agent Python), this takes two ``float`` parameters specifying the search origin. Normally this will be passed directly to a C++ range-based for loop, allowing the returned messages to be iterated.

In the case of :class:`MessageSpatial2D<flamegpu::MessageSpatial2D>`, the returned :class:`Message<flamegpu::MessageSpatial2D::In::Filter::Message>` objects only provide :func:`getVariable()<template<typename T, unsigned int N> __device__ T flamegpu::MessageSpatial2D::In::Filter::Message::getVariable(const char(&)[N]) const>` methods for returning the variables and array variables stored within the message. The Python equivalent requires the type and array length to be appended to the function name (e.g. ``getVariableIntArray3(...)``).

Accessing environment properties is very similar to accessing agent and message variables, :func:`getProperty()<template<typename T, unsigned int N> T flamegpu::ReadOnlyDeviceEnvironment::getProperty(const char(&)[N]) const>` is called on :class:`FLAMEGPU->environment<flamegpu::DeviceEnvironment>`. The Python equivalent requires the type and array length to be appended to the function name (e.g. ``getVariableIntArray3(...)``).

The remainder of the Circles model's message input agent function contains some model specific maths, so you should simply use the code provided below. However, give it a thorough read to check you understand how the messages are being read.


.. tabs::

  .. code-tab:: cpp Agent C++

    ...
    // Agent Function to read the location messages and decide how the agent should move
    FLAMEGPU_AGENT_FUNCTION(input_message, flamegpu::MessageSpatial2D, flamegpu::MessageNone) {
        const flamegpu::id_t ID = FLAMEGPU->getID();
        const float REPULSE_FACTOR = FLAMEGPU->environment.getProperty<float>("repulse");
        const float RADIUS = FLAMEGPU->message_in.radius();
        float fx = 0.0;
        float fy = 0.0;
        const float x1 = FLAMEGPU->getVariable<float>("x");
        const float y1 = FLAMEGPU->getVariable<float>("y");
        int count = 0;
        for (const auto &message : FLAMEGPU->message_in(x1, y1)) {
            if (message.getVariable<flamegpu::id_t>("id") != ID) {
                const float x2 = message.getVariable<float>("x");
                const float y2 = message.getVariable<float>("y");
                float x21 = x2 - x1;
                float y21 = y2 - y1;
                const float separation = sqrtf(x21*x21 + y21*y21);
                if (separation < RADIUS && separation > 0.0f) {
                    float k = sinf((separation / RADIUS)*3.141f*-2)*REPULSE_FACTOR;
                    // Normalise without recalculating separation
                    x21 /= separation;
                    y21 /= separation;
                    fx += k * x21;
                    fy += k * y21;
                    count++;
                }
            }
        }
        fx /= count > 0 ? count : 1;
        fy /= count > 0 ? count : 1;
        FLAMEGPU->setVariable<float>("x", x1 + fx);
        FLAMEGPU->setVariable<float>("y", y1 + fy);
        FLAMEGPU->setVariable<float>("drift", sqrt(fx*fx + fy*fy));
        return flamegpu::ALIVE;
    }
    ...

  .. code-tab:: py Python with Agent C++

    ...
    # Agent Function to read the location messages and decide how the agent should move
    input_message = r"""
    FLAMEGPU_AGENT_FUNCTION(input_message, flamegpu::MessageSpatial2D, flamegpu::MessageNone) {
        const flamegpu::id_t ID = FLAMEGPU->getID();
        const float REPULSE_FACTOR = FLAMEGPU->environment.getProperty<float>("repulse");
        const float RADIUS = FLAMEGPU->message_in.radius();
        float fx = 0.0;
        float fy = 0.0;
        const float x1 = FLAMEGPU->getVariable<float>("x");
        const float y1 = FLAMEGPU->getVariable<float>("y");
        int count = 0;
        for (const auto &message : FLAMEGPU->message_in(x1, y1)) {
            if (message.getVariable<flamegpu::id_t>("id") != ID) {
                const float x2 = message.getVariable<float>("x");
                const float y2 = message.getVariable<float>("y");
                float x21 = x2 - x1;
                float y21 = y2 - y1;
                const float separation = sqrtf(x21*x21 + y21*y21);
                if (separation < RADIUS && separation > 0.0f) {
                    float k = sinf((separation / RADIUS)*3.141f*-2)*REPULSE_FACTOR;
                    // Normalise without recalculating separation
                    x21 /= separation;
                    y21 /= separation;
                    fx += k * x21;
                    fy += k * y21;
                    count++;
                }
            }
        }
        fx /= count > 0 ? count : 1;
        fy /= count > 0 ? count : 1;
        FLAMEGPU->setVariable<float>("x", x1 + fx);
        FLAMEGPU->setVariable<float>("y", y1 + fy);
        FLAMEGPU->setVariable<float>("drift", sqrt(fx*fx + fy*fy));
        return flamegpu::ALIVE;
    }
    """
    ...

  .. code-tab:: py Agent Python
    
    ...
    # Agent Function to read the location messages and decide how the agent should move
    @pyflamegpu.agent_function
    def input_message(message_in: pyflamegpu.MessageSpatial2D, message_out: pyflamegpu.MessageNone):
        ID = pyflamegpu.getID()
        REPULSE_FACTOR = pyflamegpu.environment.getPropertyFloat("repulse")
        RADIUS = message_in.radius()
        fx = 0.0
        fy = 0.0
        x1 = pyflamegpu.getVariableFloat("x")
        y1 = pyflamegpu.getVariableFloat("y")
        count = 0
        for message in message_in(x1, y1) :
            if message.getVariableUInt("id") != ID :
                x2 = message.getVariableFloat("x")
                y2 = message.getVariableFloat("y")
                x21 = x2 - x1
                y21 = y2 - y1
                separation = math.sqrtf(x21*x21 + y21*y21)
                if separation < RADIUS and separation > 0 :
                    k = math.sinf((separation / RADIUS)*3.141*-2)*REPULSE_FACTOR
                    # Normalise without recalculating separation
                    x21 /= separation
                    y21 /= separation
                    fx += k * x21
                    fy += k * y21
                    count += 1
        fx /= count if count > 0 else 1
        fy /= count if count > 0 else 1
        pyflamegpu.setVariableFloat("x", x1 + fx)
        pyflamegpu.setVariableFloat("y", y1 + fy)
        pyflamegpu.setVariableFloat("drift", math.sqrtf(fx*fx + fy*fy))
        return pyflamegpu.ALIVE
    ...
    
Now that both agent functions have been implemented, they must be attached to the model.

Returning to the earlier defined agent, first we use this to create an :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` for each of the two function's that we have defined using :func:`newFunction()<flamegpu::AgentDescription::newFunction>` (C++ API) or :func:`newRTCFunction()<flamegpu::AgentDescription::newRTCFunction>` (Python or C++ Agent API). Both of these functions take two arguments, firstly a name to refer to the function, and secondly the function implementation that was defined above.

If the agent function has been specified in Python then it will need to be translated using the ``pyflamegpu.codegen.translate()`` function. The resulting C++ agent code can then be passed to :func:`newRTCFunction()<flamegpu::AgentDescription::newRTCFunction>`.

The returned :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>` can then be used to configure the agent function, enabling support for agent birth and death and any message inputs or outputs that are used. As we are using messages, we must call :func:`setMessageOutput()<flamegpu::AgentFunctionDescription::setMessageOutput>` and :func:`setMessageInput()<flamegpu::AgentFunctionDescription::setMessageInput>` passing the name give to our message type (``"location"``).

.. tabs::

  .. code-tab:: cpp C++

    ...
    // Setup the two agent functions
    flamegpu::AgentFunctionDescription out_fn = agent.newFunction("output_message", output_message);
    out_fn.setMessageOutput("location");
    flamegpu::AgentFunctionDescription in_fn = agent.newFunction("input_message", input_message);
    in_fn.setMessageInput("location");   
    ...

  .. code-tab:: py Python (using C++ Agent API)

    ...
    # Setup the two agent functions
    out_fn = agent.newRTCFunction("output_message", output_message)
    out_fn.setMessageOutput("location")
    in_fn = agent.newRTCFunction("input_message", input_message)
    in_fn.setMessageInput("location")
    
    ...

  .. code-tab:: py Python (using Python Agent API)

    #ensure to import the codegen module (usually at the top of your Python file)
    import pyflamegpu.codegen
    ...
    agent.newVariableFloat("drift", 0)
    # translate the agent functions from Python to C++
    output_func_translated = pyflamegpu.codegen.translate(output_message)
    input_func_translated = pyflamegpu.codegen.translate(input_message)
    # Setup the two agent functions
    out_fn = agent.newRTCFunction("output_message", output_func_translated)
    out_fn.setMessageOutput("location")
    in_fn = agent.newRTCFunction("input_message", input_func_translated)
    in_fn.setMessageInput("location")
    
    ...
    
Execution Order
^^^^^^^^^^^^^^^

Finally, the model's execution flow must be setup. This can be achieved using either the old FLAME GPU 1 style with layers (see :func:`ModelDescription::newLayer()<flamegpu::ModelDescription::newLayer>`), or the new dependency graph API. In this tutorial we will use the dependency API.

To define the order in which functions are executed during the model, their dependencies must be specified. :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`, :class:`HostFunctionDescription<flamegpu::HostFunctionDescription>` and :class:`SubModelDescription<flamegpu::SubModelDescription>` objects all implement :func:`dependsOn()<template<typename A> void flamegpu::DependencyNode::dependsOn(A&)>`. This is used to specify dependencies between the functions of the model.

The root of the graph specified with :func:`ModelDescription::addExecutionRoot()<flamegpu::ModelDescription::addExecutionRoot>`, and finally the dependency graph converted to layers via :func:`ModelDescription::generateLayers()<flamegpu::ModelDescription::generateLayers>`.


This can be placed at the end of the file, following the previously defined environment properties.

.. tabs::

  .. code-tab:: cpp C++

    ...        
    {   // (optional local scope block for cleaner grouping)
        // Dependency specification
        // Message input depends on output
        in_fn.dependsOn(out_fn);
        // Output is the root of our graph
        model.addExecutionRoot(out_fn);
        model.generateLayers();
    }
    ...

  .. code-tab:: py Python

    ...
    # Message input depends on output
    in_fn.dependsOn(out_fn)
    # Dependency specification
    # Output is the root of our graph
    model.addExecutionRoot(out_fn)
    model.generateLayers()
    ...

Initialisation Function
^^^^^^^^^^^^^^^^^^^^^^^

Now that the model's components and behaviours have been setup, it's time to decide how the model will be initialised. FLAME GPU allows models to be initialised either via input file and/or user-defined initialisation functions, which may depend on environmental properties or agents loaded from input file.

For the Circles model, we simply need to randomly scatter an amount of agents within the environment bounds. Therefore, we can simply generate agents according to some of the environment properties we defined earlier.

Similar to agent functions, the C++ API defines initialisation functions using :c:macro:`FLAMEGPU_INIT_FUNCTION`, which takes a single argument of the function's name. Python in contrast has native functions, so they are defined differently, a subclass of ``pyflamegpu.HostFunction`` must be created, which implements the method ``def run(self, FLAMEGPU):``.

Initialisation function's have access to the :class:`HostAPI<flamegpu::HostAPI>`, the host counter-part to the :class:`DeviceAPI<flamegpu::DeviceAPI>` present in agent functions. It has similar functionality, with a few additional features: agent variable reductions, setting environment properties.

Firstly we will need to generate some random numbers, to decide the locations. The :class:`HostAPI<flamegpu::HostAPI>` contains ``random`` which provides access to random functionality via :class:`HostRandom<flamegpu::HostRandom>`. This provides the :func:`uniform()<template<typename T> T flamegpu::HostRandom::uniform() const>`. It only requires a template argument ``float``, and will return a random number in the inclusive-exclusive range ``[0, 1)``.

The only feature we need to use that is unique to the :class:`HostAPI<flamegpu::HostAPI>` is agent birth, on the host any number of agents can be created without the limitations of agent functions. First we fetch the :class:`HostAgentAPI<flamegpu::HostAgentAPI>` for the ``"point"`` agent, this gives us access to functionality affect that agent. Then we can simply call :func:`newAgent()<flamegpu::HostAgentAPI::newAgent>` to create new agents, the returned agent has the normal :func:`setVariable()<template<typename T> void flamegpu::HostNewAgentAPI::setVariable(const std::string &, const T &)>` functionality and will be added to the simulation after the initialisation functions have all completed.
enumerator

The initialisation function, again, goes near the top of the file alongside the agent functions.

Putting all this together, we can use the below code to generate the initial agent population:

.. tabs::

  .. code-tab:: cpp C++
  
    ...
    FLAMEGPU_INIT_FUNCTION(create_agents) {
        // Fetch the desired agent count and environment width
        const unsigned int AGENT_COUNT = FLAMEGPU->environment.getProperty<unsigned int>("AGENT_COUNT");
        const float ENV_WIDTH = FLAMEGPU->environment.getProperty<float>("ENV_WIDTH");
        // Create agents
        flamegpu::HostAgentAPI t_pop = FLAMEGPU->agent("point");
        for (unsigned int i = 0; i < AGENT_COUNT; ++i) {
            auto t = t_pop.newAgent();
            t.setVariable<float>("x", FLAMEGPU->random.uniform<float>() * ENV_WIDTH);
            t.setVariable<float>("y", FLAMEGPU->random.uniform<float>() * ENV_WIDTH);
        }
    }
    ...

  .. code-tab:: py Python

    ...   
    class create_agents(pyflamegpu.HostFunction):
        def run(self, FLAMEGPU):
            # Fetch the desired agent count and environment width
            AGENT_COUNT = FLAMEGPU.environment.getPropertyUInt("AGENT_COUNT")
            ENV_WIDTH = FLAMEGPU.environment.getPropertyFloat("ENV_WIDTH")
            # Create agents
            t_pop = FLAMEGPU.agent("point")
            for i in range(AGENT_COUNT):
                t = t_pop.newAgent()
                t.setVariableFloat("x", FLAMEGPU.random.uniformFloat() * ENV_WIDTH)
                t.setVariableFloat("y", FLAMEGPU.random.uniformFloat() * ENV_WIDTH)
    ...
                
                
.. note ::
    
    Use of the FLAME GPU random API in initialisation functions, ensure that the random (and hence the model) is seeded according to the random seed specified for the simulation at execution.
    
Similar to agent functions, the initialisation function must be attached to the model. Initialisation function's always run once at the start of the model, so it's not necessary to use layer or a dependency graph, they are simply added to the :class:`ModelDescription<flamegpu::ModelDescription>` using :func:`addInitFunction()<flamegpu::ModelDescription::addInitFunction>` (C++ API) or ``addInitFunction()`` (Python API).

.. tabs::

  .. code-tab:: cpp C++

    ...      
    model.addInitFunction(create_agents);
    ...

  .. code-tab:: py Python

    ...
    dependencyGraph.generateLayers(model)
    model.addInitFunction(create_agents())
    ...
    

Configuring the Simulation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The :class:`ModelDescription<flamegpu::ModelDescription>` is now complete, so it is time to construct a :class:`CUDASimulation<flamegpu::CUDASimulation>` to execute the model.

In most cases, this is simply a case of constructing the :class:`CUDASimulation<flamegpu::CUDASimulation>`, initialising it with command line arguments and calling :func:`simulate()<flamegpu::CUDASimulation::simulate>`. It is also possible to setup this configuration in code, for details see the :ref:`userguide<Configuring Execution>`.


.. tabs::

  .. code-tab:: cpp C++

    ...        
    // Create and run the simulation
    flamegpu::CUDASimulation cuda_model(model, argc, argv);
    cuda_model.simulate();

  .. code-tab:: py Python
  
    ...
    # Import sys for access to run args (this can be moved to the top of your Python file)
    import sys
    
    # Create and run the simulation
    cuda_model = pyflamegpu.CUDASimulation(model)
    cuda_model.initialise(sys.argv)
    cuda_model.simulate()

You can optionally configure logging or visualisation via the :class:`CUDASimulation<flamegpu::CUDASimulation>`, these are explained in the following two sections.

Configuring Logging (Optional)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
When running FLAME GPU models without a visualisation, you most likely want to collect data from the runs. This can be carried out by defining a logging configuration.

For this tutorial we will log the mean of our ``"point"`` agents' ``"drift"`` variable each step, if the model is working correctly this value should trend towards zero as the agents reach a steady state.

To achieve this we must first create a :class:`StepLoggingConfig<flamegpu::StepLoggingConfig>`, passing our finished :class:`ModelDescription<flamegpu::ModelDescription>` to it's constructor.

This object provides a wide range of options for logging agent data and environment properties. However, we only need to request the :class:`AgentLoggingConfig<flamegpu::AgentLoggingConfig>` using :func:`agent()<flamegpu::LoggingConfig::agent>`. After which, we simply call :func:`logMean()<flamegpu::AgentLoggingConfig::logMean>`, providing the agent variable's type as a template argument and it's name as the sole argument.

After the :class:`StepLoggingConfig<flamegpu::StepLoggingConfig>` is fully defined, it can be attached to the :class:`CUDASimulation<flamegpu::CUDASimulation>` using :func:`setStepLog()<flamegpu::CUDASimulation::setStepLog>`.

.. tabs::

  .. code-tab:: cpp C++

    ... // following on from  model.addInitFunction(create_agents);
            
    // Specify the desired StepLoggingConfig
    flamegpu::StepLoggingConfig step_log_cfg(model);
    // Log every step
    step_log_cfg.setFrequency(1);
    // Include the mean of the "point" agent population's variable 'drift'
    step_log_cfg.agent("point").logMean<float>("drift");
    
    // Create the simulation
    flamegpu::CUDASimulation cuda_model(model, argc, argv);
    
    // Attach the logging config
    cuda_model.setStepLog(step_log_cfg);
    
    // Run the simulation
    cuda_model.simulate();

  .. code-tab:: py Python
  
    ... # following on from model.addInitFunction(create_agents())
    
    # Specify the desired StepLoggingConfig
    step_log_cfg = pyflamegpu.StepLoggingConfig(model)
    # Log every step
    step_log_cfg.setFrequency(1)
    # Include the mean of the "point" agent population's variable 'drift'
    step_log_cfg.agent("point").logMeanFloat("drift")
        
    # Create the simulation
    cuda_model = pyflamegpu.CUDASimulation(model)
        
    # Attach the logging config
    cuda_model.setStepLog(step_log_cfg)
        
    # Init and run the simulation
    cuda_model.initialise(sys.argv)
    cuda_model.simulate()

After the simulation has completed, the log can then be collected using :func:`getRunLog()<flamegpu::CUDASimulation::getRunLog>` or written to file if the appropriate output files were :ref:`configured<Configuring Execution>` before execution.

To learn more about using logging configurations see the :ref:`userguide<Collecting Data>`.

Visualisation Config (Optional)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning::

    Visualisation support is disabled by default. To enable visualisation support `FLAMEGPU_VISUALISATION` must be enabled at CMake configure time. If using a prebuilt Python wheel, ensure you select a wheel with ``vis`` in the name for visualisation support.

Many models are easier to quickly validate early on by using a visualisation, FLAME GPU provides a visualiser capable of visualising agents locations, directions, scales and colours dependent on their variables.

The visualisation configuration (:class:`ModelVis<flamegpu::visualiser::ModelVis>`) is created from the :class:`CUDASimulation<flamegpu::CUDASimulation>` using :func:`getVisualisation()<flamegpu::CUDASimulation::getVisualisation>`. This provides many advanced options for configuring the visualisation, see the :ref:`userguide<Visualisation>` for the full overview, we will cover the minimum required for visualising the Circles model here.

The below code positions the initial camera, sets the camera's movement speed (when a user uses the keyboard to move), renders the ``"point"`` agents as icospheres (these are a low polygon count sphere, great for high agent count visualisations), and marks out the environment boundaries with a white square.

Additionally the simulation speed is limited to 25 steps per second. This allows the evolution of the simulation to be visualised more clearly. This small model would normally execute in hundreds of steps per second, reaching a steady state too fast to observe.

It is important to call :func:`activate()<flamegpu::visualiser::ModelVis::activate>` after the visualisation configuration is complete, to finalise and start the visualiser.

In most cases, you will want the visualisation to persist after the simulation completes, so the exit state can be explored. To achieve this, :func:`join()<flamegpu::visualiser::ModelVis::join>` must be called after :func:`simulate()<flamegpu::CUDASimulation::simulate>` to catch the main program thread before it exits.


.. note::
    
    FLAME GPU is designed for use both on personal machines and headless machines over ssh (e.g. HPC). The latter are unlikely to have support for visualisations, as such FLAME GPU can be built without visualisation support. Hence, it is useful to wrap the visualisation specific code with a check for the ``FLAMEGPU_VISUALISATION`` macro, allowing the model to compile/run irrespective of visualisation support as opposed to maintaining two versions.


.. tabs::

  .. code-tab:: cpp C++

    ... // following on from flamegpu::CUDASimulation cuda_model(model, argc, argv);
        
    // Only compile this block if being built with visualisation support    
    #ifdef FLAMEGPU_VISUALISATION
        // Create visualisation
        flamegpu::visualiser::ModelVis m_vis = cuda_model.getVisualisation();
        // Set the initial camera location and speed
        const float INIT_CAM = ENV_WIDTH / 2.0f;
        m_vis.setInitialCameraTarget(INIT_CAM, INIT_CAM, 0);
        m_vis.setInitialCameraLocation(INIT_CAM, INIT_CAM, ENV_WIDTH);
        m_vis.setCameraSpeed(0.01f);
        m_vis.setSimulationSpeed(25);
        // Add "point" agents to the visualisation
        flamegpu::visualiser::AgentVis point_agt = m_vis.addAgent("point");
        // Location variables have names "x" and "y" so will be used by default
        point_agt.setModel(flamegpu::visualiser::Stock::Models::ICOSPHERE);
        point_agt.setModelScale(1/10.0f);
        // Mark the environment bounds
        flamegpu::visualiser::LineVis pen = m_vis.newPolylineSketch(1, 1, 1, 0.2f);
        pen.addVertex(0, 0, 0);
        pen.addVertex(0, ENV_WIDTH, 0);
        pen.addVertex(ENV_WIDTH, ENV_WIDTH, 0);
        pen.addVertex(ENV_WIDTH, 0, 0);
        pen.addVertex(0, 0, 0);
        // Open the visualiser window
        m_vis.activate();
    #endif
    
        // Run the simulation
        cuda_model.simulate();
        
    #ifdef FLAMEGPU_VISUALISATION
        // Keep the visualisation window active after the simulation has completed
        m_vis.join();
    #endif

  .. code-tab:: py Python
  
    ... # following on from cuda_model = pyflamegpu.CUDASimulation(model)
        
    # Only run this block if pyflamegpu was built with visualisation support 
    if pyflamegpu.VISUALISATION:
        # Create visualisation
        m_vis = cuda_model.getVisualisation()
        # Set the initial camera location and speed
        INIT_CAM = ENV_WIDTH / 2
        m_vis.setInitialCameraTarget(INIT_CAM, INIT_CAM, 0)
        m_vis.setInitialCameraLocation(INIT_CAM, INIT_CAM, ENV_WIDTH)
        m_vis.setCameraSpeed(0.01)
        m_vis.setSimulationSpeed(25)
        # Add "point" agents to the visualisation
        point_agt = m_vis.addAgent("point")
        # Location variables have names "x" and "y" so will be used by default
        point_agt.setModel(pyflamegpu.ICOSPHERE);
        point_agt.setModelScale(1/10.0);
        # Mark the environment bounds
        pen = m_vis.newPolylineSketch(1, 1, 1, 0.2)
        pen.addVertex(0, 0, 0)
        pen.addVertex(0, ENV_WIDTH, 0)
        pen.addVertex(ENV_WIDTH, ENV_WIDTH, 0)
        pen.addVertex(ENV_WIDTH, 0, 0)
        pen.addVertex(0, 0, 0)
        # Open the visualiser window
        m_vis.activate()

    # Run the simulation
    cuda_model.simulate()
    
    if pyflamegpu.VISUALISATION:
        # Keep the visualisation window active after the simulation has completed
        m_vis.join()

Running the Simulation
^^^^^^^^^^^^^^^^^^^^^^

At this point, you should have a complete model which can be (compiled and) ran.

To run the model for **500** steps with the random seed **12** you would pass the runtime arguments ``-s 500 -r 12``.

If you chose to add a logging config, you will want to additionally specify a log file e.g. ``--out-step step.json``.

If you have included the visualisation, however wish to block it from running you would include ``--console`` or ``-c``.

If you wish to continue learning with the Circles model try one of these extensions:

* Extend the model to operate in 3D.
* Extend the model to operate in a wrapped 2D (toroidal) environment.
* Extend the visualisation to colour agents according to their ``drift`` variable, or number of messages read.
* Extend the model by giving agents a weight that affects the force they apply/receive to/from other agents.


Complete Tutorial Code
^^^^^^^^^^^^^^^^^^^^^^

If you have followed the complete tutorial, you should now have the following code.

  
    
.. tabs::

  .. code-tab:: cpp C++

      #include "flamegpu/flamegpu.h"

      // Agent Function to output the agents ID and position in to a 2D spatial message list
      FLAMEGPU_AGENT_FUNCTION(output_message, flamegpu::MessageNone, flamegpu::MessageSpatial2D) {
          FLAMEGPU->message_out.setVariable<int>("id", FLAMEGPU->getID());
          FLAMEGPU->message_out.setLocation(
              FLAMEGPU->getVariable<float>("x"),
              FLAMEGPU->getVariable<float>("y"));
          return flamegpu::ALIVE;
      }

      // Agent Function to read the location messages and decide how the agent should move
      FLAMEGPU_AGENT_FUNCTION(input_message, flamegpu::MessageSpatial2D, flamegpu::MessageNone) {
          const flamegpu::id_t ID = FLAMEGPU->getID();
          const float REPULSE_FACTOR = FLAMEGPU->environment.getProperty<float>("repulse");
          const float RADIUS = FLAMEGPU->message_in.radius();
          float fx = 0.0;
          float fy = 0.0;
          const float x1 = FLAMEGPU->getVariable<float>("x");
          const float y1 = FLAMEGPU->getVariable<float>("y");
          int count = 0;
          for (const auto &message : FLAMEGPU->message_in(x1, y1)) {
              if (message.getVariable<flamegpu::id_t>("id") != ID) {
                  const float x2 = message.getVariable<float>("x");
                  const float y2 = message.getVariable<float>("y");
                  float x21 = x2 - x1;
                  float y21 = y2 - y1;
                  const float separation = sqrt(x21*x21 + y21*y21);
                  if (separation < RADIUS && separation > 0.0f) {
                      float k = sinf((separation / RADIUS)*3.141f*-2)*REPULSE_FACTOR;
                      // Normalise without recalculating separation
                      x21 /= separation;
                      y21 /= separation;
                      fx += k * x21;
                      fy += k * y21;
                      count++;
                  }
              }
          }
          fx /= count > 0 ? count : 1;
          fy /= count > 0 ? count : 1;
          FLAMEGPU->setVariable<float>("x", x1 + fx);
          FLAMEGPU->setVariable<float>("y", y1 + fy);
          FLAMEGPU->setVariable<float>("drift", sqrt(fx*fx + fy*fy));
          return flamegpu::ALIVE;
      }

      FLAMEGPU_INIT_FUNCTION(create_agents) {
          // Fetch the desired agent count and environment width
          const unsigned int AGENT_COUNT = FLAMEGPU->environment.getProperty<unsigned int>("AGENT_COUNT");
          const float ENV_WIDTH = FLAMEGPU->environment.getProperty<float>("ENV_WIDTH");
          // Create agents
          flamegpu::HostAgentAPI t_pop = FLAMEGPU->agent("point");
          for (unsigned int i = 0; i < AGENT_COUNT; ++i) {
              auto t = t_pop.newAgent();
              t.setVariable<float>("x", FLAMEGPU->random.uniform<float>() * ENV_WIDTH);
              t.setVariable<float>("y", FLAMEGPU->random.uniform<float>() * ENV_WIDTH);
          }
      }

      int main(int argc, const char **argv) {
          // Define some useful constants
          const unsigned int AGENT_COUNT = 16384;
          const float ENV_WIDTH = static_cast<float>(floor(cbrt(AGENT_COUNT)));

          // Define the FLAME GPU model
          flamegpu::ModelDescription model("Circles Tutorial");

          {   // (optional local scope block for cleaner grouping)
              // Define a message of type MessageSpatial2D named location
              flamegpu::MessageSpatial2D::Description message = model.newMessage<flamegpu::MessageSpatial2D>("location");
              // Configure the message list
              message.setMin(0, 0);
              message.setMax(ENV_WIDTH, ENV_WIDTH);
              message.setRadius(1.0f);
              // Add extra variables to the message
              // X Y (Z) are implicit for spatial messages
              message.newVariable<flamegpu::id_t>("id");
          }

          // Define an agent named point
          flamegpu::AgentDescription agent = model.newAgent("point");
          // Assign the agent some variables (ID is implicit to agents, so we don't define it ourselves)
          agent.newVariable<float>("x");
          agent.newVariable<float>("y");
          agent.newVariable<float>("drift", 0.0f);
          // Setup the two agent functions
          flamegpu::AgentFunctionDescription out_fn = agent.newFunction("output_message", output_message);
          out_fn.setMessageOutput("location");
          flamegpu::AgentFunctionDescription in_fn = agent.newFunction("input_message", input_message);
          in_fn.setMessageInput("location");

          {   // (optional local scope block for cleaner grouping)
              // Define environment properties
              flamegpu::EnvironmentDescription env = model.Environment();
              env.newProperty<unsigned int>("AGENT_COUNT", AGENT_COUNT);
              env.newProperty<float>("ENV_WIDTH", ENV_WIDTH);
              env.newProperty<float>("repulse", 0.05f);
          }

          {   // (optional local scope block for cleaner grouping)
              // Dependency specification
              // Message input depends on output
              in_fn.dependsOn(out_fn);
              // Output is the root of our graph
              model.addExecutionRoot(out_fn);
              model.generateLayers();
          }

          model.addInitFunction(create_agents);

          // Specify the desired StepLoggingConfig
          flamegpu::StepLoggingConfig step_log_cfg(model);
          // Log every step
          step_log_cfg.setFrequency(1);
          // Include the mean of the "point" agent population's variable 'drift'
          step_log_cfg.agent("point").logMean<float>("drift");

          // Create the simulation
          flamegpu::CUDASimulation cuda_model(model, argc, argv);

          // Attach the logging config
          cuda_model.setStepLog(step_log_cfg);
          
      // Only compile this block if being built with visualisation support
      #ifdef FLAMEGPU_VISUALISATION
          // Create visualisation
          flamegpu::visualiser::ModelVis m_vis = cuda_model.getVisualisation();
          // Set the initial camera location and speed
          const float INIT_CAM = ENV_WIDTH / 2.0f;
          m_vis.setInitialCameraTarget(INIT_CAM, INIT_CAM, 0);
          m_vis.setInitialCameraLocation(INIT_CAM, INIT_CAM, ENV_WIDTH);
          m_vis.setCameraSpeed(0.01f);
          m_vis.setSimulationSpeed(25);
          // Add "point" agents to the visualisation
          flamegpu::visualiser::AgentVis point_agt = m_vis.addAgent("point");
          // Location variables have names "x" and "y" so will be used by default
          point_agt.setModel(flamegpu::visualiser::Stock::Models::ICOSPHERE);
          point_agt.setModelScale(1/10.0f);
          // Mark the environment bounds
          flamegpu::visualiser::LineVis pen = m_vis.newPolylineSketch(1, 1, 1, 0.2f);
          pen.addVertex(0, 0, 0);
          pen.addVertex(0, ENV_WIDTH, 0);
          pen.addVertex(ENV_WIDTH, ENV_WIDTH, 0);
          pen.addVertex(ENV_WIDTH, 0, 0);
          pen.addVertex(0, 0, 0);
          // Open the visualiser window
          m_vis.activate();
      #endif
          
          // Run the simulation
          cuda_model.simulate();
          
      #ifdef FLAMEGPU_VISUALISATION
          // Keep the visualisation window active after the simulation has completed
          m_vis.join();
      #endif
      }

  .. code-tab:: py Python (using C++ Agent API)
  
      import pyflamegpu
      # Import sys for access to run args
      import sys

      # Agent Function to output the agents ID and position in to a 2D spatial message list
      output_message = r"""
      FLAMEGPU_AGENT_FUNCTION(output_message, flamegpu::MessageNone, flamegpu::MessageSpatial2D) {
          FLAMEGPU->message_out.setVariable<flamegpu::id_t>("id", FLAMEGPU->getID());
          FLAMEGPU->message_out.setLocation(
              FLAMEGPU->getVariable<float>("x"),
              FLAMEGPU->getVariable<float>("y"));
          return flamegpu::ALIVE;
      }
      """

      # Agent Function to read the location messages and decide how the agent should move
      input_message = r"""
      FLAMEGPU_AGENT_FUNCTION(input_message, flamegpu::MessageSpatial2D, flamegpu::MessageNone) {
          const flamegpu::id_t ID = FLAMEGPU->getID();
          const float REPULSE_FACTOR = FLAMEGPU->environment.getProperty<float>("repulse");
          const float RADIUS = FLAMEGPU->message_in.radius();
          float fx = 0.0;
          float fy = 0.0;
          const float x1 = FLAMEGPU->getVariable<float>("x");
          const float y1 = FLAMEGPU->getVariable<float>("y");
          int count = 0;
          for (const auto &message : FLAMEGPU->message_in(x1, y1)) {
              if (message.getVariable<flamegpu::id_t>("id") != ID) {
                  const float x2 = message.getVariable<float>("x");
                  const float y2 = message.getVariable<float>("y");
                  float x21 = x2 - x1;
                  float y21 = y2 - y1;
                  const float separation = sqrt(x21*x21 + y21*y21);
                  if (separation < RADIUS && separation > 0.0f) {
                      float k = sinf((separation / RADIUS)*3.141f*-2)*REPULSE_FACTOR;
                      // Normalise without recalculating separation
                      x21 /= separation;
                      y21 /= separation;
                      fx += k * x21;
                      fy += k * y21;
                      count++;
                  }
              }
          }
          fx /= count > 0 ? count : 1;
          fy /= count > 0 ? count : 1;
          FLAMEGPU->setVariable<float>("x", x1 + fx);
          FLAMEGPU->setVariable<float>("y", y1 + fy);
          FLAMEGPU->setVariable<float>("drift", sqrt(fx*fx + fy*fy));
          return flamegpu::ALIVE;
      }
      """

      class create_agents(pyflamegpu.HostFunction):
          def run(self, FLAMEGPU):
              # Fetch the desired agent count and environment width
              AGENT_COUNT = FLAMEGPU.environment.getPropertyUInt("AGENT_COUNT")
              ENV_WIDTH = FLAMEGPU.environment.getPropertyFloat("ENV_WIDTH")
              # Create agents
              t_pop = FLAMEGPU.agent("point")
              for i in range(AGENT_COUNT):
                  t = t_pop.newAgent()
                  t.setVariableFloat("x", FLAMEGPU.random.uniformFloat() * ENV_WIDTH)
                  t.setVariableFloat("y", FLAMEGPU.random.uniformFloat() * ENV_WIDTH)

      # Define some useful constants
      AGENT_COUNT = 16384
      ENV_WIDTH = int(AGENT_COUNT**(1/3))

      # Define the FLAME GPU model
      model = pyflamegpu.ModelDescription("Circles Tutorial")

      # Define a message of type MessageSpatial2D named location
      message = model.newMessageSpatial2D("location")
      # Configure the message list
      message.setMin(0, 0)
      message.setMax(ENV_WIDTH, ENV_WIDTH)
      message.setRadius(1)
      # Add extra variables to the message
      # X Y (Z) are implicit for spatial messages
      message.newVariableID("id")

      # Define an agent named point
      agent = model.newAgent("point")
      # Assign the agent some variables (ID is implicit to agents, so we don't define it ourselves)
      agent.newVariableFloat("x")
      agent.newVariableFloat("y")
      agent.newVariableFloat("drift", 0)
      # Setup the two agent functions
      out_fn = agent.newRTCFunction("output_message", output_message)
      out_fn.setMessageOutput("location")
      in_fn = agent.newRTCFunction("input_message", input_message)
      in_fn.setMessageInput("location")

      # Define environment properties
      env = model.Environment()
      env.newPropertyUInt("AGENT_COUNT", AGENT_COUNT)
      env.newPropertyFloat("ENV_WIDTH", ENV_WIDTH)
      env.newPropertyFloat("repulse", 0.05)

      # Message input depends on output
      in_fn.dependsOn(out_fn)
      # Dependency specification
      # Output is the root of our graph
      model.addExecutionRoot(out_fn)
      model.generateLayers()

      model.addInitFunction(create_agents())

      # Specify the desired StepLoggingConfig
      step_log_cfg = pyflamegpu.StepLoggingConfig(model)
      # Log every step
      step_log_cfg.setFrequency(1)
      # Include the mean of the "point" agent population's variable 'drift'
      step_log_cfg.agent("point").logMeanFloat("drift")

      # Create and init the simulation
      cuda_model = pyflamegpu.CUDASimulation(model)
      cuda_model.initialise(sys.argv)

      # Attach the logging config
      cuda_model.setStepLog(step_log_cfg)

      # Only run this block if pyflamegpu was built with visualisation support
      if pyflamegpu.VISUALISATION:
          # Create visualisation
          m_vis = cuda_model.getVisualisation()
          # Set the initial camera location and speed
          INIT_CAM = ENV_WIDTH / 2
          m_vis.setInitialCameraTarget(INIT_CAM, INIT_CAM, 0)
          m_vis.setInitialCameraLocation(INIT_CAM, INIT_CAM, ENV_WIDTH)
          m_vis.setCameraSpeed(0.01)
          m_vis.setSimulationSpeed(25)
          # Add "point" agents to the visualisation
          point_agt = m_vis.addAgent("point")
          # Location variables have names "x" and "y" so will be used by default
          point_agt.setModel(pyflamegpu.ICOSPHERE);
          point_agt.setModelScale(1/10.0);
          # Mark the environment bounds
          pen = m_vis.newPolylineSketch(1, 1, 1, 0.2)
          pen.addVertex(0, 0, 0)
          pen.addVertex(0, ENV_WIDTH, 0)
          pen.addVertex(ENV_WIDTH, ENV_WIDTH, 0)
          pen.addVertex(ENV_WIDTH, 0, 0)
          pen.addVertex(0, 0, 0)
          # Open the visualiser window
          m_vis.activate()

      # Run the simulation
      cuda_model.simulate()

      if pyflamegpu.VISUALISATION:
          # Keep the visualisation window active after the simulation has completed
          m_vis.join()

  .. code-tab:: py Python (using Python Agent API)

    from pyflamegpu import *
    import pyflamegpu.codegen
    import sys

    # Define some useful constants
    AGENT_COUNT = 16384
    ENV_WIDTH = int(AGENT_COUNT**(1/3))

    # Define the FLAME GPU model
    model = pyflamegpu.ModelDescription("Circles Tutorial")

    # Define a message of type MessageSpatial2D named location
    message = model.newMessageSpatial2D("location")
    # Configure the message list
    message.setMin(0, 0)
    message.setMax(ENV_WIDTH, ENV_WIDTH)
    message.setRadius(1)
    # Add extra variables to the message
    # X Y (Z) are implicit for spatial messages
    message.newVariableID("id")

    # Define an agent named point
    agent = model.newAgent("point")
    # Assign the agent some variables (ID is implicit to agents, so we don't define it ourselves)
    agent.newVariableFloat("x")
    agent.newVariableFloat("y")
    agent.newVariableFloat("drift", 0)

    # Define environment properties
    env = model.Environment()
    env.newPropertyUInt("AGENT_COUNT", AGENT_COUNT)
    env.newPropertyFloat("ENV_WIDTH", ENV_WIDTH)
    env.newPropertyFloat("repulse", 0.05)

    @pyflamegpu.agent_function
    def output_message(message_in: pyflamegpu.MessageNone, message_out: pyflamegpu.MessageSpatial2D):
        message_out.setVariableUInt("id", pyflamegpu.getID())
        message_out.setLocation(
            pyflamegpu.getVariableFloat("x"),
            pyflamegpu.getVariableFloat("y"))
        return pyflamegpu.ALIVE
        
    @pyflamegpu.agent_function
    def input_message(message_in: pyflamegpu.MessageSpatial2D, message_out: pyflamegpu.MessageNone):
        ID = pyflamegpu.getID()
        REPULSE_FACTOR = pyflamegpu.environment.getPropertyFloat("repulse")
        RADIUS = message_in.radius()
        fx = 0.0
        fy = 0.0
        x1 = pyflamegpu.getVariableFloat("x")
        y1 = pyflamegpu.getVariableFloat("y")
        count = 0
        for message in message_in(x1, y1):
            if message.getVariableUInt("id") != ID :
                x2 = message.getVariableFloat("x")
                y2 = message.getVariableFloat("y")
                x21 = x2 - x1
                y21 = y2 - y1
                separation = math.sqrtf(x21*x21 + y21*y21)
                if separation < RADIUS and separation > 0 :
                    k = math.sinf((separation / RADIUS)*3.141*-2)*REPULSE_FACTOR
                    # Normalise without recalculating separation
                    x21 /= separation
                    y21 /= separation
                    fx += k * x21
                    fy += k * y21
                    count += 1
        fx /= count if count > 0 else 1
        fy /= count if count > 0 else 1
        pyflamegpu.setVariableFloat("x", x1 + fx)
        pyflamegpu.setVariableFloat("y", y1 + fy)
        pyflamegpu.setVariableFloat("drift", math.sqrtf(fx*fx + fy*fy))
        return pyflamegpu.ALIVE
        
    # translate the agent functions from Python to C++
    output_func_translated = pyflamegpu.codegen.translate(output_message)
    input_func_translated = pyflamegpu.codegen.translate(input_message)
    # Setup the two agent functions
    out_fn = agent.newRTCFunction("output_message", output_func_translated)
    out_fn.setMessageOutput("location")
    in_fn = agent.newRTCFunction("input_message", input_func_translated)
    in_fn.setMessageInput("location")

    # Message input depends on output
    in_fn.dependsOn(out_fn)
    # Dependency specification
    # Output is the root of our graph
    model.addExecutionRoot(out_fn)
    model.generateLayers()

    class create_agents(pyflamegpu.HostFunction):
        def run(self, FLAMEGPU):
            # Fetch the desired agent count and environment width
            AGENT_COUNT = FLAMEGPU.environment.getPropertyUInt("AGENT_COUNT")
            ENV_WIDTH = FLAMEGPU.environment.getPropertyFloat("ENV_WIDTH")
            # Create agents
            t_pop = FLAMEGPU.agent("point")
            for i in range(AGENT_COUNT):
                t = t_pop.newAgent()
                t.setVariableFloat("x", FLAMEGPU.random.uniformFloat() * ENV_WIDTH)
                t.setVariableFloat("y", FLAMEGPU.random.uniformFloat() * ENV_WIDTH)
                
    model.addInitFunction(create_agents())

    # Specify the desired StepLoggingConfig
    step_log_cfg = pyflamegpu.StepLoggingConfig(model)
    # Log every step
    step_log_cfg.setFrequency(1)
    # Include the mean of the "point" agent population's variable 'drift'
    step_log_cfg.agent("point").logMeanFloat("drift")

    # Create and init the simulation
    cuda_model = pyflamegpu.CUDASimulation(model)
    cuda_model.initialise(sys.argv)

    # Attach the logging config
    cuda_model.setStepLog(step_log_cfg)

    # Only run this block if pyflamegpu was built with visualisation support
    if pyflamegpu.VISUALISATION:
        # Create visualisation
        m_vis = cuda_model.getVisualisation()
        # Set the initial camera location and speed
        INIT_CAM = ENV_WIDTH / 2
        m_vis.setInitialCameraTarget(INIT_CAM, INIT_CAM, 0)
        m_vis.setInitialCameraLocation(INIT_CAM, INIT_CAM, ENV_WIDTH)
        m_vis.setCameraSpeed(0.01)
        m_vis.setSimulationSpeed(25)
        # Add "point" agents to the visualisation
        point_agt = m_vis.addAgent("point")
        # Location variables have names "x" and "y" so will be used by default
        point_agt.setModel(pyflamegpu.ICOSPHERE);
        point_agt.setModelScale(1/10.0);
        # Mark the environment bounds
        pen = m_vis.newPolylineSketch(1, 1, 1, 0.2)
        pen.addVertex(0, 0, 0)
        pen.addVertex(0, ENV_WIDTH, 0)
        pen.addVertex(ENV_WIDTH, ENV_WIDTH, 0)
        pen.addVertex(ENV_WIDTH, 0, 0)
        pen.addVertex(0, 0, 0)
        # Open the visualiser window
        m_vis.activate()

    # Run the simulation
    cuda_model.simulate()

    if pyflamegpu.VISUALISATION:
        # Keep the visualisation window active after the simulation has completed
        m_vis.join()

Tutorial: Graph Network Model
-----------------------------

Configuring CMake
^^^^^^^^^^^^^^^^^
This tutorial assumes you are familiar with the example templates as used in the :ref:`Circles Model<Circles Model>`, but in this case the use of visualisation is 
essential to understanding the model behaviour. CMake must therefore be configured with visualisation support.

A more detailed guide regarding building FLAME GPU 2 from source can be found :ref:`here<q-compiling flamegpu>`.

.. tabs::

  .. code-tab:: sh Linux (.sh)
  
    # Create the build directory and change into it
    mkdir -p build && cd build

    # Configure CMake from the command line passing configure-time options. 
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_ARCHITECTURES=75 -DFLAMEGPU_VISUALISATION=1

.. note::
  
  ``-DCMAKE_CUDA_ARCHITECTURES=75``, configures the build for Turing GPUs of ``SM_75``, you may wish to change this to match your available GPU. Omitting it entirely will produce a larger binary suitable for all current architectures, which essentially multiplies the compile time by the number of architectures. In general, GPUs of newer architecture than specified will run but be limited to the features of the earlier architecture that the program was compiled for.

The build files for the project should now be created inside the directory ``build``.

Opening the Project
^^^^^^^^^^^^^^^^^^^ 

Linux C++ users should now open ``src/main.cu`` in their preferred text editor or IDE.

Windows C++ users should now open ``build/example.vcxproj`` with Visual Studio, and subsequently open ``main.cu`` via the solution explorer panel.

.. tabs::

  .. code-tab:: cpp C++

	#include <filesystem>
	#include <iostream>
	#include <fstream>
	#include "flamegpu/flamegpu.h"
	#include "flamegpu/visualiser/visualiser_api.h"

Introducing The Graph Network Model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The graph network model illustrates the implementation of a network model within the FLAME GPU 2 framework. It demonstrates the concepts underlying published 
network models such XXXXX (for roads) and XXXXX (for railways). 

The network consists of one central and three peripheral railway stations ('nodes' or 'verticies' of the graph), linked by railway lines ('links' or 'edges' forming a graph). 
Trains run on the network according to a pre-planned timetable held in an XML configuration file. This demonstrates the use of an external configuration file, 
and allows exploring different timetables without recompiling the model. 

Model Description
^^^^^^^^^^^^^^^^^

As for the :ref:`Circles Model<Circles Model>` the first step to creating a FLAME GPU model is to define the model, this begins by creating 
a :class:`ModelDescription<flamegpu::ModelDescription>`. The :class:`ModelDescription<flamegpu::ModelDescription>` is defined at the start of 
program flow.

Before the model description, we define define some variables used to keep track of time enabling us to see how long the similation takes to run.

.. tabs::

  .. code-tab:: cpp C++

    ...
    // All code examples are assumed to be implemented within a main function.
    // E.g. int main(int argc, const char *argv[])
  
    // Enable keeping track of time
    time_t now = time(NULL);
    struct tm *timenow;
    timenow = gmtime(&now);
    printf("Simulation start: %s", asctime(timenow));
    
    // Filenanme to be used for logging output
    char filename[60];
    
    // Define the FLAME GPU model
    flamegpu::ModelDescription model("Graph example");
    ...


Environment Description
^^^^^^^^^^^^^^^^^^^^^^^

This follows a similar pattern to that used in the :ref:`Circles Model<Circles Model>` fetching the :class:`EnvironmentDescription<flamegpu::EnvironmentDescription>` 
from the :class:`ModelDescription<flamegpu::ModelDescription>` using :func:`Environment()<flamegpu::ModelDescription::Environment>`.

Properties are added using :func:`newProperty()<template<typename T> void flamegpu::EnvironmentDescription::newProperty(const std::string &, T, bool)>` with 
an initial value specified as the second argument.

The environment for the graph model holds information about the visualisation and its camera angle, logging, and the simulation timestep. The maximum number of trains 
to be modelled is stored to facilitate colour coding the trains to differentiate them as they run in the visualisation. 

.. tabs::

  .. code-tab:: cpp C++

    ...       
	// global environment variables
	flamegpu::EnvironmentDescription env = model.Environment();
	env.newProperty<int>("visualisation", 0);              //0 = off, 1 = on
	env.newProperty<int, 6>("camera", {0, 0, 0, 0, 0, 0}); // x,y,z camera target, x,y,z camera location
	env.newProperty<int>("logging", 0);                    //0 = off, 1 = on
	env.newProperty<float>("timestep", 1);                 //Time step of the simulation in seconds
	env.newProperty<float>("maxtrains", (float)100);       //Maximum number of trains in the simulation, to configure visualisation
    ...

Graph Network Description
^^^^^^^^^^^^^^^^^^^^^^^^^

The modelled network graph is made up of railway stations ('nodes' or 'verticies') and railway lines ('links' or 'edges'). 

The railway lines each have an origin and destination station, and a linespeed (maximum speed) property. The stations have properties including their location in x-y space, 
and a dwelltime in seconds needed for passengers to board and alight when trains call there. Provision is made for additional properties to indicate how factors 
such as station capacity and station type (terminal or through station) might be included in the model, but these are not explored in this tutorial. 

The properties of the graph must be defined in the program code, but are then populated using a JSON file read in the :ref:`initialisation function<Graph Model Initialisation>`. 

The :class:`EnvironmentDirectedGraphDescription<flamegpu::EnvironmentDirectedGraphDescription>` is attached to the model environment using 
:func:`newDirectedGraph()<flamegpu::ModelDescription::Environment::newDirectedGraph>`.

.. tabs::

  .. code-tab:: cpp C++

    ... 
    flamegpu::EnvironmentDirectedGraphDescription graph = model.Environment().newDirectedGraph("graph");
    graph.newVertexProperty<float>("x");       // Location - x
    graph.newVertexProperty<float>("y");       // Location - y
    graph.newVertexProperty<int>("type");      // 0 = terminal station, 1 = through station
    graph.newVertexProperty<int>("capacity");  // Number of trains that can be accomodated
    graph.newVertexProperty<int>("dwelltime"); //Minimum time allocated for boarding and alighting at each station
    graph.newEdgeProperty<float>("linespeed");
    ...
    
  
Agent Description
^^^^^^^^^^^^^^^^^

Train agents are added to the model and the variables each train holds are assigned. These include routing and timing information which will be assigned to the train 
at the start of running the model, and variables that store working information during movement on the network. Efficiency of calculation is increased by 
calculating only once for each leg of the train journey the direction of motion and step size per timestep in x-y space rather than recalculating this every timestep.

.. tabs::

  .. code-tab:: cpp C++

	... 
	//Create agent description
	flamegpu::AgentDescription train = model.newAgent("train");
	train.newVariable<float>("x");          // Locaiton - x
	train.newVariable<float>("y");          // Location - y
	train.newVariable<float>("z");          // Location - z
	train.newVariable<float>("trainviz");   // Automatically assigned to enable colour differentiation between trains
	train.newVariable<int>("target");       // The node (station) the train is heading towards. -1 indicates not yet on journey. -2 indicates journey completed.
	train.newVariable<int>("starttime");    // Start time in seconds, e.g. relative to midnight
	train.newVariable<int, 50>("route");    // An array of stations to call at. Allow for 50 stops
	train.newVariable<int, 50>("timing");   // An array of timings indicating how long each leg of the journey is scheduled to take (incremental, not cumulative)
	train.newVariable<float>("maxSpeed");   // Train capabillity maximum speed
	train.newVariable<float>("dx");         // Step size in x on current edge
	train.newVariable<float>("dy");         // Step size in y on current edge
	train.newVariable<float>("dl");         // Step size in l on current edge
	train.newVariable<float>("remainingL"); // Count down to reaching edge destination
	train.newVariable<int>("journeyIndex"); // Count down to reaching edge destination
	train.newVariable<int>("dwelltime");    // Count down dwell period in station
    ...
    

Agent Function Description
^^^^^^^^^^^^^^^^^^^^^^^^^^

The core agent function moves the train around the network according to the route information already held by the trains. It combines information about the 
network (linespeed limits) and the trains (maximum speed capability) to ensure the train movement is within the capabilities of both the vehicle and the infrastructure. 
Since this check is used in two places within the agent function a separate device function is defined to hold this code. 

.. tabs::

  .. code-tab:: cpp C++

    ...
    //Ensure speed is within the capability of both train and infrastructgure
    FLAMEGPU_DEVICE_FUNCTION float myFun(float linespeed, float maxspeed, float dt){
		float velocity, dl;
		velocity = min(linespeed, maxspeed);
		dl = velocity * dt;
		return dl;
	}
	...

The main agent function ``move_trains`` can then be defined. This begins with an initialisation routine that will only run in the first modelling timestep. 
This is here rather than in an initialisation function as it requires access to the graph data which is only available in device functions, not host functions. 
A countdown timer ``dwelltime`` is set when trains arrive at startions and they wait for this to reach zero before continuing their journey. The ``starttime`` 
enables trains to begin their journey at a pre-planned time after the start of the simulation. For each leg of the journey the train takes location information 
from the graph to define its origin (source) and destination (target). The number of movement increments needed to reach the remaining distance to the target 
is used to determine when the graph should be checked again for the next leg of the journey. The journey terminates when the next stage of the route indicates 
vertex index -2, a special value used for this purpose which does not correspond to any real vertex in the graph. 

.. tabs::

  .. code-tab:: cpp C++

    ... 
	//Agent function to move trains on the network
	FLAMEGPU_AGENT_FUNCTION(move_trains, flamegpu::MessageNone, flamegpu::MessageNone) {
	  // move agents in time steps - a more sophisticated model would account for acceleration and braking periods
	  
	  flamegpu::DeviceEnvironmentDirectedGraph graph = FLAMEGPU->environment.getDirectedGraph("graph");
	  int source, target;
	  float Dx, Dy, dl, vel, remainingL, timestep;
	  
	  timestep = FLAMEGPU->environment.getProperty<float>("timestep");
	  
	  //Initialise train positions
	  if(FLAMEGPU->getStepCounter() == 0 && FLAMEGPU->getVariable<int, 50>("route", 0) != -2){
		  source = FLAMEGPU->getVariable<int, 50>("route", 0); 
		  FLAMEGPU->setVariable<float>("x", graph.getVertexProperty<float>("x", source));
		  FLAMEGPU->setVariable<float>("y", graph.getVertexProperty<float>("y", source));
		  FLAMEGPU->setVariable<float>("z", graph.getVertexProperty<float>("z", source));
	  }
	  
	  //Trains start at an allocated time. A more sophisticated model would use clock times not simulation timesteps
	  if(FLAMEGPU->getStepCounter() >= FLAMEGPU->getVariable<int>("starttime")){
		
		//If the dwelltime counter is set, decrement the counter but don't move the train yet
		if(FLAMEGPU->getVariable<int>("dwelltime") > 0){
			FLAMEGPU->setVariable<int>("dwelltime", FLAMEGPU->getVariable<int>("dwelltime") - 1);
		  
		}else{      
			//Prior to starting their journey place the agents at the first node listed in their route
			//A more sophisticated model would include the journey to/from a depot
			if(FLAMEGPU->getVariable<int>("journeyIndex") == 0 && FLAMEGPU->getVariable<int, 50>("route", 0) != -2){
				FLAMEGPU->setVariable<int>("journeyIndex", 1); // Effectively this is the 'next stop' or next node
				source = FLAMEGPU->getVariable<int, 50>("route", 0);
				target = FLAMEGPU->getVariable<int, 50>("route", 1);
			
				FLAMEGPU->setVariable<float>("x", graph.getVertexProperty<float>("x", source));
				FLAMEGPU->setVariable<float>("y", graph.getVertexProperty<float>("y", source));
			
				//Set trajectory based on the source to target geometry (Dx, Dy)
				//These are really edge properties but are more easily handled in the train agent
				Dx = graph.getVertexProperty<float>("x", target) - graph.getVertexProperty<float>("x", source);
				Dy = graph.getVertexProperty<float>("y", target) - graph.getVertexProperty<float>("y", source);
				remainingL = sqrt(Dx*Dx + Dy*Dy);
				FLAMEGPU->setVariable<float>("remainingL", remainingL);
				
				//Update the incremental steps according to the speed
				unsigned int edge_index = graph.getEdgeIndex(source, target);
				dl = myFun(graph.getEdgeProperty<float>("linespeed", edge_index), FLAMEGPU->getVariable<float>("maxSpeed"), timestep);
				
				//dx and dy scale by the same ratio as remainingL:dl, so no need for use of trig here
				FLAMEGPU->setVariable<float>("dx", Dx * dl / remainingL);
				FLAMEGPU->setVariable<float>("dy", Dy * dl / remainingL);
				FLAMEGPU->setVariable<float>("dl", dl);
		
			}else if(FLAMEGPU->getVariable<float>("remainingL") > 0){
				//Train is on the move - increment its progress and check if it's reaching its target node
				
				FLAMEGPU->setVariable<float>("remainingL", FLAMEGPU->getVariable<float>("remainingL") - FLAMEGPU->getVariable<float>("dl"));
				FLAMEGPU->setVariable<float>("x", FLAMEGPU->getVariable<float>("x") + FLAMEGPU->getVariable<float>("dx"));
				FLAMEGPU->setVariable<float>("y", FLAMEGPU->getVariable<float>("y") + FLAMEGPU->getVariable<float>("dy"));
				
				if(FLAMEGPU->getVariable<float>("remainingL") < FLAMEGPU->getVariable<float>("dl")){
					//This train will reach its next station within the next time step - update route information now
					source = FLAMEGPU->getVariable<int, 50>("route", FLAMEGPU->getVariable<int>("journeyIndex"));
					FLAMEGPU->setVariable<int>("journeyIndex", FLAMEGPU->getVariable<int>("journeyIndex") + 1);
					target = FLAMEGPU->getVariable<int, 50>("route", FLAMEGPU->getVariable<int>("journeyIndex"));
				  
					if(target == -2 || source == -2){
						//You have reached your destination.
						//A more sophisticated model would move the train to its next service here
					
					}else{
						//Set the dwell counter to pause the train in the station
						FLAMEGPU->setVariable<int>("dwelltime", graph.getVertexProperty<int>("dwelltime", target));
					
						//Set up for the next leg of the journey - follows steps used to initialise the first step of the journey
						FLAMEGPU->setVariable<float>("x", graph.getVertexProperty<float>("x", source));
						FLAMEGPU->setVariable<float>("y", graph.getVertexProperty<float>("y", source));
						Dx = graph.getVertexProperty<float>("x", target) - graph.getVertexProperty<float>("x", source);
						Dy = graph.getVertexProperty<float>("y", target) - graph.getVertexProperty<float>("y", source);
						remainingL = sqrt(Dx*Dx + Dy*Dy);
						FLAMEGPU->setVariable<float>("remainingL", remainingL);
						unsigned int edge_index = graph.getEdgeIndex(source, target);
						dl = myFun(graph.getEdgeProperty<float>("linespeed", edge_index), FLAMEGPU->getVariable<float>("maxSpeed"), timestep);
						FLAMEGPU->setVariable<float>("dx", Dx * dl / remainingL);
						FLAMEGPU->setVariable<float>("dy", Dy * dl / remainingL);
						FLAMEGPU->setVariable<float>("dl", dl);
					  }
					}
				}
			}
		}
		return flamegpu::ALIVE;
	}
	...

.. _Graph Model Initialisation:

Initialisation Functions
^^^^^^^^^^^^^^^^^^^^^^^^

Two initialisation functions are used, one for the trains, and one for the graph network. In both cases the data to initialise the agents could be hard coded here, 
but we instead use data from external configuration files so it can be modified without recompiling the program. 

For the trains initialisation populates agent variables that are not set from the external configuration file. 

.. tabs::

  .. code-tab:: cpp C++

	... 
	//Initialisation of the trains
	FLAMEGPU_INIT_FUNCTION(InitTrains) {
	  int i = 0;
	  
	  printf("Creating train agents\n");
	  
	  // Get population of train agents which will have been loaded from an external configuration file
	  flamegpu::HostAgentAPI t_pop2 = FLAMEGPU->agent("train");
	  
	  // Get DeviceAgentVector to the train population
	  flamegpu::DeviceAgentVector t_vector = t_pop2.getPopulationData();
	  // Set all trains's to origin
	  for(auto t : t_vector){
		t.setVariable<int>("target", -1);
		t.setVariable<int>("journeyIndex", 0);
		t.setVariable<float>("remainingL", 0.0);
		t.setVariable<float>("x", 0.0);
		t.setVariable<float>("y", 0.0);
		t.setVariable<float>("z", 0.0);
		t.setVariable<float>("trainviz", (float)i);
		i++;
	  }
	  printf("Created %i train agents\n", i);
	}
	...

For the graph network the initialisation reads in an external JSON file defining the layout. 

.. tabs::

  .. code-tab:: cpp C++

	... 
	FLAMEGPU_INIT_FUNCTION(InitGraph){
		flamegpu::HostEnvironmentDirectedGraph graph = FLAMEGPU->environment.getDirectedGraph("graph");

		graph.importGraph("../src/graph.json");
 
	}
	...

For our example the following JSON file defines the network layout and properties of the nodes and edges. Units used should be self-consistent to ensure speeds and distances
are physically sensible (in this simple example the time unit is the simulation timestep rather than seconds). This file needs to be saved using the name ``graph.json`` 
within your source code folder (i.e. with a name matching the ``importGraph`` function shown above). 


.. tabs::

  .. code-tab:: json JSON

	{
	"nodes": [
        {
            "id": "1",
            "capacity": 500,
            "dwelltime": 600,
            "type": 0,
            "x": 650,
            "y": 50,
	    "z": 0
        },
        {
            "id": "2",
            "capacity": 500,
            "dwelltime": 600,
            "type": 0,
            "x": 500,
            "y": 400,
	    "z": 0
        },
        {
            "id": "3",
            "capacity": 500,
            "dwelltime": 400,
            "type": 0,
            "x": 750,
            "y": 900,
	    "z": 0
        },
        {
                "id": "4",
            "capacity": 500,
            "dwelltime": 300,
            "type": 0,
            "x": 50,
            "y": 750,
	    "z": 0
        }],
	"links": [
        {
                "source": "1",
                "target": "2",
                "linespeed": 50
        },
        {
                "source": "2",
                "target": "3",
                "linespeed": 50
        },
        {
                "source": "2",
                "target": "4",
                "linespeed": 50
        }]
	}



Model execution order and logging set-up
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The configuration steps below are included in the code to assemble the elements we have created. The initialisation functions are added to the model, 
with the first (and only) function to run on the agents added as the ExecutitionRoot. Logging is configured to save environment data at exit. Further configuration of 
logging for agent data is given in the complete program listing. 

.. tabs::

  .. code-tab:: cpp C++

	... 
	  //Setup execution order
	  
	  //Graph must be initialised before trains as the trains use graph properties in their initialisation
	  model.addInitFunction(InitGraph);
	  model.addInitFunction(InitTrains);

	  // Setup the move_trains function
	  flamegpu::AgentFunctionDescription train_fn = train.newFunction("move_trains", move_trains);
	  
	  // Identify the root of execution
	  model.addExecutionRoot(train_fn);
	  
	  // Build the model
	  model.generateLayers();
	  
	  //Convert model to a simulation
	  flamegpu::CUDASimulation simulation(model, argc, argv);
	  
	  // Specify the desired Exit LoggingConfig
	  flamegpu::LoggingConfig exit_log_cfg(model);
	  exit_log_cfg.logEnvironment("camera");
	  exit_log_cfg.logEnvironment("visualisation");
	  exit_log_cfg.logEnvironment("logging");
	  simulation.setExitLog(exit_log_cfg);
	  ...
    
Model runtime configuration and train routes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

At runtime the model reads an XML configuration file which contains train agent properties including their routes and timing information. This needs to be saved locally so you can 
read it at run time, for example, saving as ``config.xml`` in your source code directory. 

Trains undertake routes around the network, with provision here for up to 50 station calls on each route. In the example code trains run at the least of the maximum  
line speed or the maximum train speed, but a timing entry is provided through which more control of timetabling for each leg of the journey could be developed. 
Trains start at the location of the first station on their route, with unused trains stored at a 'depot' location at position 0,0. Each train has a ``starttime`` 
at which it begins its journey to avoid them all beginning at the start of the simulation. In this simple example the time unit is the simulation timestep rather 
than seconds. When trains pass through stations they pause for the dwelltime specified in the graph for that station location. 

.. tabs::

  .. code-tab:: xml XML

	<states>
        <itno>100</itno>
        <config>
                <simulation>
                        <input_file></input_file>
                        <steps>25000</steps>
                        <verbosity>1</verbosity>
                        <console_mode>false</console_mode>
                </simulation>
                <cuda>
                        <device_id>0</device_id>
                        <inLayerConcurrency>true</inLayerConcurrency>
                </cuda>
        </config>
        <environment>
                <timestep>0.01</timestep>
                <visualisation>1</visualisation>
                <logging>1</logging>
                <camera>100,500,0,100,500, 1000</camera>
		<maxtrains>2</maxtrains>
        </environment>
        <macro_environment/>
        <xagent>
                <name>train</name>
                <state>default</state>
                <_id type="j">1</_id>
                <route type="i">1,2,1,3,1,0,1,2,1,3,1,2,-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</route>
                <starttime type="i">3500</starttime>
                <timing type="i">45,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</timing>
                <maxSpeed type="f">40</maxSpeed>
        </xagent>
        <xagent>
                <name>train</name>
                <state>default</state>
                <_id>2</_id>
                <route>0,1,3,1,0,-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</route>
                <starttime>0</starttime>
                <timing>0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</timing>
                <maxSpeed>20</maxSpeed>
        </xagent>
        <xagent>
                <name>train</name>
                <state>default</state>
                <_id>3</_id>
                <route>-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</route>
                <starttime>0</starttime>
                <timing>0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</timing>
                <maxSpeed>50</maxSpeed>
        </xagent>
        <xagent>
                <name>train</name>
                <state>default</state>
                <_id>4</_id>
                <route>-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</route>
                <starttime>0</starttime>
                <timing>0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</timing>
                <maxSpeed>60</maxSpeed>
        </xagent>
        <xagent>
                <name>train</name>
                <state>default</state>
                <_id>5</_id>
                <route>-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</route>
                <starttime>0</starttime>
                <timing>0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0</timing>
                <maxSpeed>70</maxSpeed>
        </xagent>
	</states>
	<!-- timestep - currently set to make visualisation run well. Needs to be 1 or 2s, and use framerate (CameraSpeed) to adjust the visualisation -->
	<!-- Camera target and camera location {x,y,z,x,y,z} -->
	<!-- visualisation - 0 = off, 1 = on -->
	<!-- logging - 0 = off, 1 = environment, 2 = environment and agents -->
	<!-- maxtrains - set to the number of trains that will be colour differentiable in the visualisation -->



Visualisation
^^^^^^^^^^^^^

The visualisation is tailored to the x-y space over which the stations are located. Here, that environment bounds for the visualisation are hard-coded but they 
could be read from environment variables defined in the XML configuration file using the same approach used for the camera location if it was important to vary 
these between runs. 

.. tabs::

  .. code-tab:: cpp C++

	... 
	  // Create visualisation if enabled
	#ifdef FLAMEGPU_VISUALISATION
	  flamegpu::visualiser::ModelVis visualiser = simulation.getVisualisation();
	  
	  if(simulation.getEnvironmentProperty<int>("visualisation") >=1){
		visualiser.setInitialCameraTarget(simulation.getEnvironmentProperty<int, 6>("camera",0),
						  simulation.getEnvironmentProperty<int, 6>("camera",1), simulation.getEnvironmentProperty<int, 6>("camera",2));
		visualiser.setInitialCameraLocation(simulation.getEnvironmentProperty<int, 6>("camera",3),
						simulation.getEnvironmentProperty<int, 6>("camera",4), simulation.getEnvironmentProperty<int, 6>("camera",5));
		visualiser.setCameraSpeed(0.01f);
		
		// Add "train" agents to the visualisation
		flamegpu::visualiser::AgentVis train_agt = visualiser.addAgent("train");
		// Location variables have names "x" and "y" so will be used by default
		train_agt.setModel(flamegpu::visualiser::Stock::Models::CUBE);
		train_agt.setModelScale(10, 10, 10);
		train_agt.setXVariable("x");
		train_agt.setYVariable("y");
		train_agt.setZVariable("z");
		//A more sophisticated model would automatically adapt here for the number of trains
		train_agt.setColor(flamegpu::visualiser::HSVInterpolation::GREENRED("trainviz", 0.0f, simulation.getEnvironmentProperty<float>("maxtrains")));
		
		//Plot location of the graph verticies and edges
		flamegpu::visualiser::EnvironmentGraphVis g = visualiser.addGraph("graph");
		g.setColor(flamegpu::visualiser::Color{"#ff0000"});
		g.setXVertexProperty("x");
		g.setYVertexProperty("y");
		g.setZVertexProperty("z");
		
		// Mark the environment bounds
		flamegpu::visualiser::LineVis pen = visualiser.newPolylineSketch(1, 1, 1, 1); //0.2f
		pen.addVertex(0, 0, 0);
		pen.addVertex(0, 1000, 0);
		pen.addVertex(1000, 1000, 0);
		pen.addVertex(1000, 0, 0);
		pen.addVertex(0, 0, 0);
		
		// Open the visualiser window
		visualiser.activate();
	  }
	#endif
	...

Compiling and running the Simulation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To run the simulation the location of the XML configuration file must be given on the command line. It is assumed that the JSON network definition file is in the 
same folder as the source code file. 

If compiling and running from the build directory, and with the ``config.xml`` file and ``graph.json`` file stored in the source directory, the commands on linux are:

.. tabs::

  .. code-tab:: cpp C++

	cmake --build . --target flamegpu template -j 4

	./bin/Release/template -i ../src/config.xml


Complete Tutorial Code
^^^^^^^^^^^^^^^^^^^^^^

If you have followed the complete tutorial, you should now understand the flow of the full model code given here. Note that this includes some additional code to configure 
logging from the model, and to manage the visualisation window after the simulation finishes.

.. tabs::

  .. code-tab:: cpp C++

	#include <filesystem>
	#include <iostream>
	#include <fstream>
	#include "flamegpu/flamegpu.h"
	#include "flamegpu/visualiser/visualiser_api.h"

	//Ensure speed is within the capability of both train and infrastructgure
	FLAMEGPU_DEVICE_FUNCTION float myFun(float linespeed, float maxspeed, float dt){
	  float velocity, dl;
	  velocity = min(linespeed, maxspeed);
	  dl = velocity * dt;
	  return dl;
	}

	//Agent function to move trains on the network
	FLAMEGPU_AGENT_FUNCTION(move_trains, flamegpu::MessageNone, flamegpu::MessageNone) {
	  // move agents in time steps - a more sophisticated model would account for acceleration and braking periods
	  
	  flamegpu::DeviceEnvironmentDirectedGraph graph = FLAMEGPU->environment.getDirectedGraph("graph");
	  int source, target;
	  float Dx, Dy, dl, vel, remainingL, timestep;
	  
	  timestep = FLAMEGPU->environment.getProperty<float>("timestep");
	  
	  //Initialise train positions
	  if(FLAMEGPU->getStepCounter() == 0 && FLAMEGPU->getVariable<int, 50>("route", 0) != -2){
		  source = FLAMEGPU->getVariable<int, 50>("route", 0); 
		  FLAMEGPU->setVariable<float>("x", graph.getVertexProperty<float>("x", source));
		  FLAMEGPU->setVariable<float>("y", graph.getVertexProperty<float>("y", source));
		  FLAMEGPU->setVariable<float>("z", graph.getVertexProperty<float>("z", source));
	  }
	  
	  //Trains start at an allocated time. A more sophisticated model would use clock times not simulation timesteps
	  if(FLAMEGPU->getStepCounter() >= FLAMEGPU->getVariable<int>("starttime")){
		
		//If the dwelltime counter is set, decrement the counter but don't move the train yet
		if(FLAMEGPU->getVariable<int>("dwelltime") > 0){
			FLAMEGPU->setVariable<int>("dwelltime", FLAMEGPU->getVariable<int>("dwelltime") - 1);
		  
		}else{      
			//Prior to starting their journey place the agents at the first node listed in their route
			//A more sophisticated model would include the journey to/from a depot
			if(FLAMEGPU->getVariable<int>("journeyIndex") == 0 && FLAMEGPU->getVariable<int, 50>("route", 0) != -2){
				FLAMEGPU->setVariable<int>("journeyIndex", 1); // Effectively this is the 'next stop' or next node
				source = FLAMEGPU->getVariable<int, 50>("route", 0);
				target = FLAMEGPU->getVariable<int, 50>("route", 1);
			
				FLAMEGPU->setVariable<float>("x", graph.getVertexProperty<float>("x", source));
				FLAMEGPU->setVariable<float>("y", graph.getVertexProperty<float>("y", source));
			
				//Set trajectory based on the source to target geometry (Dx, Dy)
				//These are really edge properties but are more easily handled in the train agent
				Dx = graph.getVertexProperty<float>("x", target) - graph.getVertexProperty<float>("x", source);
				Dy = graph.getVertexProperty<float>("y", target) - graph.getVertexProperty<float>("y", source);
				remainingL = sqrt(Dx*Dx + Dy*Dy);
				FLAMEGPU->setVariable<float>("remainingL", remainingL);
				
				//Update the incremental steps according to the speed
				unsigned int edge_index = graph.getEdgeIndex(source, target);
				dl = myFun(graph.getEdgeProperty<float>("linespeed", edge_index), FLAMEGPU->getVariable<float>("maxSpeed"), timestep);
				
				//dx and dy scale by the same ratio as remainingL:dl, so no need for use of trig here
				FLAMEGPU->setVariable<float>("dx", Dx * dl / remainingL);
				FLAMEGPU->setVariable<float>("dy", Dy * dl / remainingL);
				FLAMEGPU->setVariable<float>("dl", dl);
		
			}else if(FLAMEGPU->getVariable<float>("remainingL") > 0){
				//Train is on the move - increment its progress and check if it's reaching its target node
				
				FLAMEGPU->setVariable<float>("remainingL", FLAMEGPU->getVariable<float>("remainingL") - FLAMEGPU->getVariable<float>("dl"));
				FLAMEGPU->setVariable<float>("x", FLAMEGPU->getVariable<float>("x") + FLAMEGPU->getVariable<float>("dx"));
				FLAMEGPU->setVariable<float>("y", FLAMEGPU->getVariable<float>("y") + FLAMEGPU->getVariable<float>("dy"));
				
				if(FLAMEGPU->getVariable<float>("remainingL") < FLAMEGPU->getVariable<float>("dl")){
					//This train will reach its next station within the next time step - update route information now
					source = FLAMEGPU->getVariable<int, 50>("route", FLAMEGPU->getVariable<int>("journeyIndex"));
					FLAMEGPU->setVariable<int>("journeyIndex", FLAMEGPU->getVariable<int>("journeyIndex") + 1);
					target = FLAMEGPU->getVariable<int, 50>("route", FLAMEGPU->getVariable<int>("journeyIndex"));
				  
					if(target == -2 || source == -2){
						//You have reached your destination.
						//A more sophisticated model would move the train to its next service here
					
					}else{
						//Set the dwell counter to pause the train in the station
						FLAMEGPU->setVariable<int>("dwelltime", graph.getVertexProperty<int>("dwelltime", target));
					
						//Set up for the next leg of the journey - follows steps used to initialise the first step of the journey
						FLAMEGPU->setVariable<float>("x", graph.getVertexProperty<float>("x", source));
						FLAMEGPU->setVariable<float>("y", graph.getVertexProperty<float>("y", source));
						Dx = graph.getVertexProperty<float>("x", target) - graph.getVertexProperty<float>("x", source);
						Dy = graph.getVertexProperty<float>("y", target) - graph.getVertexProperty<float>("y", source);
						remainingL = sqrt(Dx*Dx + Dy*Dy);
						FLAMEGPU->setVariable<float>("remainingL", remainingL);
						unsigned int edge_index = graph.getEdgeIndex(source, target);
						dl = myFun(graph.getEdgeProperty<float>("linespeed", edge_index), FLAMEGPU->getVariable<float>("maxSpeed"), timestep);
						FLAMEGPU->setVariable<float>("dx", Dx * dl / remainingL);
						FLAMEGPU->setVariable<float>("dy", Dy * dl / remainingL);
						FLAMEGPU->setVariable<float>("dl", dl);
					}
				}
			}
		}
	 }
	return flamegpu::ALIVE;
	}

	//Initialisation of the trains
	FLAMEGPU_INIT_FUNCTION(InitTrains) {
	  int i = 0;
	  
	  printf("Creating train agents\n");
	  
	  // Get population of train agents which will have been loaded from an external configuration file
	  flamegpu::HostAgentAPI t_pop2 = FLAMEGPU->agent("train");
	  
	  // Get DeviceAgentVector to the train population
	  flamegpu::DeviceAgentVector t_vector = t_pop2.getPopulationData();
	  // Set all trains's to origin
	  for(auto t : t_vector){
		t.setVariable<int>("target", -1);
		t.setVariable<int>("journeyIndex", 0);
		t.setVariable<float>("remainingL", 0.0);
		t.setVariable<float>("x", 0.0);
		t.setVariable<float>("y", 0.0);
		t.setVariable<float>("z", 0.0);
		t.setVariable<float>("trainviz", (float)i);
		i++;
	  }
	  printf("Created %i train agents\n", i);
	}

	//Initialisation of the graph network
	FLAMEGPU_INIT_FUNCTION(InitGraph){
	  flamegpu::HostEnvironmentDirectedGraph graph = FLAMEGPU->environment.getDirectedGraph("graph");
	  graph.importGraph("../src/graph.json");
	}

	//Main function
	int main(int argc, const char ** argv) {
	  
	  // Enable keeping track of time
	  time_t now = time(NULL);
	  struct tm *timenow;
	  timenow = gmtime(&now);
	  printf("Simulation start: %s", asctime(timenow));
	  
	  // Filenanme to be used for logging output
	  char filename[60];
	  
	  // Define the FLAME GPU model
	  flamegpu::ModelDescription model("Graph example");
	  
	  
	  // global environment variables
	  flamegpu::EnvironmentDescription env = model.Environment();
	  env.newProperty<int>("visualisation", 0);              //0 = off, 1 = on
	  env.newProperty<int, 6>("camera", {0, 0, 0, 0, 0, 0}); // x,y,z camera target, x,y,z camera location
	  env.newProperty<int>("logging", 0);                    //0 = off, 1 = on
	  env.newProperty<float>("timestep", 1);                 //Time step of the simulation in seconds
	  env.newProperty<float>("maxtrains", (float)100);       //Maximum number of trains in the simulation, to configure visualisation
	  
	  
	  // Graph definition
	  flamegpu::EnvironmentDirectedGraphDescription graph = model.Environment().newDirectedGraph("graph");
	  graph.newVertexProperty<float>("x");       // Location - x
	  graph.newVertexProperty<float>("y");       // Location - y
	  graph.newVertexProperty<float>("z");       // Location - z
	  graph.newVertexProperty<int>("type");      // 0 = terminal station, 1 = through station
	  graph.newVertexProperty<int>("capacity");  // Number of trains that can be accomodated
	  graph.newVertexProperty<int>("dwelltime"); //Minimum time allocated for boarding and alighting at each station
	  graph.newEdgeProperty<float>("linespeed");
	  
	  
	  //Create agent description
	  flamegpu::AgentDescription train = model.newAgent("train");
	  train.newVariable<float>("x");          // Locaiton - x
	  train.newVariable<float>("y");          // Location - y
	  train.newVariable<float>("z");          // Location - z
	  train.newVariable<float>("trainviz");   // Automatically assigned to enable colour differentiation between trains
	  train.newVariable<int>("target");       // The node (station) the train is heading towards. -1 indicates not yet on journey. -2 indicates journey completed.
	  train.newVariable<int>("starttime");    // Start time in seconds, e.g. relative to midnight
	  train.newVariable<int, 50>("route");    // An array of stations to call at. Allow for 50 stops
	  train.newVariable<int, 50>("timing");   // An array of timings indicating how long each leg of the journey is scheduled to take (incremental, not cumulative)
	  train.newVariable<float>("maxSpeed");   // Train capabillity maximum speed
	  train.newVariable<float>("dx");         // Step size in x on current edge
	  train.newVariable<float>("dy");         // Step size in y on current edge
	  train.newVariable<float>("dl");         // Step size in l on current edge
	  train.newVariable<float>("remainingL"); // Count down to reaching edge destination
	  train.newVariable<int>("journeyIndex"); // Count down to reaching edge destination
	  train.newVariable<int>("dwelltime");    // Count down dwell period in station
	  
	  //Setup execution order
	  
	  //Graph must be initialised before trains as the trains use graph properties in their initialisation
	  model.addInitFunction(InitGraph);
	  model.addInitFunction(InitTrains);

	  // Setup the move_trains function
	  flamegpu::AgentFunctionDescription train_fn = train.newFunction("move_trains", move_trains);
	  
	  // Identify the root of execution
	  model.addExecutionRoot(train_fn);
	  
	  // Build the model
	  model.generateLayers();
	  
	  //Convert model to a simulation
	  flamegpu::CUDASimulation simulation(model, argc, argv);
	  
	  // Specify the desired Exit LoggingConfig
	  flamegpu::LoggingConfig exit_log_cfg(model);
	  exit_log_cfg.logEnvironment("camera");
	  exit_log_cfg.logEnvironment("visualisation");
	  exit_log_cfg.logEnvironment("logging");
	  simulation.setExitLog(exit_log_cfg);

	  //Avoid messages about items not defined in the XML config file
	  simulation.SimulationConfig().verbosity = flamegpu::Verbosity::Quiet;
	  
	  // Create visualisation if enabled
	#ifdef FLAMEGPU_VISUALISATION
	  flamegpu::visualiser::ModelVis visualiser = simulation.getVisualisation();
	  
	  if(simulation.getEnvironmentProperty<int>("visualisation") >=1){
		visualiser.setInitialCameraTarget(simulation.getEnvironmentProperty<int, 6>("camera",0),
						  simulation.getEnvironmentProperty<int, 6>("camera",1), simulation.getEnvironmentProperty<int, 6>("camera",2));
		visualiser.setInitialCameraLocation(simulation.getEnvironmentProperty<int, 6>("camera",3),
						simulation.getEnvironmentProperty<int, 6>("camera",4), simulation.getEnvironmentProperty<int, 6>("camera",5));
		visualiser.setCameraSpeed(0.01f);
		
		// Add "train" agents to the visualisation
		flamegpu::visualiser::AgentVis train_agt = visualiser.addAgent("train");
		// Location variables have names "x" and "y" so will be used by default
		train_agt.setModel(flamegpu::visualiser::Stock::Models::CUBE);
		train_agt.setModelScale(10, 10, 10);
		train_agt.setXVariable("x");
		train_agt.setYVariable("y");
		train_agt.setZVariable("z");
		//A more sophisticated model would automatically adapt here for the number of trains
		train_agt.setColor(flamegpu::visualiser::HSVInterpolation::GREENRED("trainviz", 0.0f, simulation.getEnvironmentProperty<float>("maxtrains")));
		
		//Plot location of the graph verticies and edges
		flamegpu::visualiser::EnvironmentGraphVis g = visualiser.addGraph("graph");
		g.setColor(flamegpu::visualiser::Color{"#ff0000"});
		g.setXVertexProperty("x");
		g.setYVertexProperty("y");
		g.setZVertexProperty("z");
		
		// Mark the environment bounds
		flamegpu::visualiser::LineVis pen = visualiser.newPolylineSketch(1, 1, 1, 1); //0.2f
		pen.addVertex(0, 0, 0);
		pen.addVertex(0, 1000, 0);
		pen.addVertex(1000, 1000, 0);
		pen.addVertex(1000, 0, 0);
		pen.addVertex(0, 0, 0);
		
		// Open the visualiser window
		visualiser.activate();
	  }
	#endif
	  
	  //Run the simulation
	  simulation.initialise(argc, argv);  //MUST run this or the environmental graph won't be plotted in the visualisation
	  
	  // Execute the simulation
	  simulation.simulate();
	  
	  now = time(NULL);
	  timenow = gmtime(&now);
	  printf("Simulation end: %s", asctime(timenow));
	  
	  //Exit logging
	  
	  if(simulation.getEnvironmentProperty<int>("logging")){
		// Export the logged data to file
		// Use custom name. If the file exists the simulation will fail causing all data generated to be lost.
		strftime(filename, sizeof(filename), "network_%Y-%m-%d_%H-%M-%S.xml", timenow);
		
		simulation.exportLog(
				 filename, // The file to output (must end '.json' or '.xml')
				 simulation.getEnvironmentProperty<int>("logging")>=1,       // Whether the step log should be included in the log file
				 true,       // Whether the exit log should be included in the log file
				 true,       // Whether the step time should be included in the log file (treated as false if step log not included)
				 true,       // Whether the simulation time should be included in the log file (treated as false if exit log not included)
				 false       // Whether the log file should be minified or not
				 );
		
		if(simulation.getEnvironmentProperty<int>("logging") >= 2){
		  //Log agent data
		  strftime(filename, sizeof(filename), "agents_%Y-%m-%d_%H-%M-%S.xml", timenow);
		  simulation.exportData(filename);
		}
	  }
	  
	#ifdef FLAMEGPU_VISUALISATION
	  if(simulation.getEnvironmentProperty<int>("visualisation") >=1){
		// Keep the visualisation window active after the simulation has completed
		visualiser.join();
	  }
	#endif
	  
	  // Ensure profiling / memcheck work correctly
	  flamegpu::util::cleanup();
	  return EXIT_SUCCESS;
	}
  
Related Links
-------------

* User Guide Page: :ref:`What is FLAMEGPU_SEATBELTS?<FLAMEGPU_SEATBELTS>`
