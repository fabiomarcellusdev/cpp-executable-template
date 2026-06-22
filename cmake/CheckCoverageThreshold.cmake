# CheckCoverageThreshold.cmake
# Parses lcov coverage data and fails if coverage is below threshold
#
# Usage:
#   cmake -DCOVERAGE_FILE=path/to/coverage.info -DCOVERAGE_THRESHOLD=80 -P CheckCoverageThreshold.cmake

if(NOT DEFINED COVERAGE_FILE)
    message(FATAL_ERROR "COVERAGE_FILE is not defined")
endif()

if(NOT DEFINED COVERAGE_THRESHOLD)
    set(COVERAGE_THRESHOLD 80)
endif()

if(NOT EXISTS "${COVERAGE_FILE}")
    message(FATAL_ERROR "Coverage file not found: ${COVERAGE_FILE}")
endif()

# Read the coverage file
file(READ "${COVERAGE_FILE}" COVERAGE_CONTENT)

# Extract line coverage percentage
# lcov format: LH:<lines hit> LF:<lines found>
string(REGEX MATCHALL "LF:([0-9]+)" LF_ALL "${COVERAGE_CONTENT}")
string(REGEX MATCHALL "LH:([0-9]+)" LH_ALL "${COVERAGE_CONTENT}")

if(NOT LF_ALL OR NOT LH_ALL)
    message(FATAL_ERROR "Could not parse coverage data from ${COVERAGE_FILE}")
endif()

set(LINES_FOUND 0)
set(LINES_HIT 0)

foreach(LF_ENTRY IN LISTS LF_ALL)
    string(REGEX REPLACE "LF:([0-9]+)" "\\1" VALUE "${LF_ENTRY}")
    math(EXPR LINES_FOUND "${LINES_FOUND} + ${VALUE}")
endforeach()

foreach(LH_ENTRY IN LISTS LH_ALL)
    string(REGEX REPLACE "LH:([0-9]+)" "\\1" VALUE "${LH_ENTRY}")
    math(EXPR LINES_HIT "${LINES_HIT} + ${VALUE}")
endforeach()

if(LINES_FOUND EQUAL 0)
    message(FATAL_ERROR "No lines found in coverage data")
endif()

# Calculate percentage
math(EXPR COVERAGE_PERCENT "(${LINES_HIT} * 100) / ${LINES_FOUND}")

message(STATUS "Coverage: ${LINES_HIT}/${LINES_FOUND} lines (${COVERAGE_PERCENT}%)")
message(STATUS "Threshold: ${COVERAGE_THRESHOLD}%")

if(COVERAGE_PERCENT LESS COVERAGE_THRESHOLD)
    message(FATAL_ERROR
        "Code coverage ${COVERAGE_PERCENT}% is below the required threshold of ${COVERAGE_THRESHOLD}%. "
        "Please add more tests to increase coverage."
    )
else()
    message(STATUS "Coverage check passed: ${COVERAGE_PERCENT}% >= ${COVERAGE_THRESHOLD}%")
endif()
