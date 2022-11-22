.. _FLAMEGPU_SEATBELTS:

What is FLAMEGPU_SEATBELTS?
===========================

FLAME GPU 2, unlike FLAME GPU 1, allows models to be fully defined via a C++ API. This means that some algorithmic magic is required to map a variable's name to a memory within agent functions (CUDA device code) at runtime. In order to achieve this, whilst enabling the highest performance it becomes necessary to remove any safety checks (e.g. ensuring the variable exists, has the correct type etc).

From this was born ``FLAMEGPU_SEATBELTS``. Originally named ``NO_SEATBELTS`` after the racing concept of removing weight from a car to allow it to accelerate faster, in combination with the removal of safety checks which in the case of a racing car would be the seatbelts.

When ``FLAMEGPU_SEATBELTS`` is enabled at CMake configure time Release builds will include any error checking deemed expensive. These builds still run much faster than Debug builds, which always have ``FLAMEGPU_SEATBELTS`` enabled regardless of CMAKE configuration. However, the fastest performance can only be achieved by producing a Release build with ``FLAMEGPU_SEATBELTS`` disabled.

Most ``FLAMEGPU_SEATBELTS`` checks are limited to device code within agent functions (type checking in host functions is cheap), however there are some additional expensive integrity checks (such as array message output collisions) which are limited to ``FLAMEGPU_SEATBELTS`` enabled builds.

.. note::

    CUDA does not support safely exiting device code early, via an exception or similar. All CUDA errors raised from device code execution are considered fatal, whereby the CUDA runtime is corrupted and data cannot be recovered from device memory. As such, in order to provide exceptions from agent functions, it is necessary for ``FLAMEGPU_SEATBELTS`` to both log detail about the problem to device memory and return a sensible value (normally ``0``) in order to allow the agent function to complete without raising a CUDA error. Our testing has not found any cases where this currently fails, ho<SEATwever it may be possible to structure code such that ``FLAMEGPU_SEATBELTS`` does not prevent a CUDA error.

Enabling/Disabling FLAMEGPU_SEATBELTS
-------------------------------------
``FLAMEGPU_SEATBELTS`` is a compile-time feature, whereby the compiler passes the C macro of the same name to all files. As such, it can only be toggled at CMake time (as mentioned above it cannot be disabled for Debug builds).

By default when configuring CMake ``FLAMEGPU_SEATBELTS`` is ``ON``.

In order to disable it, for the fastest performance ``-DFLAMEGPU_SEATBELTS=OFF`` must be passed to ``cmake`` at configure time. If using ``cmake-gui``, you should locate the ``FLAMEGPU_SEATBELTS`` option in the central table, set it to ``OFF`` and press the ``Configure`` button followed by the ``Generate`` button.


Understanding FLAMEGPU_SEATBELTS Exceptions
-------------------------------------------
When ``FLAMEGPU_SEATBELTS`` detects a problem in an agent function it will cause a :class:`DeviceError<flamegpu::exception::DeviceError>` to be raised. This error contains a message detailing the problem, for example:

.. code-block:: none

  Device function 'inputdata' reported 4000 errors.
  First error:
  inputdata_impl_curve_rtc_dynamic.h(187)[2,0,0][64,0,0]:
  Agent variable 'x33' was not found during getVariable().
  
Below this message has been broken down:
  
* ``Device function 'inputdata' reported 4000 errors``
   * ``inputdata`` is the name of the agent function which raised the error.
   * ``4000`` is the number of agents which reported an error during the function
* ``First error:``
   * Only the first agent to report an error will have it's location and message returned. However in most cases, all agent's errors will be caused by the same bug.
* ``inputdata_impl_curve_rtc_dynamic.h(187)[2,0,0][64,0,0]:``
   * This is the location of the error within the FLAME GPU 2 source, it will usually point to internal headers so is unlikely to be useful to you.
   * ``inputdata_impl_curve_rtc_dynamic.h`` refers to the dynamically generated RTC curve header for the agent function ``inputdata``.
   * ``(187)`` states that the error was thrown from line 187 of the above file.
   * ``[2,0,0][64,0,0]`` Specifies the CUDA block and thread indices of the reporting thread. Non-deterministic atomics are used to decide the first agent/thread, so this value is likely to change with repeated runs.
* ``Agent variable 'xx' was not found during getVariable().``
   * This is the bespoke message of the exception and will vary due to the cause.
   * In this case it reports that the agent variable ``xx`` was requested, but does not exist. 

In most cases when FLAME GPU 2 raises an exception, the message will be printed to console by default. However, in some cases you may need to catch the exception and print it's message manually (using the standard C++/Python error-handling techniques).

Related Links
-------------

* User Guide Page: :ref:`Building From Source<q-compiling flamegpu>` (C++)
* User Guide Page: :ref:`Building From Source<q-python-building-from-source>` (Python)