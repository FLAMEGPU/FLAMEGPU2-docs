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

set(SPHINX_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(SPHINX_BUILD "${CMAKE_CURRENT_BINARY_DIR}/userguide")
set(SPHINX_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}")
# set(SPHINX_CAHCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_doctrees")

find_package(FLAMEGPU2)
# Build Doxygen if we can
if(FLAMEGPU2_FOUND)
    # Load FGPU2s Doxygen config, implicitly calls find_package(doxygen)
    include(${FLAMEGPU2_ROOT}/cmake/doxygen.cmake)
    mark_as_advanced(FORCE BUILD_API_DOCUMENTATION)
endif()

# Get the relative path to the SRC directory from the current build directory
file(RELATIVE_PATH RELPATH_CONFIG_TO_STATIC "${SPHINX_CONFIG_DIR}" "${SPHINX_SOURCE}/_static")

# Get the path to the exhalecontainment folder, relative to the config folder.
set(EXHALE_CONTAINMENT_FOLDER_ABS "${SPHINX_SOURCE}/api")
file(RELATIVE_PATH EXHALE_CONTAINMENT_FOLDER "${SPHINX_CONFIG_DIR}" "${EXHALE_CONTAINMENT_FOLDER_ABS}")

message("FLAMEGPU2_FOUND ${FLAMEGPU2_FOUND}")
if(FLAMEGPU2_FOUND AND DOXYGEN_FOUND)
    # Set the var used when generating conf.py to enable breathe/exhale 
    set(USE_BREATHE_EXHALE "True")
    # Decide path to temp store the xml output, used in conf.py generation.
    set(API_DOCS_XML_PATH "api_xml")

    # Generate conf.py in the build directory
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.py.in"
        "${CMAKE_CURRENT_BINARY_DIR}/conf.py"
        @ONLY
    )

    # Disabling this setting might break stuff
    if(${BUILD_API_DOCUMENTATION})
        # Create Doxygen target 'userguide_docs_xml'
        create_doxygen_target("${FLAMEGPU2_ROOT}" "${CMAKE_CURRENT_BINARY_DIR}" "${API_DOCS_XML_PATH}")
    endif()
    # Create Sphinx target
    add_custom_target(userguide ALL
        COMMAND ${SPHINX_EXECUTABLE} -b html
        -c "${SPHINX_CONFIG_DIR}"
        ${SPHINX_SOURCE} ${SPHINX_BUILD}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        BYPRODUCTS ${EXHALE_CONTAINMENT_FOLDER_ABS} ${SPHINX_BUILD}
        )
    # Make Sphinx target depend on Doxygen target
    add_dependencies(userguide api_docs_xml)
else()
    # Set the var used when generating conf.py to disable breathe/exhale 
    set(USE_BREATHE_EXHALE "False")
    # Generate conf.py in the build directory
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.py.in"
        "${CMAKE_CURRENT_BINARY_DIR}/conf.py"
        @ONLY
    )
    # Create the custom target with appropriate command.
    add_custom_target(userguide ALL
        COMMAND ${SPHINX_EXECUTABLE} -b html
        -c "${SPHINX_CONFIG_DIR}"
        ${SPHINX_SOURCE} ${SPHINX_BUILD}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        BYPRODUCTS ${SPHINX_BUILD}
    )
endif()

# @todo - api docs .RST should not be built into the src dir - they are part of the build (and should be in the build dir). **But** EXHALE_CONTAINMENT_FOLDER **must** be a child of SPHINX_SOURCE. Probably either need to copy src/ into build, and use that as the sphinx source, or do soemthing with symlinks? Either option is grim.
