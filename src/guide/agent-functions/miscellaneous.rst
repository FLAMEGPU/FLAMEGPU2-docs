Miscellaneous Methods
^^^^^^^^^^^^^^^^^^^^^

These other methods are also available within :class:`DeviceAPI<flamegpu::DeviceAPI>` for use within agent functions:

============================================================== =========================== ===========================================================
Method                                                         Return                      Description
============================================================== =========================== ===========================================================
:func:`getID()<flamegpu::DeviceAPI::getID>`                    ``unsigned int``            Returns the current agent's unique identifier, this ID is unique to the agent throughout the simulation. All IDs are greater than 0.
:func:`getStepCounter()<flamegpu::DeviceAPI::getStepCounter>`  ``unsigned int``            Returns the current step index, the first step has index 0. Exit conditions execute before the step counter is incremented.
:func:`getThreadIndex()<flamegpu::DeviceAPI::getThreadIndex>`  ``unsigned int``            Returns the current thread index, each agent executing the agent function has a unique thread index in the range [0, N).
:func:`isAgent()<flamegpu::DeviceAPI::isAgent>`                ``bool``                    When passed a string literal, this function will return a boolean confirming whether that string matches the executing agent's name. *This function is considered expensive.*
:func:`isState()<flamegpu::DeviceAPI::isState>`                ``bool``                    When passed a string literal, this function will return a boolean confirming whether that string matches the executing agent's state. *This function is considered expensive.*

============================================================== =========================== ===========================================================

Related Links
-------------

* Full API documentation for :class:`DeviceAPI<flamegpu::DeviceAPI>`
* Full API documentation for :class:`ReadOnlyDeviceAPI<flamegpu::ReadOnlyDeviceAPI>`