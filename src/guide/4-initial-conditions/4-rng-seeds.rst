Random Number Generation
========================

Agent variables can be initialised with randomly generated data:

.. tabs::

  .. code-tab:: python

    # Set the min and max initial positions
    min_pos = -2.0f
    max_pos = 2.0f

    # For each agent
    for i in range(populationSize):
        instance = population[i]

        # Randomly initialise the x, y and z variables with values between min_pos and max_pos
        instance.setVariableFloat("x", random.uniform(min_pos, max_pos))
        instance.setVariableFloat("y", random.uniform(min_pos, max_pos))
        instance.setVariableFloat("z", random.uniform(min_pos, max_pos))

  .. code-tab:: cpp

    // Use the standard C++ library mt19937 random number generator
    std::mt19937 rngEngine(cuda_model.getSimulationConfig().random_seed);

    // Create a distribution to sample
    int min_position = -2.0f;
    int max_position = 2.0f;
    std::uniform_real_distribution<float> position_distribution(min_position, max_position);

    // For each agent
    for (unsigned int i = 0; i < populationSize; i++) {
        AgentVector::Agent instance = population[i];

        // Randomly initialise the x, y and z variables with values between min_pos and max_pos
        instance.setVariable<float>("x", position_distribution(rngEngine));
        instance.setVariable<float>("y", position_distribution(rngEngine));
        instance.setVariable<float>("z", position_distribution(rngEngine));
    }