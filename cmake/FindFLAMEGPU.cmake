#  Look for a file we expect to always exist. version.h is dynamically created so cannot be relied upon
find_path(FLAMEGPU_ROOT include/flamegpu/defines.h
    HINTS
        $ENV{FLAMEGPU_ROOT}
        ${FLAMEGPU_ROOT}
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
find_package_handle_standard_args(FLAMEGPU
                                  "Failed to find FLAMEGPU root"
                                  FLAMEGPU_ROOT)