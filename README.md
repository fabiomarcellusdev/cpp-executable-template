# cpp-executable-template

A professional C++ executable project template using **CMake**, **Conan**, and **C++23**. This repository provides a ready-to-use starting point for building C++ applications with a clean, scalable folder structure, strict compiler settings, and modern tooling.

---

## Quick Start

```bash
# 1. Install dependencies via Conan
conan install . --build=missing

# 2. Configure the project
cmake --preset conan-release

# 3. Build
cmake --build --preset conan-release

# 4. Run
./build/Release/cpp_executable_template

# 5. Run tests
ctest --preset conan-release
```

---

## Project Structure

```
cpp-executable-template/
├── CMakeLists.txt              # Root CMake configuration
├── conanfile.py                # Conan 2.x package manager definition
├── README.md                   # This file
├── .gitignore                  # Git ignore rules
│
├── src/                        # Application source code
│   ├── CMakeLists.txt          # Executable target definition
│   └── main.cpp                # Entry point
│
├── include/                    # Project header files
│
├── lib/                        # Internal / vendored static libraries
│
├── tests/                      # Test source code
│   ├── CMakeLists.txt          # Test target definition
│   └── test_main.cpp           # Test entry point
│
├── cmake/                      # Custom CMake modules
│   └── ConanSetup.cmake        # Conan toolchain integration
│
├── scripts/                    # Build and utility scripts
│
├── docs/                       # Additional project documentation
│
└── external/                   # Vendored third-party source code
```

---

## Directory Guide

### `src/` — Application Source Code

This is where all application implementation files live. It contains the `main()` entry point and every `.cpp` file that makes up the executable.

**What goes here:**
- `main.cpp` — the program entry point
- All `.cpp` implementation files (e.g., `app.cpp`, `parser.cpp`, `config.cpp`)
- Subdirectories for organizing source by module if the project grows (e.g., `src/core/`, `src/io/`)

**What does NOT go here:**
- Header files (those belong in `include/`)
- Test files (those belong in `tests/`)
- Third-party code (those belong in `external/` or are managed by Conan)

The `src/CMakeLists.txt` defines the executable target, sets include paths to `include/`, and links any Conan-provided dependencies (e.g., `fmt`).

---

### `include/` — Project Header Files

Contains all project header files (`.hpp`, `.h`). Separating headers from source files keeps include paths clean and makes it straightforward to expose a public API if the project ever evolves into a library.

**What goes here:**
- All `.hpp` and `.h` files that declare interfaces used across translation units
- Headers organized in subdirectories that mirror the source layout (e.g., `include/core/app.hpp`)

**What does NOT go here:**
- Implementation files (`.cpp` — those belong in `src/`)
- Third-party headers (those belong in `external/` or are managed by Conan)

Headers in this directory are accessible via `#include "core/app.hpp"` because `src/CMakeLists.txt` adds `include/` to the target's include path.

---

### `lib/` — Internal Libraries

Reserved for internal or vendored static libraries that are compiled as part of the project but are logically separate from the main application. This is useful when your project contains reusable components that could theoretically be extracted into their own library.

**What goes here:**
- Self-contained utility libraries written as part of this project
- Each library should have its own `CMakeLists.txt` and be added via `add_subdirectory()` from the root

**What does NOT go here:**
- Third-party code downloaded from the internet (use `external/` or Conan)
- Main application source code (that belongs in `src/`)

---

### `tests/` — Test Source Code

Contains all unit and integration tests. The project uses **Google Test** (GTest) when available via Conan, and tests are automatically discovered by **CTest**.

**What goes here:**
- Test source files (`test_*.cpp` or `*_test.cpp`)
- Test-specific headers or fixtures
- The `CMakeLists.txt` that defines the test executable and registers tests with CTest

**What does NOT go here:**
- Application source code (that belongs in `src/`)
- Benchmark code (consider a separate `benchmarks/` directory if needed)

To add a new test file, add it to the `add_executable()` call in `tests/CMakeLists.txt`.

---

### `cmake/` — Custom CMake Modules

Contains CMake helper modules, custom `Find*.cmake` scripts, and toolchain integration files that the root `CMakeLists.txt` includes.

**What goes here:**
- `ConanSetup.cmake` — handles optional inclusion of the Conan-generated toolchain file
- Custom `Find<Package>.cmake` modules for dependencies not available through Conan
- CMake utility scripts (e.g., code coverage setup, sanitizers configuration)

**What does NOT go here:**
- Source code of any kind
- Build output (that goes in `build/` or `cmake-build-*/`, both of which are gitignored)

---

### `scripts/` — Build and Utility Scripts

Shell scripts, Python scripts, or other automation tools used during development, CI, or deployment.

**What goes here:**
- Build wrapper scripts (e.g., `build.sh`, `clean.sh`)
- CI pipeline helper scripts
- Code generation or preprocessing scripts
- Linting and formatting scripts (e.g., `run-clang-format.sh`)

