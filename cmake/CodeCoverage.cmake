option(ENABLE_COVERAGE "Enable code coverage reporting" OFF)
set(COVERAGE_THRESHOLD 80 CACHE STRING "Minimum code coverage percentage (0-100)")

if(ENABLE_COVERAGE)
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(WARNING "Code coverage requires GCC or Clang. Disabling coverage.")
        set(ENABLE_COVERAGE OFF)
        return()
    endif()

    message(STATUS "Code coverage enabled (threshold: ${COVERAGE_THRESHOLD}%)")

    add_compile_options(--coverage)
    add_link_options(--coverage)

    find_program(LCOV_EXECUTABLE NAMES lcov)
    find_program(GENHTML_EXECUTABLE NAMES genhtml)
    
    # Find gcov that matches the compiler
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        # Extract GCC version and find matching gcov
        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
            OUTPUT_VARIABLE GCC_VERSION
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        string(REGEX MATCH "^[0-9]+" GCC_VERSION_MAJOR "${GCC_VERSION}")
        find_program(GCOV_EXECUTABLE NAMES gcov-${GCC_VERSION_MAJOR} gcov)
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        # For Clang, try to find versioned gcov first, then fall back to gcov
        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
            OUTPUT_VARIABLE CLANG_VERSION
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        string(REGEX MATCH "^[0-9]+" CLANG_VERSION_MAJOR "${CLANG_VERSION}")
        find_program(GCOV_EXECUTABLE NAMES gcov-${CLANG_VERSION_MAJOR} gcov)
    endif()
    
    if(NOT GCOV_EXECUTABLE)
        message(WARNING "gcov not found. Coverage target will not be available.")
        return()
    endif()
    
    message(STATUS "Using gcov: ${GCOV_EXECUTABLE}")

    if(LCOV_EXECUTABLE AND GENHTML_EXECUTABLE)
        set(COVERAGE_DIR "${CMAKE_BINARY_DIR}/coverage")

        add_custom_target(coverage
            COMMAND ${CMAKE_COMMAND} -E make_directory ${COVERAGE_DIR}
            COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}
                ${LCOV_EXECUTABLE} --capture --directory . --output-file ${COVERAGE_DIR}/coverage.info
                --gcov-tool ${GCOV_EXECUTABLE}
                --ignore-errors mismatch,format,unsupported,version,empty
            COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}
                ${LCOV_EXECUTABLE} --remove ${COVERAGE_DIR}/coverage.info
                '/usr/*' '*/tests/*' '*/build/*' '*/external/*'
                --output-file ${COVERAGE_DIR}/coverage_filtered.info
                --gcov-tool ${GCOV_EXECUTABLE}
                --ignore-errors unused,format,unsupported,version,empty
            COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}
                ${GENHTML_EXECUTABLE} ${COVERAGE_DIR}/coverage_filtered.info
                --output-directory ${COVERAGE_DIR}/html
                --title "${PROJECT_NAME} Code Coverage"
                --legend --show-details
            COMMAND ${CMAKE_COMMAND} -E echo "Coverage report generated at: ${COVERAGE_DIR}/html/index.html"
            COMMAND ${CMAKE_COMMAND}
                -DCOVERAGE_FILE=${COVERAGE_DIR}/coverage_filtered.info
                -DCOVERAGE_THRESHOLD=${COVERAGE_THRESHOLD}
                -P ${CMAKE_SOURCE_DIR}/cmake/CheckCoverageThreshold.cmake
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Generating code coverage report..."
        )

        add_custom_command(TARGET coverage PRE_BUILD
            COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}
                ${LCOV_EXECUTABLE} --zerocounters --directory .
                --gcov-tool ${GCOV_EXECUTABLE}
            COMMENT "Resetting coverage counters..."
        )
    else()
        message(WARNING "lcov or genhtml not found. Coverage target will not be available.")
        message(STATUS "Install lcov: apt-get install lcov (Linux) or brew install lcov (macOS)")
    endif()
endif()
