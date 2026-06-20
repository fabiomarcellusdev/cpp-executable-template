# Build Configuration Guide

This document provides detailed explanations of the build system, commands, and configurations used in this project.

---

## Installing Conan

Conan is the C++ package manager used to manage dependencies (currently Google Test).

### Installation

**Using pip (recommended):**

```bash
pip install conan
```

**Using pipx (isolated installation):**

```bash
pipx install conan
```

### Verification

After installation, verify Conan is available:

```bash
conan --version
```

**Expected output:**

```
Conan version 2.x.x
```

If you see `Command 'conan' not found`, ensure your Python scripts directory is in your PATH:

```bash
# Check where pip installed Conan
pip show conan | grep Location

# Add to PATH if needed (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"
```

### Initial Setup

Detect your default Conan profile (compiler, OS, architecture):

```bash
conan profile detect
```

**Expected output:**

```
Detecting profile...
Found cc=gcc -> /usr/bin/gcc
...
Profile detection successful
```

---

## Understanding `conan install`

### The Command

```bash
conan install . --build=missing
```

### What It Does

**`conan install .`**

The `.` tells Conan to look in the current directory for `conanfile.py`. Conan then:

1. **Reads dependencies** from the `requirements()` method in `conanfile.py` (currently `gtest/1.14.0`)
2. **Downloads packages** from Conan Center (https://conan.io/center/)
3. **Generates CMake integration files** in the build directory:
   - `conan_toolchain.cmake` — tells CMake where to find dependencies and their headers/libraries
   - `CMakePresets.json` — defines `conan-release` and `conan-debug` presets that CMake can use
   - Package config files (e.g., `GTestConfig.cmake`) for each dependency

**`--build=missing`**

This flag tells Conan: "If a pre-built binary package isn't available for my system/compiler, build it from source."

**Why it matters:**

- Conan Center provides pre-built binaries for common platforms (Linux x86_64, macOS ARM64, etc.)
- If no binary exists for your exact setup (e.g., unusual compiler version), Conan would normally fail
- With `--build=missing`, Conan compiles the dependency from source (first time only, then cached)

**Example scenario:**

```bash
# Without --build=missing (might fail)
conan install .
# ERROR: Missing binary for gtest/1.14.0

# With --build=missing (builds from source if needed)
conan install . --build=missing
# gtest/1.14.0: Building from source...
# gtest/1.14.0: Package built successfully
```

### Build Type Variants

By default, `conan install` uses `Release` settings. For Debug builds:

```bash
conan install . --build=missing -s build_type=Debug
```

The `-s build_type=Debug` flag tells Conan to:
- Use Debug compiler flags (`-g -O0` instead of `-O2 -DNDEBUG`)
- Download/build Debug versions of dependencies
- Generate `conan-debug` preset instead of `conan-release`

### Real Example

```bash
# Install dependencies for Release build
conan install . --build=missing

# Install dependencies for Debug build
conan install . --build=missing -s build_type=Debug
```

**Expected output:**

```
======== Computing dependency graph ========
Graph root
    conanfile.py (cpp_executable_template/0.1.0)
    Requirements
        gtest/1.14.0

======== Installing packages ========
gtest/1.14.0: Already installed!

======== Generating toolchain files ========
CMakeToolchain generated: conan_toolchain.cmake
CMakeDeps generated: GTestConfig.cmake
CMakePresets generated: CMakePresets.json
```

---

## CMake Presets Explained

### What Are Presets?

CMake presets are predefined configuration sets that specify:
- Build directory location
- Generator (Ninja, Make, etc.)
- Compiler settings
- CMake cache variables

Conan generates presets automatically when you run `conan install`.

### Available Presets

After running `conan install . --build=missing`, two presets are available:

**`conan-release`**
- Build directory: `build/Release`
- Build type: `Release` (optimizations enabled, debug symbols stripped)
- Compiler flags: `-O2 -DNDEBUG`

**`conan-debug`**
- Build directory: `build/Debug`
- Build type: `Debug` (no optimizations, full debug symbols)
- Compiler flags: `-g -O0`

### Using Presets

**Configure with a preset:**

```bash
cmake --preset conan-release
```

This is equivalent to:

```bash
cmake -B build/Release \
      -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake \
      -DCMAKE_BUILD_TYPE=Release
```

**Build with a preset:**

```bash
cmake --build --preset conan-release
```

This builds everything in `build/Release`.

**Run tests with a preset:**

```bash
ctest --preset conan-release
```

This runs tests from the `build/Release` directory.

### Real Example

```bash
# Configure Release build
cmake --preset conan-release

# Expected output:
# Preset CMake variables:
#   CMAKE_BUILD_TYPE=Release
#   CMAKE_TOOLCHAIN_FILE=/path/to/conan_toolchain.cmake
# -- Configuring done
# -- Generating done
# -- Build files have been written to: /path/to/build/Release

# Build
cmake --build --preset conan-release

# Expected output:
# [1/3] Building CXX object src/CMakeFiles/cpp_executable_template.dir/main.cpp.o
# [2/3] Linking CXX executable cpp_executable_template
# [3/3] Built target cpp_executable_template
```

---

## Build Configurations

### Release vs Debug

**Release (`conan-release`)**
- **Use when:** Building for production, performance testing, deployment
- **Optimizations:** Enabled (`-O2`)
- **Debug symbols:** Stripped
- **Assertions:** Disabled (`NDEBUG` defined)
- **Binary size:** Smaller
- **Performance:** Faster

**Debug (`conan-debug`)**
- **Use when:** Development, debugging, testing, code coverage, sanitizers
- **Optimizations:** Disabled (`-O0`)
- **Debug symbols:** Full (`-g`)
- **Assertions:** Enabled
- **Binary size:** Larger
- **Performance:** Slower (but debuggable)

### When to Use Each

| Scenario | Configuration |
|---|---|
| Daily development | Debug |
| Running tests | Debug |
| Code coverage analysis | Debug |
| Sanitizer analysis | Debug |
| Performance testing | Release |
| Production deployment | Release |
| CI/CD pipelines | Both |

### Switching Between Configurations

You can configure both Release and Debug builds side-by-side:

```bash
# Install dependencies for both
conan install . --build=missing
conan install . --build=missing -s build_type=Debug

# Configure both
cmake --preset conan-release
cmake --preset conan-debug

# Build either
cmake --build --preset conan-release
cmake --build --preset conan-debug
```

Each configuration lives in its own directory (`build/Release` and `build/Debug`), so they don't interfere with each other.

---

## Build Output Structure

### Directory Layout

The `conanfile.py` uses Conan's `cmake_layout()`, which organizes build artifacts:

```
build/
├── Release/                    # Release build artifacts
│   ├── src/
│   │   └── cpp_executable_template    # The executable
│   ├── tests/
│   │   └── cpp_executable_template_tests  # Test executable
│   ├── CMakeCache.txt
│   ├── compile_commands.json   # For clangd/clang-tidy
│   └── ...
│
└── Debug/                      # Debug build artifacts
    ├── src/
    │   └── cpp_executable_template
    ├── tests/
    │   └── cpp_executable_template_tests
    ├── CMakeCache.txt
    ├── compile_commands.json
    └── ...
```

### Key Files

**`compile_commands.json`**
- Generated by CMake when `CMAKE_EXPORT_COMPILE_COMMANDS=ON` (set in root `CMakeLists.txt`)
- Contains the exact compiler commands used for each source file
- Required by `clang-tidy` for linting
- Used by `clangd` (language server) for IDE integration

**Executable location**
- Release: `build/Release/src/cpp_executable_template`
- Debug: `build/Debug/src/cpp_executable_template`
- On Windows: `.exe` extension is added automatically

### Running the Executable

```bash
# Release
./build/Release/src/cpp_executable_template

# Debug
./build/Debug/src/cpp_executable_template
```

---

## Complete Build Workflow

### From Fresh Clone to Running Executable

**Step 1: Install Conan (if not already installed)**

```bash
pip install conan
conan profile detect
```

**Step 2: Install dependencies**

```bash
conan install . --build=missing
```

**Step 3: Configure the project**

```bash
cmake --preset conan-release
```

**Step 4: Build**

```bash
cmake --build --preset conan-release
```

**Step 5: Run the executable**

```bash
./build/Release/src/cpp_executable_template
```

**Expected output:**

```
Hello, World!
```

### Debug Build Workflow

```bash
# Install dependencies for Debug
conan install . --build=missing -s build_type=Debug

# Configure
cmake --preset conan-debug

# Build
cmake --build --preset conan-debug

# Run (with debug symbols for gdb/lldb)
gdb ./build/Debug/src/cpp_executable_template
```

---

## Common Issues

### "Command 'conan' not found"

**Cause:** Conan is not installed or not in PATH.

**Solution:**

```bash
pip install conan
export PATH="$HOME/.local/bin:$PATH"
```

### "CMake Error: Could not find Conan toolchain"

**Cause:** `conan install` was not run before `cmake --preset`.

**Solution:**

```bash
conan install . --build=missing
cmake --preset conan-release
```

### "Preset 'conan-release' not found"

**Cause:** Conan did not generate `CMakePresets.json`.

**Solution:**

```bash
# Re-run conan install
conan install . --build=missing

# Verify CMakePresets.json exists
ls CMakePresets.json
```

### "Build type mismatch"

**Cause:** Trying to build Release configuration with Debug dependencies (or vice versa).

**Solution:**

```bash
# Install dependencies for the correct build type
conan install . --build=missing -s build_type=Debug  # for Debug
conan install . --build=missing                       # for Release
```

---

## Summary

| Command | Purpose |
|---|---|
| `conan install . --build=missing` | Install dependencies and generate CMake integration files |
| `cmake --preset conan-release` | Configure Release build |
| `cmake --preset conan-debug` | Configure Debug build |
| `cmake --build --preset conan-release` | Build Release configuration |
| `cmake --build --preset conan-debug` | Build Debug configuration |
| `ctest --preset conan-release` | Run tests (Release) |
| `ctest --preset conan-debug` | Run tests (Debug) |

For linting, testing, coverage, and sanitizers, see:
- [Linting Guide](LINTING.md)
- [Testing Guide](TESTING.md)
