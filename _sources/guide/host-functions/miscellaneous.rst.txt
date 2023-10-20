Miscellaneous Methods
^^^^^^^^^^^^^^^^^^^^^

These other methods are also available within :class:`HostAPI<flamegpu::HostAPI>` for use within host functions and host conditions:

===================================================================== ================================================================== ===========================================================
Method                                                                Return                                                             Description
===================================================================== ================================================================== ===========================================================
:func:`getStepCounter()<flamegpu::HostAPI::getStepCounter>`           ``unsigned int``                                                   Returns the current step index, the first step has index 0.
:func:`getSimulationConfig()<flamegpu::HostAPI::getSimulationConfig>` :class:`Simulation::Config<flamegpu::Simulation::Config>`          Returns the current simulation's simulation config struct.
:func:`getCUDAConfig()<flamegpu::HostAPI::getCUDAConfig>`             :class:`CUDASimulation::Config<flamegpu::CUDASimulation::Config>`  Returns the current simulation's CUDA config struct.
:func:`getEnsembleRunIndex()<flamegpu::HostAPI::getEnsembleRunIndex>` ``unsigned int``                                                   Returns the index of the simulation run within the ensemble's :class:`RunPlanVector<flamegpu::RunPlanVector>`. If the simulation is not part of an ensemble, ``UINT_MAX`` will be returned.
===================================================================== ================================================================== ===========================================================

Related Links
-------------

* Full API documentation for :class:`HostAPI<flamegpu::HostAPI>`