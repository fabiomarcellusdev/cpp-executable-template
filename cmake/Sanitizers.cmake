option(ENABLE_SANITIZERS "Enable AddressSanitizer and UndefinedBehaviorSanitizer" OFF)

if(ENABLE_SANITIZERS)
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(WARNING "Sanitizers require GCC or Clang. Disabling sanitizers.")
        set(ENABLE_SANITIZERS OFF)
        return()
    endif()

    message(STATUS "Sanitizers enabled (AddressSanitizer + UndefinedBehaviorSanitizer)")

    set(SANITIZER_FLAGS
        -fsanitize=address
        -fsanitize=undefined
        -fno-omit-frame-pointer
    )

    add_compile_options(${SANITIZER_FLAGS})
    add_link_options(${SANITIZER_FLAGS})

    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        add_compile_options(-fsanitize-recover=undefined)
        add_link_options(-fsanitize-recover=undefined)
    endif()
endif()
