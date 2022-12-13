.. _Telemetry:

Telemetry
=========

Support for academic software is dependant on evidence of impact. Without evidence it is difficult/impossible to justify investment to add features and provide maintenance. We collect a minimal amount of anonymous usage data so that we can gather usage statistics that enable us to continue to develop the software under a free and permissible licence.

When is Data sent
-----------------

We collect information when a simulation/ensemble/test suite has completed execution.

Where and How is Data Sent
--------------------------

We use the TelemetryDeck service to store telemetry data. All data is sent to their API endpoint of `https://nom.telemetrydeck.com/v1/ <https://nom.telemetrydeck.com/v1/>`_ via https. For more details please review `their privacy policy <https://telemetrydeck.com/privacy/>`_.

Data is sent via an subprocess call to :code:`curl`. If :code:`curl` is not available within your :code:`PATH` then telemetry will silently fail.

What Data is Sent
-----------------

We do not collect any personal data such as usernames, email addresses or machine identifiers. The data collected is as follows.

Metric Data for Telemetry Deck (Collected for all Telemetry)
 - ``isTestMode``: True or False value to indicate telemetry data is from developers. Set by the presence of :code:`FLAMEGPU_TEST_ENVIRONMENT` environment variable.
 - ``appID``: Out TelemetryDeck application ID.
 - ``clientUser``: A 36 character random number value generated during first CMake configuration of a build directory. This is fixed for Python wheel distributions.
 - ``sessionID``: Empty
 - ``Type``: Event type. This is either :code:`simulation-run`, :code:`ensemble-run`, :code:`googletest-run` or :code:`pytest-run`.

Payload values captured for all simulation, ensemble and test executions
 - ``appVersion``: Application full version string. e.g. :code:`pyflamegpu2.0.0-rc` (Python) or :code:`2.0.0-rc` (C++)
 - ``appVersionFull``: Full version with build hash e.g. :code:`2.0.0-rc+a0ff3c1f`
 - ``appPythonVersionFull``: Collected only for pyflamegpu. FLAME GPU version with CUDA version. e.g. :code:`2.0.0rc+cuda118`
 - ``majorSystemVersion``: e.g. :code:`2`
 - ``majorMinorSystemVersion``: e.g. :code:`2.0.0`
 - ``appVersionPatch``: e.g. :code:`0`
 - ``appVersionPreRelease``: e.g. :code:`rc`
 - ``buildNumber``:  hash from build. e.g. :code:`a0ff3c1f`
 - ``operatingSystem``: Either :code:`Windows`, :code:`Linux`, :code:`Unix` or :code:`Other`
 - ``Visualisation``: True or False value depending on if FLAME GPU was built with visualisation enabled (e.g. the :code:`FLAMEGPU_VISUALISATION` CMake variable).

Additional Payload values captured for Simulation or Ensemble Runs only
 - ``GPUDevices``: The GPU devices selected for simulation or ensemble execution. e.g. :code:`NVIDIAGeForceRTX3080`
 - ``SimTime(s)``: The simulation or ensemble time of your model.
 - ``NVCCVersion``: The version of NVCC used to compile the Simulation/Ensemble. e.g. ``12.0.76``.

Payload values captured for GoogleTest and pytest runs only
 - ``TestOutcome``: Passed or Failed
 - ``TestsTotal``: The total number of tests discoverd / collected
 - ``TestsSelected``: The number of tests executed (subject to filters etc)
 - ``TestsSkipped``: The number of tests skipped or disabled
 - ``TestsPassed``: The number of tests which passed
 - ``TestsFailed``: The number of tests which failed
 - ``TestsPassed``: Number of tests Passed
 - ``TestsToRun``: Number of tests selected to run
 - ``TestsTotal``: Total number of tests discovered by google test

If you wish to view the telemetry packet sent to TelemetryDeck then you can use the :code:`--verbose` (or :code:`-v`) command line option to either the simulation or test call. This will print the full telemetry data packet in json format.