**What does NOT go here:**
- CMake files (those belong in `cmake/`)
- Source code compiled into the executable (that belongs in `src/`)

---

### `docs/` — Project Documentation

Additional documentation beyond the root `README.md`. Use this for design documents, architecture diagrams, API references, or onboarding guides.

**What goes here:**
- Architecture or design documents (`.md`, `.drawio`, `.png`)
- API documentation
- Contributor guidelines
- Meeting notes or decision records relevant to the project

**What does NOT go here:**
- Source code or build scripts
- The main `README.md` (that stays at the repository root)

---

### `external/` — Vendored Third-Party Code

Third-party source code or libraries that are checked directly into the repository rather than managed through Conan. Use this sparingly — prefer Conan for dependency management whenever possible.

**What goes here:**
- Small, single-header libraries that are easier to vendor than to package
- Forked or patched versions of third-party code that require local modifications
- Each vendored dependency should live in its own subdirectory (e.g., `external/json/`)

**What does NOT go here:**
- Dependencies available through Conan (use `conanfile.py` instead)
- Your own project code (that belongs in `src/`, `include/`, or `lib/`)

---

## Root Files

### `CMakeLists.txt`

The root CMake configuration file. It:

- Sets the minimum CMake version to **3.27** (required for first-class C++23 support)
- Declares the project name, version, description, and language
- Configures the C++ standard to **C++23** with extensions disabled
- Enables `compile_commands.json` export for tooling (clangd, IDEs)
- Applies **strict compiler flags** (all warnings treated as errors)
- Includes the Conan toolchain setup from `cmake/ConanSetup.cmake`
- Enables CTest and adds `src/` and `tests/` as subdirectories

### `conanfile.py`

The Conan 2.x package definition. It:

- Declares the package name and version
- Specifies standard settings (`os`, `compiler`, `build_type`, `arch`)
- Uses `CMakeDeps` and `CMakeToolchain` generators for seamless CMake integration
- Defines `requirements()` where you add dependencies (e.g., `self.requires("fmt/10.2.1")`)
- Uses `cmake_layout()` for standardized build directory structure

To add a dependency, edit the `requirements()` method:

```python
def requirements(self):
    self.requires("fmt/10.2.1")
    self.requires("spdlog/1.13.0")
```

### `.gitignore`

Excludes build artifacts, IDE files, OS metadata, compiled binaries, and CMake-generated files from version control.

---

## Compiler Strictness

All warnings are treated as errors to enforce code quality from the start.

**GCC / Clang flags:**

| Flag | Purpose |
|---|---|
| `-Wall` | Enable common warnings |
| `-Wextra` | Enable additional warnings |
| `-Wpedantic` | Enforce strict ISO C++ compliance |
| `-Werror` | Treat all warnings as errors |
| `-Wshadow` | Warn on variable shadowing |
| `-Wconversion` | Warn on implicit type conversions |
| `-Wsign-conversion` | Warn on signed/unsigned conversions |
| `-Wcast-qual` | Warn on casts that remove qualifiers |
| `-Wformat=2` | Strict printf/scanf format checking |
| `-Wundef` | Warn on undefined preprocessor identifiers |
| `-Wnull-dereference` | Warn on null pointer dereference paths |
| `-Wdouble-promotion` | Warn on implicit float-to-double promotion |
| `-Wimplicit-fallthrough` | Warn on unannotated switch fallthrough |

**MSVC flags:**

| Flag | Purpose |
|---|---|
| `/W4` | Highest practical warning level |
| `/WX` | Treat all warnings as errors |
| `/permissive-` | Enforce strict standards conformance |
| `/w14640` | Warn on thread-local static initialization |

---

## Adding New Source Files

1. Create your `.cpp` file in `src/` (e.g., `src/config.cpp`)
2. Create the corresponding header in `include/` (e.g., `include/config.hpp`)
3. Add the `.cpp` file to `src/CMakeLists.txt`:

```cmake
add_executable(${PROJECT_NAME} main.cpp config.cpp)
```

---

## Adding Dependencies

1. Add the dependency to `conanfile.py`:

```python
def requirements(self):
    self.requires("fmt/10.2.1")
```

2. Run `conan install . --build=missing`
3. Link it in `src/CMakeLists.txt`:

```cmake
find_package(fmt REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)
```

---

## Adding Tests

1. Create a test file in `tests/` (e.g., `tests/test_config.cpp`)
2. Add it to `tests/CMakeLists.txt`:

```cmake
add_executable(${PROJECT_NAME}_tests test_main.cpp test_config.cpp)
```

3. Write your tests using Google Test macros (`TEST`, `EXPECT_*`, `ASSERT_*`)
4. Run `ctest --preset conan-release`

---

## Prerequisites

- **CMake** >= 3.27
- **Conan** >= 2.0
- A C++23-capable compiler:
  - GCC >= 13
  - Clang >= 16
  - MSVC >= 19.34 (Visual Studio 2022 17.4)
