# @todo - expand this to actually be graphviz not just dot.
# Look for the dot executable belonging to graphviz
find_program(GRAPHVIZ_DOT_EXECUTABLE
             NAMES dot
             DOC "Path to graphviz dot executable")
 
include(FindPackageHandleStandardArgs)
 
# Handle standard arguments to find_package like REQUIRED and QUIET
find_package_handle_standard_args(Graphviz
                                  "Failed to find dot executable"
                                  GRAPHVIZ_DOT_EXECUTABLE)

mark_as_advanced(GRAPHVIZ_DOT_EXECUTABLE)