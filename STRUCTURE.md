# Project Structure

This repository is a professional C++ executable project template using **CMake** and **Conan** with **C++23**.

## Directory Layout

```
cpp-executable-template/
├── CMakeLists.txt          # Root CMake configuration
├── conanfile.py            # Conan package manager definition
├── .gitignore
├── STRUCTURE.md            # This file
├── src/                    # Application source files
│   ├── CMakeLists.txt
│   └── main.cpp
├── include/                # Public/project header files
├── lib/                    # Internal/static libraries
├── tests/                  # Unit and integration tests
│   └── CMakeLists.txt
├── cmake/                  # Custom CMake modules and toolchain files
│   └── ConanSetup.cmake
├── scripts/                # Build and utility scripts
├── docs/                   # Project documentation
└── external/               # Third-party code not managed by Conan
```

## Directory Purposes

### `src/`
Contains all application source files (`.cpp`). The executable target is defined here. This is where the `main()` entry point and all implementation files live.

### `include/`
Contains header files (`.hpp`, `.h`) that are part of the project's public interface. Keeping headers separate from source files enables clean include paths and makes it easy to expose a public API if the project ever evolves into a library.

### `lib/`
Reserved for internal or vendored static libraries that are compiled as part of the project but are logically separate from the main application code.

### `tests/`
Contains test source files and their own `CMakeLists.txt`. Tests use Google Test (when available via Conan) and are discovered automatically by CTest.

### `cmake/`
Contains custom CMake modules, find scripts, and toolchain integration files. `ConanSetup.cmake` handles optional Conan toolchain inclusion.

### `scripts/`
Utility scripts for building, formatting, CI, or other development workflows (e.g., shell scripts, Python scripts).

### `docs/`
Project documentation beyond what is in the root `README.md` or this file.

### `external/`
Third-party source code or libraries that are vendored directly into the repository rather than managed through Conan. Use sparingly.

## Build Instructions

```bash
# Install dependencies via Conan
conan install . --build=missing

# Configure and build
cmake --preset conan-release
cmake --build --preset conan-release

# Run tests
ctest --preset conan-release
```

## Compiler Strictness

The root `CMakeLists.txt` enables strict compiler flags:

- **GCC/Clang**: `-Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -Wsign-conversion -Wcast-qual -Wformat=2 -Wundef -Wnull-dereference -Wdouble-promotion -Wimplicit-fallthrough`
- **MSVC**: `/W4 /WX /permissive-`

All warnings are treated as errors to enforce code quality.
