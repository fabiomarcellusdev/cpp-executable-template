# cpp-executable-template

A professional C++ executable project template using **CMake**, **Conan**, and **C++23**. This repository provides a ready-to-use starting point for building C++ applications with a clean, scalable folder structure, strict compiler settings, and modern tooling.

---

## Using This Template

This repository is designed to be used as a GitHub template. There are several ways to create your own project from it:

**GitHub Web UI:**
1. Navigate to the repository page on GitHub
2. Click the **"Use this template"** button (top-right, next to "Code")
3. Choose **"Create a new repository"**
4. Enter your new repository name, set visibility, and click **"Create repository"**

**GitHub CLI:**

```bash
gh repo create my-project --template your-username/cpp-executable-template --public --clone
cd my-project
```

**Manual clone (if you don't want template history):**

```bash
git clone https://github.com/your-username/cpp-executable-template.git my-project
cd my-project
rm -rf .git
git init
git add -A
git commit -m "Initial commit"
```

After creating your project, see the [Renaming Your Project](#renaming-your-project) section below for a complete walkthrough of every place the project name needs to be updated.

---

## Renaming Your Project

This template uses `cpp_executable_template` as the project name and `my_project_name` as the include namespace. You should rename these to match your actual project. Here is every location that needs updating:

### 1. Root `CMakeLists.txt`

Update the `project()` declaration:

```cmake
project(
    my_project          # was: cpp_executable_template
    VERSION 0.1.0
    DESCRIPTION "My project description"
    LANGUAGES CXX
)
```

This automatically updates the executable name, test target name (`my_project_tests`), and all references to `${PROJECT_NAME}` throughout the build system.

### 2. `conanfile.py`

Update the `name` field:

```python
class MyProject(ConanFile):
    name = "my_project"          # was: cpp_executable_template
    version = "0.1.0"
```

### 3. Include namespace directory

Rename the directory inside `include/`:

```bash
mv include/my_project_name include/my_project
```

Then update all `#include` statements in your source files:

```cpp
#include <my_project/core.hpp>   // was: #include <my_project_name/core.hpp>
```

### 4. `LICENSE`

Update the copyright line with your name:

```
Copyright (c) 2026 Your Name
```

### 5. `README.md`

Replace the contents of this file with documentation for your project.

### Summary checklist

- [ ] `CMakeLists.txt` — `project()` name and description
- [ ] `conanfile.py` — `name` field
- [ ] `include/my_project_name/` — rename directory
- [ ] All `#include <my_project_name/...>` statements — update namespace
- [ ] `LICENSE` — copyright holder name
- [ ] `README.md` — replace with your project documentation

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

### Build Output Location

The `conanfile.py` uses Conan's `cmake_layout()`, which places all build artifacts inside a `build/` directory at the project root, organized by build configuration:

```
build/
├── Release/        # Release build artifacts (executable, object files, etc.)
├── Debug/          # Debug build artifacts
└── RelWithDebInfo/ # RelWithDebInfo build artifacts (if configured)
```

The final executable is located at `build/<BuildType>/cpp_executable_template` (or `.exe` on Windows). The `build/` directory is gitignored and should never be committed.

---

## Project Structure

```
cpp-executable-template/
├── CMakeLists.txt              # Root CMake configuration
├── conanfile.py                # Conan 2.x package manager definition
├── README.md                   # This file
├── LICENSE                     # MIT license
├── SECURITY.md                 # Security policy for vulnerability reporting
├── .gitignore                  # Git ignore rules
├── .editorconfig               # Editor-agnostic formatting rules
├── .clang-format               # Code formatting rules
├── .clang-tidy                 # Static analysis and naming convention rules
├── .pre-commit-config.yaml     # Pre-commit hooks configuration
│
├── src/                        # Application source code
│   ├── CMakeLists.txt          # Executable target definition
│   └── main.cpp                # Entry point
│
├── include/                    # Project header files
│   └── my_project_name/        # Namespace directory for clean include paths
│
├── lib/                        # Internal / vendored static libraries
│
├── tests/                      # Test source code
│   ├── CMakeLists.txt          # Test target definition
│   └── test_main.cpp           # Test entry point
│
├── cmake/                      # Custom CMake modules
│   ├── ConanSetup.cmake        # Conan toolchain integration
│   ├── LintTargets.cmake       # Formatting and linting CMake targets
│   ├── CheckPragmaOnce.cmake   # Enforces #pragma once in all headers
│   ├── CodeCoverage.cmake      # Code coverage reporting with lcov
│   └── Sanitizers.cmake        # AddressSanitizer and UndefinedBehaviorSanitizer
│
├── .github/                    # GitHub-specific configuration
│   └── workflows/
│       └── ci.yml              # GitHub Actions CI workflow
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

All headers live inside a **project-named subdirectory** (currently `my_project_name/`). This enforces namespaced include paths throughout the codebase, preventing header name collisions with third-party libraries and making it immediately clear which headers belong to your project.

**What goes here:**
- All `.hpp` and `.h` files inside `include/my_project_name/` (e.g., `include/my_project_name/core.hpp`, `include/my_project_name/config.hpp`)
- Subdirectories within `my_project_name/` for organizing by module (e.g., `include/my_project_name/io/parser.hpp`)

**What does NOT go here:**
- Implementation files (`.cpp` — those belong in `src/`)
- Third-party headers (those belong in `external/` or are managed by Conan)
- Headers placed directly in `include/` without the namespace subdirectory

Because `src/CMakeLists.txt` adds `include/` to the target's include path, headers are included with the project namespace:

```cpp
#include <my_project_name/core.hpp>
#include <my_project_name/io/parser.hpp>
```

When starting your own project, rename `my_project_name/` to match your project name (e.g., `include/my_app/`).

---

### `lib/` — Internal Libraries

Reserved for self-contained, reusable components that are compiled as static libraries within the project but are logically independent from the main application. Think of `lib/` as a place for mini-libraries you wrote yourself — code that has no dependency on your application's domain logic and could be extracted into its own repository or reused in a different project with little to no modification.

The key distinction from `src/`: code in `src/` is application-specific (it knows about your CLI flags, your config format, your business rules), while code in `lib/` is generic and domain-agnostic.

**What goes here:**
- Each library lives in its own subdirectory with its own `CMakeLists.txt`, and is added via `add_subdirectory()` from the root
- Examples of good candidates for `lib/`:
  - `lib/logger/` — a lightweight logging utility with severity levels, sinks, and formatting, usable in any C++ project
  - `lib/thread_pool/` — a generic thread pool implementation with task submission and future-based results
  - `lib/arg_parser/` — a command-line argument parser that knows nothing about your specific application's flags
  - `lib/signal_slot/` — a generic observer/signal-slot mechanism for decoupled event handling
  - `lib/crc32/` — a CRC32 checksum implementation with no external dependencies

**What does NOT go here:**
- Application-specific code like `config.cpp` or `app.cpp` — those belong in `src/` because they are tightly coupled to your project's domain
- Third-party code downloaded from the internet — use `external/` for vendored code or Conan for managed dependencies
- Header-only utilities — those belong in `include/` since they have no compiled component

---

### `tests/` — Test Source Code

Contains all unit and integration tests. The project uses **Google Test** (GTest) as a required dependency managed by Conan, and tests are automatically discovered by **CTest**.

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
- `LintTargets.cmake` — adds `format-check`, `format-fix`, `lint`, and `check-headers` CMake targets
- `CheckPragmaOnce.cmake` — CMake script that verifies all headers contain `#pragma once`
- `CodeCoverage.cmake` — adds `coverage` CMake target for generating HTML coverage reports with lcov
- `Sanitizers.cmake` — enables AddressSanitizer and UndefinedBehaviorSanitizer via `-DENABLE_SANITIZERS=ON`
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
- Includes the lint/format targets from `cmake/LintTargets.cmake`
- Includes code coverage support from `cmake/CodeCoverage.cmake`
- Includes sanitizer support from `cmake/Sanitizers.cmake`
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

### `.clang-format`

Defines code formatting rules applied by `clang-format`. Key settings: 4-space indentation, attached braces (K&R style), 100-column limit, left-aligned pointers/references, regrouped and sorted includes (C headers first, then C++ standard library, then project headers), and C++23 standard. See the [Formatting & Linting](#formatting--linting) section for details.

### `.clang-tidy`

Defines static analysis checks run by `clang-tidy`. Enables checks for bug-prone patterns, C++ Core Guidelines, modernization, performance, and readability. Enforces naming conventions via `readability-identifier-naming` (see the naming conventions table in the Formatting & Linting section). See the [Formatting & Linting](#formatting--linting) section for details.

### `LICENSE`

MIT license. Update the copyright line with your name when you create your project from this template.

### `.editorconfig`

Editor-agnostic formatting rules that work across IDEs and text editors. Defines charset (UTF-8), line endings (LF), indentation (4 spaces for C++/CMake, 2 spaces for YAML), trailing whitespace trimming, and final newline insertion. Complements `.clang-format` for editor-level consistency.

### `.pre-commit-config.yaml`

Configuration for [pre-commit](https://pre-commit.com/) hooks that run automatically before each git commit. Includes:
- Trailing whitespace removal
- End-of-file newline fixing
- YAML syntax checking
- Large file detection
- Merge conflict detection
- `clang-format` enforcement on C++ files

To install pre-commit hooks:

```bash
pip install pre-commit
pre-commit install
```

Hooks will then run automatically on every commit. To run manually on all files:

```bash
pre-commit run --all-files
```

### `SECURITY.md`

Security policy for the repository. Defines how to report vulnerabilities, expected response times, disclosure policy, and security best practices for users of the template. Uses GitHub's private vulnerability reporting feature.

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
2. Create the corresponding header in `include/my_project_name/` (e.g., `include/my_project_name/config.hpp`)
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

## Formatting & Linting

This project enforces code quality through **clang-format** and **clang-tidy**, integrated directly into CMake.

### Configuration Files

- **`.clang-format`** — Defines code formatting rules: 4-space indentation, attached braces, 100-column limit, left-aligned pointers, regrouped and sorted includes, and more.
- **`.clang-tidy`** — Defines static analysis checks: naming conventions, modernization suggestions, bug-prone patterns, performance issues, and C++ Core Guidelines compliance.

### Naming Conventions

Enforced by `.clang-tidy` via `readability-identifier-naming`:

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case` | `my_class.cpp`, `config_parser.hpp` |
| Classes / Structs | `PascalCase` | `MyClass`, `AppConfig` |
| Functions | `snake_case` | `calculate_total()`, `parse_input()` |
| Variables | `snake_case` | `item_count`, `buffer_size` |
| Parameters | `snake_case` | `max_retries`, `output_path` |
| Class members | `snake_case` | `connection_count` |
| Private/protected members | `snake_case_` | `is_valid_`, `cache_` |
| Namespaces | `snake_case` | `my_project_name` |
| Enums | `PascalCase` | `Color`, `LogLevel` |
| Enum values | `PascalCase` | `Color::DarkBlue`, `LogLevel::Error` |
| Constants / `constexpr` | `PascalCase` | `MaxBufferSize`, `DefaultTimeout` |
| Macros | `UPPER_CASE` | `MY_PROJECT_VERSION`, `LOG_DEBUG` |
| Type aliases | `PascalCase` | `StringMap`, `CallbackFn` |
| Template parameters | `PascalCase` | `T`, `Allocator` |

### Available CMake Targets

| Target | Description |
|---|---|
| `format-check` | Checks formatting without modifying files (fails if any file is unformatted) |
| `format-fix` | Auto-fixes formatting in all source and header files |
| `lint` | Runs clang-tidy static analysis on all source files |
| `check-headers` | Verifies all header files in `include/` contain `#pragma once` |

### Usage

```bash
# Check formatting
cmake --build build --target format-check

# Auto-fix formatting
cmake --build build --target format-fix

# Run linter
cmake --build build --target lint

# Check headers for #pragma once
cmake --build build --target check-headers
```

### Enforce During Build

To make the build fail when formatting or linting issues are detected:

```bash
cmake --preset conan-release -DENABLE_LINTING=ON
cmake --build --preset conan-release
```

When `ENABLE_LINTING` is enabled:
- `clang-format --dry-run` runs before compilation (build fails if files are unformatted)
- `clang-tidy` runs on every compilation unit (build fails on warnings)
- `#pragma once` is verified for all headers before compilation

---

## Code Coverage

Generate HTML coverage reports showing which lines of code are exercised by your tests.

### Prerequisites

- **lcov** (includes `genhtml`)
  - Linux: `apt-get install lcov` or `dnf install lcov`
  - macOS: `brew install lcov`

### Usage

```bash
# 1. Configure with coverage enabled (use Debug for best results)
conan install . --build=missing -s build_type=Debug
cmake --preset conan-debug -DENABLE_COVERAGE=ON

# 2. Build
cmake --build --preset conan-debug

# 3. Run tests to collect coverage data
ctest --preset conan-debug

# 4. Generate the HTML coverage report
cmake --build build --target coverage
```

The coverage report is generated at `build/Debug/coverage/html/index.html`. Open it in a browser to view line-by-line coverage data.

### What's excluded

The coverage report automatically excludes:
- System headers (`/usr/*`)
- Test files (`*/tests/*`)
- Build artifacts (`*/build/*`)
- Vendored third-party code (`*/external/*`)

---

## Sanitizers

Runtime error detection tools that catch bugs invisible during normal execution. Enabled via CMake option, supported on GCC and Clang only.

### Available Sanitizers

| Sanitizer | What it catches |
|---|---|
| **AddressSanitizer (ASan)** | Buffer overflows, use-after-free, double-free, memory leaks |
| **UndefinedBehaviorSanitizer (UBSan)** | Integer overflow, null dereference, misaligned pointers, signed overflow |

### Usage

```bash
# Configure with sanitizers enabled (use Debug for best results)
conan install . --build=missing -s build_type=Debug
cmake --preset conan-debug -DENABLE_SANITIZERS=ON

# Build
cmake --build --preset conan-debug

# Run tests — sanitizers abort on first error detected
ctest --preset conan-debug --output-on-failure
```

### Performance impact

Sanitizers add ~2-3x slowdown and higher memory usage. Use only for development and testing builds, never for release.

### Combining with other options

Sanitizers can be combined with code coverage and linting:

```bash
cmake --preset conan-debug -DENABLE_SANITIZERS=ON -DENABLE_COVERAGE=ON -DENABLE_LINTING=ON
```

---

## Continuous Integration

This project includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that automatically builds and tests the project on every push and pull request.

**What it does:**
- Runs on Linux (Ubuntu) and macOS
- Tests with both GCC and Clang compilers
- Builds in both Release and Debug configurations
- Installs Conan dependencies
- Configures, builds, and runs tests via CTest

The workflow matrix excludes GCC on macOS since Clang is the default compiler there.

**Viewing CI status:**
After pushing to GitHub, check the Actions tab to see build status. A green checkmark indicates all configurations passed.

**Customizing the workflow:**
Edit `.github/workflows/ci.yml` to:
- Add Windows support (requires MSVC setup)
- Enable code coverage reporting
- Add static analysis uploads (e.g., SonarCloud, Codecov)
- Add deployment/release automation

---

## Prerequisites

- **CMake** >= 3.27
- **Conan** >= 2.0
- **clang-format** >= 16
- **clang-tidy** >= 16
- **lcov** (optional, for code coverage reports)
- **pre-commit** (optional, for git commit hooks)
- A C++23-capable compiler:
  - GCC >= 13
  - Clang >= 16
  - MSVC >= 19.34 (Visual Studio 2022 17.4)
