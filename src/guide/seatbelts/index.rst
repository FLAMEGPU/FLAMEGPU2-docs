.. _SEATBELTS:

What is SEATBELTS?
==================

FLAME GPU 2, unlike FLAME GPU 1, allows models to be fully defined via a C++ API. This means that some algorithmic magic is required to map a variable's name to a memory within agent functions (CUDA device code) at runtime. In order to achieve this, whilst enabling the highest performance it becomes necessary to remove any safety checks (e.g. ensuring the variable exists, has the correct type etc).

From this was born ``SEATBELTS``. Originally named ``NO_SEATBELTS`` after the racing concept of removing weight from a car to allow it to accelerate faster, in combination with the removal of safety checks which in the case of a racing car would be the seatbelts.

When ``SEATBELTS`` is enabled at CMake configure time Release builds will include any error checking deemed expensive. These builds still run much faster than Debug builds, which always have ``SEATBELTS`` enabled regardless of CMAKE configuration. However, the fastest performance can only be achieved by producing a Release build with ``SEATBELTS`` disabled.

Most ``SEATBELTS`` checks are limited to device code within agent functions (type checking in host functions is cheap), however there are some additional expensive integrity checks (such as array message output collisions) which are limited to ``SEATBELTS`` enabled builds.

.. note::

    CUDA does not support safely exiting device code early, via an exception or similar. All CUDA errors raised from device code execution are considered fatal, whereby the CUDA runtime is corrupted and data cannot be recovered from device memory. As such, in order to provide exceptions from agent functions, it is necessary for ``SEATBELTS`` to both log detail about the problem to device memory and return a sensible value (normally ``0``) in order to allow the agent function to complete without raising a CUDA error. Our testing has not found any cases where this currently fails, however it may be possible to structure code such that ``SEATBELTS`` does not prevent a CUDA error.




Enabling/Disabling SEATBELTS
----------------------------
``SEATBELTS`` is a compile-time feature, whereby the compiler passes the C macro of the same name to all files. As such, it can only be toggled at CMake time (as mentioned above it cannot be disabled for Debug builds).

By default when configuring CMake ``SEATBELTS`` is ``ON``.

In order to disable it, for the fastest performance ``-DSEATBELTS=OFF`` must be passed to ``cmake`` at configure time. If using ``cmake-gui``, you should locate the ``SEATBELTS`` option in the central table, set it to ``OFF`` and press the ``Configure`` button followed by the ``Generate`` button.


Related Links
-------------

* User Guide Page: :ref:`Building From Source<q-compiling flamegpu>` (C++)
* User Guide Page: :ref:`Building From Source<q-python-building-from-source>` (Python)