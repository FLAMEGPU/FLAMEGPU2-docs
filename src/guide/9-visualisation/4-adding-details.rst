Visualising Additional Details
==============================

In addition to visualising agents, you may wish to visualise the environment bounding box, or environment properties.


Lines
-----

FLAME GPU visualisations allow you to define static line drawings, from either line segments or a single polyline as part of the visualisation config.

These can be useful to denote the bounding area of the environment, or other details.

.. tabs::

  .. code-tab:: cuda CUDA C++

    // Configure the visualisation
    flamegpu::visualiser::ModelVis &m_vis = cudaSimulation.getVisualisation();
    // Draw a square out of line segments, white 20% alpha
    flamegpu::visualiser::LineVis pen = m_vis.newLineSketch(1.0f, 1.0f, 1.0f, 0.2f);
    pen.addVertex(0.0f, 0.0f, 0.0f); pen.addVertex(1.0f, 0.0f, 0.0f);
    pen.addVertex(1.0f, 0.0f, 0.0f); pen.addVertex(1.0f, 0.0f, 1.0f);
    pen.addVertex(1.0f, 0.0f, 1.0f); pen.addVertex(0.0f, 0.0f, 1.0f);
    pen.addVertex(0.0f, 0.0f, 1.0f); pen.addVertex(0.0f, 0.0f, 0.0f);
    // Or, draw a square out of a single poly-line, red 50% alpha
    flamegpu::visualiser::LineVis pen2 = m_vis.newPolylineSketch(1.0f, 0.0f, 0.0f, 0.5f);
    pen.addVertex(0.0f, 0.0f, 0.0f);
    pen.addVertex(1.0f, 0.0f, 0.0f);
    pen.addVertex(1.0f, 0.0f, 1.0f);
    pen.addVertex(0.0f, 0.0f, 1.0f);
    pen.addVertex(0.0f, 0.0f, 0.0f);
    
  .. code-tab:: python

    # Configure the visualisation
    m_vis = cudaSimulation.getVisualisation();
    # Draw a square out of line segments, white 20% alpha
    pen = m_vis.newLineSketch(1.0, 1.0, 1.0, 0.2);
    pen.addVertex(0.0, 0.0, 0.0); pen.addVertex(1.0, 0.0, 0.0);
    pen.addVertex(1.0, 0.0, 0.0); pen.addVertex(1.0, 0.0, 1.0);
    pen.addVertex(1.0, 0.0, 1.0); pen.addVertex(0.0, 0.0, 1.0);
    pen.addVertex(0.0, 0.0, 1.0); pen.addVertex(0.0, 0.0, 0.0);
    # Or, draw a square out of a single polyline, red 50% alpha
    pen2 = m_vis.newPolylineSketch(1.0, 0.0, 0.0, 0.5);
    pen.addVertex(0.0, 0.0, 0.0);
    pen.addVertex(1.0, 0.0, 0.0);
    pen.addVertex(1.0, 0.0, 1.0);
    pen.addVertex(0.0, 0.0, 1.0);
    pen.addVertex(0.0, 0.0, 0.0);

It is not currently possible to update these line drawings during a model's execution, however we may add support for this in future.


Models
------
If your environment is instead represented by a 3D model, it is possible to load it into the visualisation. Like the models representing agent's, currently only the ``.obj`` (wavefront) format is supported.

After specifying the location of the model, a translation, scaling and rotation can be specified if required.

.. tabs::

  .. code-tab:: cuda CUDA C++

    // Configure the visualisation
    flamegpu::visualiser::ModelVis &m_vis = cudaSimulation.getVisualisation();
    // Add the environment's model
    flamegpu::visualiser::StaticModelVis env_model = m_vis.addStaticModel("myfiles/town.obj");
    // Configure the model
    env_model.setModelScale(10.0f, 5.0f, 1.0f);
    env_model.setModelLocation(0.0f, -5.0f, 0.0f);
    env_model.setModelRotation(0.0f, 1.0f, 0.0f, 3.141/2.0f);
    
  .. code-tab:: python

    # Configure the visualisation
    m_vis = cudaSimulation.getVisualisation();
    # Add the environment's model
    env_model = m_vis.addStaticModel("myfiles/town.obj");
    # Configure the model
    env_model.setModelScale(10.0f, 5.0f, 1.0f);
    env_model.setModelLocation(0.0f, -5.0f, 0.0f);
    env_model.setModelRotation(0.0f, 1.0f, 0.0f, 3.141/2.0f);