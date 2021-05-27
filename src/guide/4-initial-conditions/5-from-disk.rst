Initialisation from Disk
========================

FLAMEGPU2 simulations can be initialised from disk using either the XML or JSON format. The format is described **TODO: Link to format**

To load the file, supply the **TODO: which switch** switch to the program, followed by the path to the XML or JSON file. 
For example

`...` 

will run the program '...' initialised with `....JSON`.

Agent IDs must be unique when the file is loaded from disk. There is no way to fix this programmatically within FLAME, it must be corrected in the intiialisation file.
