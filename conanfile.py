from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain, CMakeDeps, cmake_layout


class CppExecutableTemplate(ConanFile):
    name = "cpp_executable_template"
    version = "0.1.0"
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps"

    def configure(self):
        self.settings.compiler.cppstd = "23"

    def requirements(self):
        self.requires("gtest/1.14.0")

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate_presets = False
        tc.generate()

    def layout(self):
        cmake_layout(self)

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
