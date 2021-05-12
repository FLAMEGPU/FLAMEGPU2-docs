Structure of a FLAMEGPU2 Program
================================

FLAMEGPU2 programs are composed of 4 sections:

- Agent/Host function definitions
- Model Declaration
- Initialisation
- Execution

**TODO: annotated source code image with sections identified**

Agent/Host Function Definitions
-------------------------------

These functions define the actual behaviours of your model and are defined before the `main` function. For more detail about defining these please see **TODO: Link**.
If your model is growing very large, you can move these into a separate file and include it using the `#include` preprocessor
directive. Any number of files could be included this way, allowing you to group related functions together. 

Model Declaration
-----------------

Inside the `main` function, your model structure is declared. This includes declaration of agent and message types. We recommend the following structure For
model declaration:

- ModelDescription
- Message types
- Agent types
- Environment
- Function dependencies

Initialisation
--------------

This is where populations of agents are created and the initial conditions of your simulation are defined. This might either be done in code or loaded from file. 

Execution
---------

The simulation is run and any relevant data is collected.
 