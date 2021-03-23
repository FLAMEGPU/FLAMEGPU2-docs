#Look for a file we expect to always exist
find_path(FLAMEGPU2_ROOT src/flamegpu/exception/FGPUException.cpp
    HINTS
        $ENV{FLAMEGPU2_ROOT}
        ${FLAMEGPU2_ROOT}
        "${PROJECT_SOURCE_DIR}/../FGPU2"
        "${PROJECT_SOURCE_DIR}/../FLAMEGPU2"
        "${PROJECT_SOURCE_DIR}/../FLAMEGPU2_DEV"
        "${PROJECT_SOURCE_DIR}/../fgpu2"
        "${PROJECT_SOURCE_DIR}/../flamegpu2"
        "${PROJECT_SOURCE_DIR}/../flamegpu2_dev"
    DOC "Path to clone of FLAMEGPU2 source repository"
)
 
include(FindPackageHandleStandardArgs)
 
#Handle standard arguments to find_package like REQUIRED and QUIET
find_package_handle_standard_args(FLAMEGPU2
                                  "Failed to find FLAMEGPU2 root"
                                  FLAMEGPU2_ROOT)