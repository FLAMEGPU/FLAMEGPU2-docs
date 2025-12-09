.. _Defining Agent Functions:

Defining Agent Functions
^^^^^^^^^^^^^^^^^^^^^^^^

Agent Functions can be specified as C++ functions, built at compile time when using the C++ API, or they can be specified as Run-Time Compiled (RTC) function strings when using the both the C++ and Python APIs. Although agent functions are technically CUDA device code the FLAME GPU API abstracts this and no CUDA syntax is required to script behaviour. The same limitations apply to agent functions as to CUDA C++, the most significant restriction being standard libraries are not supported unless specified otherwise (see `CUDA documentation <https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#restrictions>`_ for more details). C++ agent functions are distinguished within the examples in this guide by using the name *Agent C++* so that it is clear that this is a subset of supported C++.

An experimental feature for Python allows the specification of native agent functions in Python. The Python can then be transpiled, a process of translating the Python syntax to equivalent C++, at runtime. A limited subset of Python is supported which is restricted to Python features that can be *easily* transpiled to a C++ equivalent at runtime for compilation. For example Python functionality like generator expressions, arrays, dictionaries, etc, which do not have an obvious C++ equivalent are not permitted and will raise an exception. The subset of supported Python is referred to as *Agent Python* within this guide.

C++ Compile Time Agent Functions
--------------------------------

A C++ agent function is can be defined for compilation using the :c:macro:`FLAMEGPU_AGENT_FUNCTION` macro. 
This takes three arguments: a unique name identifying the function, an input message communication strategy, and an output message communication strategy.
We will discuss messages in more detail later, so for now don't worry about the second and third parameters. :class:`flamegpu::MessageNone` is specified when not requiring message input or output, so this is used.
Similarly, agent functions should return :enumerator:`flamegpu::ALIVE<flamegpu::AGENT_STATUS::ALIVE>` by default, agent death is explained in a :ref:`later section<agent birth death>` of this chapter.

For compile time (i.e. non-RTC functions), when using the C++ API, the :c:macro:`FLAMEGPU_AGENT_FUNCTION` macro can be used to declare and define the agent function, which can then be associated with the :class:`AgentDescription<flamegpu::AgentDescription>` object using the :func:`newFunction()<flamegpu::AgentDescription::newFunction>` method.


.. tabs::

  .. code-tab:: cpp C++
     
    // Define an agent function called agent_fn1 - specified ahead of main function
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Behaviour goes here
        return flamegpu::ALIVE;
    }

    int main() {
        // ...

        // Attach a function called agent_fn1, defined by the symbol agent_fn1 to the AgentDescription object agent.
        flamegpu::AgentFunctionDescription agent_fn1_description = agent.newFunction("agent_fn1", agent_fn1);

        // ...
    }

.. _Runtime Compiled Agent Functions:

C++ and Python Runtime Compiled Agent Functions
-----------------------------------------------

Run-time compiled (RTC) C++ style agent functions follow the same syntax as for C++ compile time agent functions with the exception that the function must be defined in a string and associated with the :class:`AgentDescription<flamegpu::AgentDescription>` using the :func:`newRTCFunction()<flamegpu::AgentDescription::newRTCFunction>` method.

Runtime C++ style compiled functions can be used with both the the C++ and Python APIs.

.. cpp syntax highlighting due to issues with the cuda highlighter and raw strings.
.. tabs::

  .. code-tab:: cpp C++

    const char* agent_fn1_source = R"###(
    // Define an agent function called agent_fn1 - specified ahead of main function
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, flamegpu::MessageNone, flamegpu::MessageNone) {
        // Behaviour goes here
    }
    )###";

    int main() {
        ...

        // Attach a function called agent_fn1, defined in the string variable agent_fn1_source to the AgentDescription object agent.
        flamegpu::AgentFunctionDescription agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

        ...
    }

  .. code-tab:: py Python

    # Define an agent function called agent_fn1
    agent_fn1_source = r"""
    FLAMEGPU_AGENT_FUNCTION(agent_fn1, MessageNone, MessageNone) {
        # Behaviour goes here
    }
    """

    ...

    # Attach a function called agent_fn1 to an agent represented by the AgentDescription agent 
    # The AgentFunctionDescription is stored in the agent_fn1_description variable
    agent_fn1_description = agent.newRTCFunction("agent_fn1", agent_fn1_source);

    ...
    
