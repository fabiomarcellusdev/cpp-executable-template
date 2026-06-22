#include <gtest/gtest.h>

#include "my_project_name/greeting.hpp"

TEST(GreetingTest, ReturnsHelloWorld) {
    EXPECT_EQ(my_project_name::get_greeting(), "Hello, World!");
}

TEST(GreetingTest, IsNotEmpty) {
    EXPECT_FALSE(my_project_name::get_greeting().empty());
}