Disabling Telemetry (Opt-out)
-----------------------------

Telemetry is enabled by default, but can be opt-out at configuration time, or at runtime.

During configuration and building of the FLAMEGPU static library or python wheels, the default enabled/disabled status of telemetry can be configured.
By default this is ``ON``, unless the ``FLAMEGPU_SHARE_USAGE_STATISTICS`` environment variable is set to a false-y CMake value (``OFF``, ``FALSE``, ``0`` etc) during the first configuration of the CMake directory. 
The CMake option ``FLAMEGPU_SHARE_USAGE_STATISTICS`` can be used to override the default value, i.e. setting this to ``OFF``. 
The CMake configuration option only sets the default value, which can be overridden using an environment variable or programmatically, it does not fully disable telemetry.

At runtime, the system environmental variable ``FLAMEGPU_SHARE_USAGE_STATISTICS`` is queried to determine if telemetry should be enabled or not. 
If it is not present, the value from CMake configuration time will be used, otherwise if the environment variable is defined, is not empty and is set to a false-y value (``OFF``, ``FALSE``, ``0`` etc) telemetry will be disabled (unless overridden programmatically), otherwise it will be enabled.

Telemetry can be enabled / disabled programmatically, overriding CMake and system environment options:

* :func:`flamegpu::io::Telemetry::enable()<flamegpu::io::Telemetry::enable>` will enable telemetry for all Simulation and Ensemble's instantiated from then on. It does not effect already created Simulation/Ensemble objects.
* :func:`flamegpu::io::Telemetry::disable()<flamegpu::io::Telemetry::disable>` will disable telemetry for all Simulation and Ensemble's instantiated from then on. It does not effect already created Simulation/Ensemble objects.
* :func:`flamegpu::io::Telemetry::isEnabled()<flamegpu::io::Telemetry::enabled>` will return if telemetry is globally enabled at that point in time or not.
* Individual :class:`Simulation<flamegpu::Simulation>` objects can enable/disable telemetry by mutating the :class:`Simulation::Config<flamegpu::Simulation::Config>` and :class:`CUDASimulation::Config<flamegpu::CUDASimulation::Config>` structures, which are accessed via :func:`SimulationConfig()<flamegpu::Simulation::SimulationConfig>` and :func:`CUDAConfig()<flamegpu::CUDASimulation::CUDAConfig>` respectively on the :class:`CUDASimulation<flamegpu::CUDASimulation>` instance. Setting the ``telemetry`` member to ``true`` or ``false`` will enable/disable telemetry for that instance.
* Individual :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>` objects can enable/disable telemetry by mutating the :class:`CUDAEnsemble::Config<flamegpu::CUDAEnsemble::EnsembleConfig>` structures, which is accessed via :func:`Config()<flamegpu::CUDAEnsemble::Config>` on the :class:`CUDAEnsemble<flamegpu::CUDAEnsemble>` instance. Setting the ``telemetry`` member to ``true`` or ``false`` will enable/disable telemetry for that instance.

If Telemetry is disabled the software will encourage telemetry to be enabled to support the software, once per binary execution, printed to the standard output.
These encouragements can be disabled by:

* Setting the CMake option ``FLAMEGPU_TELEMETRY_SUPPRESS_NOTICE`` to ``OFF`` during CMake configuration
* Setting the system environment variable ``FLAMEGPU_TELEMETRY_SUPPRESS_NOTICE`` to ``OFF`` prior to the first CMake configuration, or at runtime.
* Programmatically by calling :func:`flamegpu::io::Telemetry::suppressNotice()<flamegpu::io::Telemetry::suppressNotice>` prior to any telemetry calls being made (i.e. prior to running any simulations or ensembles).

Developer Notes
---------------

By setting the :code:`FLAMEGPU_TELEMETRY_TEST_MODE` environment variable or CMake option to a truthy value will enable TestMode for TelemetryDeck requests. All telemetry data will be flagged as test data and not appear in standard reporting. This is useful for developers to separate simulation and test runs from users.