.. note::

    If you wish to store RTC agent functions in separate files :func:`newRTCFunction()<flamegpu::AgentDescription::newRTCFunction>` can be replaced with :func:`newRTCFunctionFile()<flamegpu::AgentDescription::newRTCFunctionFile>`, instead passing the path to the agent function's source file (either absolute or relative to the working directory at runtime). This will allow them to be developed in a text editor with C++ syntax highlighting.
    
.. note::

    RTC agent functions support ``#include`` statements, allowing seperate header files to be used. By default the only include path used is the working directory. The default include path can be overridden by setting the ``FLAMEGPU_RTC_INCLUDE_DIRS`` environment variable, multiple paths can be specified using the operating system's normal PATH delimiter (Linux ``:``, Windows ``;``).

To optimise the loading of RTC agent functions, they are only compiled when changes are detected, with compiled agent functions being cached both in memory during execution and to the operating system's on-disk temporary directory between executions. The utility :func:`util::clearRTCDiskCache()<flamegpu::util::clearRTCDiskCache>` can be used to clear the on-disk cache.

The on-disk cache may grow over time if you are using many different versions of flame gpu and compiling many different agent functions (e.g. running the test suites). If you wish to purge the on-disk cache this can be achieved via the below command.

.. tabs::

  .. code-tab:: cpp C++

    #include "flamegpu/util/cleanup.h"

    flamegpu::util::clearRTCDiskCache();

  .. code-tab:: py Python
  
    from pyflamegpu import *
  
    pyflamegpu.clearRTCDiskCache()


.. _Python Agent Functions:

FLAME GPU Python Agent Functions
--------------------------------

Python agent functions are required to have the ``@pyflamegpu.agent_function`` decorator and must specify two arguments, the ``message_in`` and ``message_out`` variables (although the names can be changed), both of which must use a type annotation of a :ref:`supported message type<Communication Strategies>` prefixed with the Python FLAME GPU module name ``pyflamegpu.``.

.. tabs::

  .. code-tab:: py Agent Python

    #Define an agent function called agent_fn1
    @pyflamegpu.agent_function
    def agent_fn1(message_in: pyflamegpu.MessageNone, message_out: pyflamegpu.MessageNone):
        # Behaviour goes here
        pass

    ...
    # Transpile the Python agent function to equivalent C++ (and transpile errors with raise an exception at this stage)
    agent_fn1_translated = pyflamegpu.codegen.translate(agent_fn1) 

    # Attach Python function called agent_fn1 to an agent represented by the AgentDescription agent (the function will be compiled at runtime as C++)
    agent.newRTCFunction("agent_fn1", agent_fn1_translated)
    ...

Compilation Errors
""""""""""""""""""

As agent functions are translated to C++ for compilation any errors will be reported at runtime as C++ errors (to the console) following a runtime exception. In order to assist users in understanding the source of errors the originating python source file and line will be reported by the C++ compiler. E.g. If an erroneous call to an unknown function call ``no = get_thing()`` is added to the ``boids_spatial3D.py`` example on line 85 the following C++ error will be produced.  

.. code-block:: console

  D:\...\site-packages\pyflamegpu\codegen\codegen.py:212: UserWarning: Warning (85, 9): Function call is not a defined FLAME GPU device function or a supported python built in.
    warnings.warn(f"Warning ({tree.lineno}, {tree.col_offset}): {str}")
  Failed to load program for agent function (condition) 'outputdata', log:
  Compilation failed: NVRTC_ERROR_COMPILATION
  boids_spatial3D.py(85): error: identifier "get_thing" is undefined
        auto no = get_thing();


