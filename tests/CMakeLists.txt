find_package(GTest REQUIRED)

add_executable(${PROJECT_NAME}_tests test_main.cpp)

target_compile_features(${PROJECT_NAME}_tests PRIVATE cxx_std_23)

target_include_directories(${PROJECT_NAME}_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}_tests PRIVATE
    GTest::gtest
    GTest::gtest_main
)

include(GoogleTest)
gtest_discover_tests(${PROJECT_NAME}_tests DISCOVERY_MODE PRE_TEST)
