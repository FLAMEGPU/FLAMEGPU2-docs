FLAMEGPU2 Design Philosophy
===========================

FLAME GPU has the aim of accelerating the performance and scale of agent-based simulation by targeting readily available parallelism in the form of Graphics Processing Units (GPUs). A central idea behind FLAME GPU is to abstract the GPU away from modellers so that modellers can build models without having to worry about writing parallel code. FLAME GPU also separates a model description from the model implementation. This simplifies the processes of validating and verifying models as the simulator code is tested in isolation from the model itself.

FLAME GPU started in the early days of general purpose computing on GPUs. GPU hardware and software development approaches have changed significantly since the inception of FLAME GPU, as such version 2.0 is a complete re-write of the library. It shifts from the FLAME GPU 1 architecture of template driven agent based modelling towards a modern C++ API with a cleaner interface for the specification of agent behaviour. It also adds a range of new features which ensure performant model simulation. E.g.

* Support for Big GPUs - Support for concurrent execution of agents functions which ensures that heterogenous models do not necessarily result in poor device utilisation.
* Model Ensembles - The ability to run ensembles of models. I.e. the same model with different parameters or random seeds. This is necessary within stochastic simulation and FLAME GPU allows the specification of ensembles to occupy multiple devices on a single computing node.
* Sub models - Certain behaviours in FLAME GPU require iterative processes to ensure reproducibility with serial counterparts (e.g. conflict resolution for resources). FLAME GPU 2 allows re-usable sub models to be described for such behaviours so that it can be abstracted from the rest of the model function.
