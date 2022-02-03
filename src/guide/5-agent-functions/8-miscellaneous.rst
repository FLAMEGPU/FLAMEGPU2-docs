Miscellaneous Methods
^^^^^^^^^^^^^^^^^^^^^

These other methods are also available within :class:`DeviceAPI<flamegpu::DeviceAPI>` for use within agent functions:

============================================================== =========================== ===========================================================
Method                                                         Return                      Description
============================================================== =========================== ===========================================================
:func:`getStepCounter()<flamegpu::DeviceAPI::getStepCounter>`  ``unsigned int``            Returns the current step index, the first step has index 0. Exit conditions execute before the step counter is incremented.
:func:`getThreadIndex()<flamegpu::DeviceAPI::getThreadIndex>`  ``unsigned int``            Returns the current thread index, each agent executing the agent function has a unique thread index in the range [0, N).
============================================================== =========================== ===========================================================

Related Links
-------------

* Full API documentation for :class:`DeviceAPI<flamegpu::DeviceAPI>`
* Full API documentation for :class:`ReadOnlyDeviceAPI<flamegpu::ReadOnlyDeviceAPI>`