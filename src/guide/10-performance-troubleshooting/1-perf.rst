Performance Troubleshooting
===========================

**Why is my code slower than the equivalent CPU version?**
For a small number of agents, the GPU code may be slower than its equivalent CPU code. This is because of the overheads of transferring data
to and from the GPU, and the fact that CPUs have higher individual thread performance. As you increase your population size, the GPU
will outscale the CPU dramatically as it is able to carry out many more computations at once.

**My program slows down dramatically as I increase the number of agents**
If you find your program is scaling poorly, consider whether you are using the most appropriate message communication strategy. 
Brute force messaging will scale poorly as the number of agents increases. Consider whether bucket or spatial messaging could be 
used instead.

**My program is still slow**
Consider whether you can adapt your model and its algorithms to increase the parallelism. Serial components will almost always be
slower than parallel ones. If your program is still slow and you are unsure why, you could consider using the NVIDIA profiling 
tools to see which parts of your code are consuming the most runtime. 