Note: The originating Python file and line will always by reported where the code generator has been provided with a Python callable from a file. In the case that a string representation of an agent function is passed the error will report ``PythonString(line_number)`` where ``line_number`` will be the line within the string. Where a callable is passed to the code generator from some source other than a Python file (e.g. a Jupyter Notebook) the error will report ``DynamicPython(line_number)`` where ``line_number`` will be line within the originating notebook cell.


Supported Function Calls
""""""""""""""""""""""""

The Python transpiler supports function calls that have a C++ equivalent in the will check function calls in the API. The API singleton is available as ``pyflamegpu`` which is equivalent to the ``FLAMEGPU`` object in C++. If non existent functions are called on API objects then this will raise an error during translation. Calling of correctly specified device functions is also supported as well as calls to a small number of python built in functions. E.g. ``abs()``, ``int()``, and ``float()``. Any calls to math library functions are directly translated to C++ equivalents. E.g. ``Math.sinf()`` will result in a call to ``sinf()`` in C++. The majority of python math functions directly translate to their C++ counterparts. 

Supported Math Constants
""""""""""""""""""""""""

The following mathematics constants are supported;

============= =================================
Python        Description
============= =================================
``math.pi``   Translated of ``M_PI`` in C++
``math.e``    Translated of ``M_E`` in C++
``math.inf``  Translated of ``INFINITY`` in C++
``math.nan``  Translated of ``NAN`` in C++
============= =================================

.. _Python Types:

Typed API Functions
"""""""""""""""""""

Calls to many FLAME GPU API functions are typed using template arguments in C++. In the Python equivalents the type is specified by calling a type instantiated version of the function using a suffix. The following type suffix are supported;

============= ===============================================
Type Suffix   C++ Equivalent type
============= ===============================================
``Char``      Would be ``char`` type template argument 
``Float``     Would be ``float`` type template argument 
``Double``    Would be ``double`` type template argument 
``Int``       Would be ``int`` type template argument (the same as Int32)
``UInt``      Would be ``unsigned int`` type template argument (the same as UInt32)
``Int8``      Would be ``int_8`` type template argument 
``UInt8``     Would be ``uint_8`` type template argument 
``Int16``     Would be ``int_16`` type template argument 
``UInt16``    Would be ``uint_16`` type template argument 
``Int32``     Would be ``int_32`` type template argument 
``UInt32``    Would be ``uint_32`` type template argument 
``Int64``     Would be ``int_64`` type template argument 
``UInt64``    Would be ``uint_64`` type template argument 
============= ===============================================

In each case the type is appended to the end of the API function. E.g. ``getVariableInt("name")`` in Python would be ``getVariable<"int">("name")`` in C++, and ``getVariableFloat("name")`` would be  ``getVariable<"float">("name")``  in C++


FLAME GPU Device Functions
--------------------------

If you wish to define regular functions which can be called from agent functions, you can use the :c:macro:`FLAMEGPU_DEVICE_FUNCTION` macro (in C++), or the ``@pyflamegpu.device_function`` decorator for Python. Python device functions require type annotations for arguments and the function return type using supported types.

