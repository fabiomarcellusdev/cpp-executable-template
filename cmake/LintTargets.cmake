option(ENABLE_LINTING "Enforce formatting and linting during build" OFF)

find_program(CLANG_FORMAT_EXECUTABLE NAMES clang-format)
find_program(CLANG_TIDY_EXECUTABLE NAMES clang-tidy)

file(GLOB_RECURSE ALL_SOURCE_FILES
    ${CMAKE_SOURCE_DIR}/src/*.cpp
    ${CMAKE_SOURCE_DIR}/src/*.hpp
    ${CMAKE_SOURCE_DIR}/src/*.h
    ${CMAKE_SOURCE_DIR}/include/*.hpp
    ${CMAKE_SOURCE_DIR}/include/*.h
    ${CMAKE_SOURCE_DIR}/tests/*.cpp
    ${CMAKE_SOURCE_DIR}/tests/*.hpp
    ${CMAKE_SOURCE_DIR}/tests/*.h
)

file(GLOB_RECURSE ALL_HEADER_FILES
    ${CMAKE_SOURCE_DIR}/include/*.hpp
    ${CMAKE_SOURCE_DIR}/include/*.h
)

if(CLANG_FORMAT_EXECUTABLE AND ALL_SOURCE_FILES)
    add_custom_target(format-check
        COMMAND ${CLANG_FORMAT_EXECUTABLE} --dry-run --Werror ${ALL_SOURCE_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Checking code formatting..."
    )

    add_custom_target(format-fix
        COMMAND ${CLANG_FORMAT_EXECUTABLE} -i ${ALL_SOURCE_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Fixing code formatting..."
    )
else()
    if(NOT CLANG_FORMAT_EXECUTABLE)
        message(WARNING "clang-format not found. Format targets will not be available.")
    endif()
endif()

if(CLANG_TIDY_EXECUTABLE)
    add_custom_target(lint
        COMMAND ${CLANG_TIDY_EXECUTABLE} -p ${CMAKE_BINARY_DIR} ${ALL_SOURCE_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running clang-tidy..."
    )
else()
    message(WARNING "clang-tidy not found. Lint target will not be available.")
endif()

add_custom_target(check-headers
    COMMAND ${CMAKE_COMMAND}
        -DHEADER_DIR=${CMAKE_SOURCE_DIR}/include
        -P ${CMAKE_SOURCE_DIR}/cmake/CheckPragmaOnce.cmake
    COMMENT "Checking headers for #pragma once..."
)

if(ENABLE_LINTING)
    if(CLANG_FORMAT_EXECUTABLE AND ALL_SOURCE_FILES)
        add_dependencies(${PROJECT_NAME} format-check)
    endif()
    if(CLANG_TIDY_EXECUTABLE)
        set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY_EXECUTABLE} PARENT_SCOPE)
    endif()
    add_dependencies(${PROJECT_NAME} check-headers)
endif()
