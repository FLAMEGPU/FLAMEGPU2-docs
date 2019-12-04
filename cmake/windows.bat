IF NOT "%1"=="" (
    SET BUILD_DIR=%1
) else (
    SET BUILD_DIR=../build
    echo Build directory not set, defaulting to '%BUILD_DIR%'
)
mkdir %BUILD_DIR%
mkdir %BUILD_DIR%/api_xml
mkdir %BUILD_DIR%/userguide
if exist "%BUILD_DIR%/Doxyfile.api_docs_xml" (
    doxygen "%BUILD_DIR%/Doxyfile.api_docs_xml"
    sphinx-build -b html -Dbreathe_projects."FLAME GPU 2"="%BUILD_DIR%/api_xml" "../src" "%BUILD_DIR%/userguide"
) else (
    echo "%BUILD_DIR%/Doxyfile.api_docs_xml" was not found, execute CMake first if api documentation is required.
    sphinx-build -b html "../src" "%BUILD_DIR%/userguide"
)
pause