.. _Initialisation from Disk:

Initialisation from Disk
========================

FLAMEGPU2 simulations can be initialised from disk using either the XML or JSON format. The XML format is compatible with the previous FLAMEGPU1 input/output files, whereas the JSON format is new to FLAMEGPU2. In both cases, the input and output file formats are the same.

Loading simulation state (agent data and environment properties) from file can be achieved via either command line specification, or explicit specification within the code for the model. (See the :ref:`full guide <Configuring Execution>` guide for more information)


In most cases, the input file will be taken from command line which can be passed using ``-i <input file>``.

Agent IDs must be unique when the file is loaded from disk, otherwise an ``AgentIDCollision`` exception will be thrown. This must be corrected in the input file, as there is no method to do so within FLAMEGPU2.

In most cases, components of the input file are optional and can be omitted if defaults are preferred. If agents are not assigned IDs within the input file, they will be automatically generated.




File Format
---------------

=================== ==============================================
Block               Description
=================== ==============================================
``itno``            **XML Only** This block provides the step number in XML output files, it is included for backwards compatibility with FLAMEGPU 1. It has no use for input.
``config``          This block is split into sub-blocks ``simulation`` and ``cuda``, the members of each sub-block align with ``SimulationConfig`` and ``CUDAConfig`` members of the same name respectively. These values are output to log the configuration, and can optionally be used to set the configuration via input file. (See the :ref:`Configuring Execution` guide for details of each individual member)
``stats``           This block includes statistics collected by FLAME GPU 2 during execution. It has no purpose on input.
``environment``     This block includes members of the environment, and can be used to configure the environment via input file. Members which begin with ``_`` are automatically created internal properties, which can be set via input file.
``xagent``          **XML Only** Each ``xagent`` block represents a single agent, and the ``name`` and ``state`` values must match an agent state within the loaded model description hierarchy. Members which begin with ``_`` are automatically created internal variables, which can be set via input file.
``agents``          **JSON Only** Within the ``agents`` block, a sub block may exist for each agent type, and within this a sub-block for each state type. Each state then maps to an array of object, where each object consists of a single agent's variables. Members which begin with ``_`` are automatically created internal variables, which can be set via input file.
=================== ==============================================

The below code block displays example files output from FLAME GPU 2 in both XML and JSON formats.

.. tabs::

  .. code-tab:: xml

    <states>
        <itno>100</itno>
        <config>
            <simulation>
                <input_file></input_file>
                <step_log_file></step_log_file>
                <exit_log_file></exit_log_file>
                <common_log_file></common_log_file>
                <truncate_log_files>true</truncate_log_files>
                <random_seed>1643029170</random_seed>
                <steps>1</steps>
                <verbose>false</verbose>
                <timing>false</timing>
                <console_mode>false</console_mode>
            </simulation>
            <cuda>
                <device_id>0</device_id>
                <inLayerConcurrency>true</inLayerConcurrency>
            </cuda>
        </config>
        <stats>
            <step_count>100</step_count>
        </stats>
        <environment>
            <repulse>0.05</repulse>
            <_stepCount>1</_stepCount>
        </environment>
        <xagent>
            <name>Circle</name>
            <state>default</state>
            <_auto_sort_bin_index>0</_auto_sort_bin_index>
            <_id>241</_id>
            <drift>0.0</drift>
            <x>0.8293430805206299</x>
            <y>1.5674132108688355</y>
            <z>14.034683227539063</z>
        </xagent>
        <xagent>
            <name>Circle</name>
            <state>default</state>
            <_auto_sort_bin_index>0</_auto_sort_bin_index>
            <_id>242</_id>
            <drift>0.0</drift>
            <x>23.089038848876954</x>
            <y>24.715721130371095</y>
            <z>2.3497250080108644</z>
        </xagent>
    </states>


  .. code-tab:: json
  
    {
      "config": {
        "simulation": {
          "input_file": "",
          "step_log_file": "",
          "exit_log_file": "",
          "common_log_file": "",
          "truncate_log_files": true,
          "random_seed": 1643029117,
          "steps": 1,
          "verbose": false,
          "timing": false,
          "console_mode": false
        },
        "cuda": {
          "device_id": 0,
          "inLayerConcurrency": true
        }
      },
      "stats": {
        "step_count": 100
      },
      "environment": {
        "repulse": 0.05,
        "_stepCount": 1
      },
      "agents": {
        "Circle": {
          "default": [
            {
              "_auto_sort_bin_index": 0,
              "_id": 241,
              "drift": 0.0,
              "x": 0.8293430805206299,
              "y": 1.5674132108688355,
              "z": 14.034683227539063
            },
            {
              "_auto_sort_bin_index": 168,
              "_id": 242,
              "drift": 0.0,
              "x": 23.089038848876954,
              "y": 24.715721130371095,
              "z": 2.3497250080108644
            }
          ]
        }
      }
    }