====================== =================================================================================
Type                   Description
====================== =================================================================================
``int``                Python built in ``int`` type which will translate transpile to a C++ ``int``
``float``              Python built in ``float`` type which will translate transpile to a C++ ``float`` 
``numpy.byte``         A numpy ``byte`` type which will transpile to a C++ ``char``
``numpy.ubyte``        A numpy ``ubyte`` type which will transpile to a C++ ``unsigned char``
``numpy.short``        A numpy ``short`` type which will transpile to a C++ ``short``
``numpy.ushort``       A numpy ``ushort`` type which will transpile to a C++ ``unsigned short``
``numpy.intc``         A numpy ``intc`` type which will transpile to a C++ ``int``
``numpy.uintc``        A numpy ``uintc`` type which will transpile to a C++ ``unsigned int``
``numpy.uint``         A numpy ``uint`` type which will transpile to a C++ ``unsigned int``
``numpy.longlong``     A numpy ``longlong`` type which will transpile to a C++ ``long long``
``numpy.ulonglong``    A numpy ``ulonglong`` type which will transpile to a C++ ``unsigned long long``
``numpy.half``         A numpy ``half`` type which will transpile to a C++ ``half``
``numpy.single``       A numpy ``single`` type which will transpile to a C++ ``float``
``numpy.double``       A numpy ``double`` type which will transpile to a C++ ``double``
``numpy.longdouble``   A numpy ``longdouble`` type which will transpile to a C++ ``long double`` (not currently supported in device code but left for completeness)
``numpy.bool_``        A numpy ``bool_`` type which will transpile to a C++ ``bool``
``numpy.bool8``        A numpy ``bool8`` type which will transpile to a C++ ``bool``
``numpy.int_``         A numpy ``int_`` type which will transpile to a C++ ``long``
``numpy.int8``         A numpy ``int8`` type which will transpile to a C++ ``int8_t``
``numpy.int16``        A numpy ``int16`` type which will transpile to a C++ ``int16_t``
``numpy.int32``        A numpy ``int32`` type which will transpile to a C++ ``int32_t``
``numpy.int64``        A numpy ``int64`` type which will transpile to a C++ ``int64_t``
``numpy.intp``         A numpy ``intp`` type which will transpile to a C++ ``intptr_t``
``numpy.uint_``        A numpy ``uint_`` type which will transpile to a C++ ``long``
``numpy.uint8``        A numpy ``uint8`` type which will transpile to a C++ ``uint8_t``
``numpy.uint16``       A numpy ``uint16`` type which will transpile to a C++ ``uint16_t``
``numpy.uint32``       A numpy ``uint32`` type which will transpile to a C++ ``uint32_t``
``numpy.uint64``       A numpy ``uint64`` type which will transpile to a C++ ``uint64_t``
``numpy.uintp``        A numpy ``uintp`` type which will transpile to a C++ ``uintptr_t``
``numpy.float_``       A numpy ``float_`` type which will transpile to a C++ ``float``
``numpy.float16``      A numpy ``float16`` type which will transpile to a C++ ``half``
``numpy.float32``      A numpy ``float32`` type which will transpile to a C++ ``float``
``numpy.float64``      A numpy ``float64`` type which will transpile to a C++ ``double``
====================== =================================================================================

Any runtime compiled agent functions must include the definition of any device functions in the agent function string. These can not be shared between agent functions (as each has a unique string definition).

Python agent device functions must be contained in the source file of any agent functions which call them. All device functions are automatically discovered and included during the transpilation process. 

.. tabs::

  .. code-tab:: cuda Agent C++

    // Define a function for adding two integers which can be called inside agent functions.
    FLAMEGPU_DEVICE_FUNCTION int add(int a, int b) {
        return a + b;
    }

  .. code-tab:: py Agent Python

    # Define a function for adding two integers which can be called inside agent functions.
    @pyflamegpu.device_function
    def add(a: int, b: int) -> int :
      return a + b

    
FLAME GPU Host Device Functions
-------------------------------

If you wish to define regular functions which can be called from within agent and host functions, you can use the :c:macro:`FLAMEGPU_HOST_DEVICE_FUNCTION` macro.

Host Device functions are not currently supported by the Python agent function format.

.. tabs::

  .. code-tab:: cuda Agent C++

    // Define a function for subtracting two integers which can be called inside agent functions, or in host code
    FLAMEGPU_HOST_DEVICE_FUNCTION int subtract(int a, int b) {
        return a - b;
    }




    
Related Links
-------------
* User Guide Section: :ref:`Supported Types<Supported Types>`
* Full API documentation for :class:`AgentFunctionDescription<flamegpu::AgentFunctionDescription>`
* Full API documentation for :c:macro:`FLAMEGPU_AGENT_FUNCTION`
* Full API documentation for :c:macro:`FLAMEGPU_DEVICE_FUNCTION`
* Full API documentation for :c:macro:`FLAMEGPU_HOST_DEVICE_FUNCTION`