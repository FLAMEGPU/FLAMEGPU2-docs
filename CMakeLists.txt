cmake_minimum_required(VERSION VERSION 3.12 FATAL_ERROR)

# Name the project and set languages
project(userguide NONE)

# Don't create installation scripts (and hide CMAKE_INSTALL_PREFIX from cmake-gui)
set(CMAKE_SKIP_INSTALL_RULES TRUE)
set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE INTERNAL "" FORCE)

# https://cmake.org/cmake/help/latest/module/FindPython3.html#module:FindPython3
# find_package(Python3 COMPONENTS Interpreter REQUIRED)

# Add the cmake folder so the FindSphinx module is found
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
find_package(Sphinx REQUIRED)

set(SPHINX_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/src")
set(SPHINX_BUILD "${CMAKE_CURRENT_BINARY_DIR}/userguide")
set(SPHINX_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/src")
# set(SPHINX_CAHCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_doctrees")

# Option to promote compilation warnings to error, useful for strict CI
option(WARNINGS_AS_ERRORS "Promote compilation warnings to errors" OFF)

# Find graphviz which is required for the user guide (sphinx graphviz plugin)
find_package(Graphviz REQUIRED)

find_package(FLAMEGPU2)
# Build Doxygen if we can
if(FLAMEGPU2_FOUND)
    # Load FLAMEGPU2s Doxygen config, implicitly calls find_package(doxygen)
    include(${FLAMEGPU_ROOT}/cmake/dependencies/doxygen.cmake)
    mark_as_advanced(FORCE BUILD_API_DOCUMENTATION)
else()
    set(BUILD_API_DOCUMENTATION "OFF")
endif()

# Define the list of known docs source files, so they can be copied into the build directory. 
# Globbing is not viable as adding new files would not trigger a new incremental build.
# Does not include .in files, which are managed separately.
set(DOCS_SRC_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/agent-functions/agent-birth-death.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/agent-functions/agent-communication.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/agent-functions/conditional-behaviours.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/agent-functions/defining-agent-functions.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/agent-functions/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/agent-functions/interacting-with-environment.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/agent-functions/miscellaneous.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/agent-functions/modifying-agent-variables.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/agent-functions/random-numbers.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/creating-a-model/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/logging.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/NB_cycle_stages_6x512.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/NB_living_countx512.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/NB_MYCNx512.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/NB_telo_countx512.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/print.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/seatbelts.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/using-a-debugger.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/visual_studio_attach_to_process_dialog.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/visual_studio_build_config.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/visual_studio_startup_project.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/debugging-models/visual_studio_start_debugger.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/defining-agents/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/defining-execution-order/dependency-graph.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/defining-execution-order/exit-conditions.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/defining-execution-order/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/defining-execution-order/layers.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/defining-execution-order/submodels.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/defining-messages-communication/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/environment/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/flamegpu2-source/build-from-source.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/flamegpu2-source/contribute.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/flamegpu2-source/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/flamegpu2-source/request-a-new-feature.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/host-functions/agent-operations.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/host-functions/defining-host-functions.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/host-functions/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/host-functions/interacting-with-environment.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/host-functions/miscellaneous.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/host-functions/random-numbers.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/performance-troubleshooting/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/running-a-simulation/collecting-data.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/running-a-simulation/configuring-execution.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/running-a-simulation/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/running-a-simulation/initial-state.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/running-multiple-simulations/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/visualisation/ui-full.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/visualisation/ui-collapsed.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/visualisation/adding-details.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/visualisation/building-with-vis.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/visualisation/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/visualisation/setting-up-vis.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/visualisation/visualisation-controls.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/guide/visualisation/visualising-agents.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/quickstart/cmake-generator.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/quickstart/cmake-gui-annotated.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/quickstart/cmake-gui.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/quickstart/index.rst"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/_static/css/flamegpu.css"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/_static/img/flamegpu2-icon-notext-128.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/tutorial/index.rst"
)

# Get the relative path to the SRC directory from the current build directory
file(RELATIVE_PATH RELPATH_CONFIG_TO_STATIC "${SPHINX_CONFIG_DIR}" "${SPHINX_SOURCE}/_static")

# Get the path to the exhalecontainment folder, relative to the config folder.
set(EXHALE_CONTAINMENT_FOLDER_ABS "${SPHINX_SOURCE}/api")
file(RELATIVE_PATH EXHALE_CONTAINMENT_FOLDER "${SPHINX_CONFIG_DIR}" "${EXHALE_CONTAINMENT_FOLDER_ABS}")

# Add custom commands to copy each listed source file from the source directory into the build directory. To fix true out-of-tree builds.
set(BUILD_SRC_DEPENDS)
foreach(SRC_FILE IN LISTS DOCS_SRC_FILES)
    file(RELATIVE_PATH SRC_FILE_CLEAN "${CMAKE_CURRENT_SOURCE_DIR}" "${SRC_FILE}")
    set(BUILD_SRC_FILE "${CMAKE_CURRENT_BINARY_DIR}/${SRC_FILE_CLEAN}")
    add_custom_command(
        OUTPUT  ${BUILD_SRC_FILE}
        DEPENDS ${SRC_FILE} ${CMAKE_CURRENT_BINARY_DIR}/src/index.rst
        COMMAND ${CMAKE_COMMAND} -E copy "\"${SRC_FILE}\"" "\"${BUILD_SRC_FILE}\""
        COMMENT "Copying '${SRC_FILE}' to '${BUILD_SRC_FILE}'"
    )
    list(APPEND BUILD_SRC_DEPENDS "${BUILD_SRC_FILE}")
    unset(BUILD_SRC_FILE)
    unset(SRC_FILE_CLEAN)
endforeach()


# Set the warnings_is_errors value if enabeld.
set(SPHINX_WARNING_IS_ERROR_FLAG "")
if (WARNINGS_AS_ERRORS)
    set(SPHINX_WARNING_IS_ERROR_FLAG "-W")
endif()
if(FLAMEGPU2_FOUND AND DOXYGEN_FOUND AND ${BUILD_API_DOCUMENTATION})
    # Set the var used when generating conf.py to enable breathe/exhale 
    set(USE_BREATHE_EXHALE "True")
    set(EXCLUDE_API_PATTERN "") # Do not exlude the api dir
    # Decide path to temp store the xml output, used in conf.py generation.
    set(API_DOCS_XML_PATH "api_xml")

    # Generate conf.py in the build directory
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.py.in"
        "${CMAKE_CURRENT_BINARY_DIR}/src/conf.py"
        @ONLY
    )
    list(APPEND BUILD_SRC_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/src/conf.py")
    unset(USE_BREATHE_EXHALE)
    unset(EXCLUDE_API_PATTERN)
    set(API_TOC_PATH "api/library_root")
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/src/index.rst.in"
        "${CMAKE_CURRENT_BINARY_DIR}/src/index.rst"
        @ONLY
    )
    list(APPEND BUILD_SRC_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/src/index.rst")
    unset(API_TOC_PATH)

    # Create Doxygen target 'userguide_docs_xml'
    create_doxygen_target("${FLAMEGPU_ROOT}" "${CMAKE_CURRENT_BINARY_DIR}" "src/${API_DOCS_XML_PATH}")
    # Create Sphinx target
    add_custom_target(userguide ALL
        COMMAND ${SPHINX_EXECUTABLE} -b html
        ${SPHINX_WARNING_IS_ERROR_FLAG}
        -c "${SPHINX_CONFIG_DIR}"
        ${SPHINX_SOURCE} ${SPHINX_BUILD}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        BYPRODUCTS ${EXHALE_CONTAINMENT_FOLDER_ABS} ${SPHINX_BUILD} ${CMAKE_CURRENT_BINARY_DIR}/src/conf.py
        DEPENDS ${BUILD_SRC_DEPENDS}
        )
    # Make Sphinx target depend on Doxygen target
    add_dependencies(userguide api_docs_xml)
else()
    # Set the var used when generating conf.py to disable breathe/exhale 
    set(USE_BREATHE_EXHALE "False")
    # exclude the api dir via pattern in the conf.py incase it exists.
    set(EXCLUDE_API_PATTERN ", 'api'")
    # Generate conf.py in the build directory
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.py.in"
        "${CMAKE_CURRENT_BINARY_DIR}/src/conf.py"
        @ONLY
    )
    list(APPEND BUILD_SRC_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/src/conf.py")
    unset(USE_BREATHE_EXHALE)
    unset(EXCLUDE_API_PATTERN)
    set(API_TOC_PATH "") # set the include line to the emtpy str
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/src/index.rst.in"
        "${CMAKE_CURRENT_BINARY_DIR}/src/index.rst"
        @ONLY
    )
    list(APPEND BUILD_SRC_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/src/index.rst")
    unset(API_TOC_PATH)
    # Create the custom target with appropriate command.
    add_custom_target(userguide ALL
        COMMAND ${SPHINX_EXECUTABLE} -b html
        ${SPHINX_WARNING_IS_ERROR_FLAG}
        -c "${SPHINX_CONFIG_DIR}"
        ${SPHINX_SOURCE} ${SPHINX_BUILD}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        BYPRODUCTS ${SPHINX_BUILD} ${CMAKE_CURRENT_BINARY_DIR}/src/conf.py
        DEPENDS ${BUILD_SRC_DEPENDS}
    )
endif()
