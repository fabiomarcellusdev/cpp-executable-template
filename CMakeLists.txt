cmake_minimum_required(VERSION 3.27)

project(
    cpp_executable_template
    VERSION 0.1.0
    DESCRIPTION "A professional C++ executable project template"
    LANGUAGES CXX
)

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(MSVC)
    add_compile_options(/W4 /WX /permissive- /w14640)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -Wsign-conversion -Wcast-qual -Wformat=2 -Wundef -Wnull-dereference -Wdouble-promotion -Wimplicit-fallthrough)
endif()

include(cmake/ConanSetup.cmake)
include(cmake/CodeCoverage.cmake)
include(cmake/Sanitizers.cmake)

enable_testing()
add_subdirectory(src)
add_subdirectory(tests)

include(cmake/LintTargets.cmake)
