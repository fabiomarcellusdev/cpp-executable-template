# Testing & Analysis Guide

This document covers running tests, generating code coverage reports, and using sanitizers to detect runtime bugs.

---

## Running Tests

### Basic Test Execution

Tests are run using CTest, which is integrated with CMake. The test executable is built as part of the normal build process.

```bash
ctest --preset release
```

**Real example:**

```bash
ctest --preset release
```

**Expected output:**

```
Test project /path/to/build/release
    Start 1: SanityCheck.TrueIsTrue
1/1 Test #1: SanityCheck.TrueIsTrue .............   Passed    0.00 sec

100% tests passed, 0 tests failed out of 1

Total Test time (real) =   0.01 sec
```

### Running with Verbose Output

See detailed test output (useful when tests fail):

```bash
ctest --preset release --output-on-failure
```

**Real example:**

```bash
ctest --preset release --output-on-failure
```

**Expected output (on failure):**

```
Test project /path/to/build/release
    Start 1: SanityCheck.TrueIsTrue
1/1 Test #1: SanityCheck.TrueIsTrue .............***Failed    0.00 sec
Running main() from gtest_main.cc
[==========] Running 1 test from 1 test suite.
[----------] Global test environment set-up.
[----------] 1 test from SanityCheck
[ RUN      ] SanityCheck.TrueIsTrue
/path/to/tests/test_main.cpp:4: Failure
Value of: false
  Actual: false
Expected: true
[  FAILED  ] SanityCheck.TrueIsTrue (0 ms)
[==========] 1 test from 1 test suite ran. (0 ms total)
[  PASSED  ] 0 tests.
[  FAILED  ] 1 test, listed below:
[  FAILED  ] SanityCheck.TrueIsTrue

 1 FAILED TEST

0% tests passed, 1 tests failed out of 1
```

### Running Specific Tests

Run only tests matching a pattern:

```bash
ctest --preset release -R "SanityCheck"
```

**Real example:**

```bash
ctest --preset release -R "SanityCheck"
```

### Debug Build Tests

Run tests in Debug configuration (recommended for development):

```bash
ctest --preset debug --output-on-failure
```

---

## Adding New Tests

### Step-by-Step

1. **Create a test file** in `tests/`:

```cpp
// tests/test_config.cpp
#include <gtest/gtest.h>
#include <my_project_name/config.hpp>

TEST(ConfigTest, DefaultValues) {
    Config config;
    EXPECT_EQ(config.port, 8080);
    EXPECT_EQ(config.host, "localhost");
}

TEST(ConfigTest, CustomValues) {
    Config config;
    config.port = 3000;
    EXPECT_EQ(config.port, 3000);
}
```

2. **Add the test file** to `tests/CMakeLists.txt`:

```cmake
add_executable(${PROJECT_NAME}_tests test_main.cpp test_config.cpp)
```

3. **Rebuild**:

```bash
cmake --build --preset release
```

4. **Run tests**:

```bash
ctest --preset release --output-on-failure
```

**Expected output:**

```
Test project /path/to/build/release
    Start 1: SanityCheck.TrueIsTrue
1/3 Test #1: SanityCheck.TrueIsTrue .............   Passed    0.00 sec
    Start 2: ConfigTest.DefaultValues
2/3 Test #2: ConfigTest.DefaultValues ...........   Passed    0.00 sec
    Start 3: ConfigTest.CustomValues
3/3 Test #3: ConfigTest.CustomValues ............   Passed    0.00 sec

100% tests passed, 0 tests failed out of 3
```

### Google Test Macros

| Macro | Purpose |
|---|---|
| `TEST(SuiteName, TestName)` | Defines a test |
| `EXPECT_EQ(a, b)` | Expects `a == b` (non-fatal) |
| `EXPECT_NE(a, b)` | Expects `a != b` (non-fatal) |
| `EXPECT_TRUE(expr)` | Expects `expr` is true (non-fatal) |
| `EXPECT_FALSE(expr)` | Expects `expr` is false (non-fatal) |
| `ASSERT_EQ(a, b)` | Asserts `a == b` (fatal, aborts test) |
| `ASSERT_TRUE(expr)` | Asserts `expr` is true (fatal) |

**Difference between EXPECT and ASSERT:**

- `EXPECT_*` — non-fatal: test continues even if assertion fails
- `ASSERT_*` — fatal: test aborts immediately if assertion fails

Use `EXPECT_*` by default. Use `ASSERT_*` when continuing the test makes no sense (e.g., pointer is null).

---

## Code Coverage

### What It Is

Code coverage measures which lines of code are executed during testing. It helps identify untested code paths and ensures your tests are comprehensive.

### Prerequisites

Install `lcov` (includes `genhtml`):

**Linux (Ubuntu/Debian):**

```bash
sudo apt-get install lcov
```

**Linux (Fedora/RHEL):**

```bash
sudo dnf install lcov
```

**macOS:**

```bash
brew install lcov
```

**Verification:**

```bash
lcov --version
```

**Expected output:**

```
lcov: LCOV version 2.0
```

### How It Works

1. **Compile with `--coverage` flag** — GCC/Clang instruments the code to track execution
2. **Run tests** — generates `.gcda` files with execution counts for each line
3. **Capture coverage data** — `lcov` reads `.gcda` files and produces `coverage.info`
4. **Filter out noise** — removes system headers, tests, and external code
5. **Generate HTML report** — `genhtml` creates an interactive HTML report

### Usage

**Step 1: Install dependencies**

Download and build Conan packages (GTest, fmt, etc.) for Debug configuration:

```bash
conan install . --build=missing -s build_type=Debug -s compiler.cppstd=23
```

**Step 2: Configure with coverage enabled**

Read `CMakeLists.txt`, resolve dependencies, and generate build files in `build/debug-coverage/` with `--coverage` compiler flags. Does **not** compile anything:

```bash
cmake --preset debug-coverage
```

**Expected output:**

```
-- Code coverage enabled (threshold: 80%)
-- Using gcov: /usr/bin/gcov-13
-- Configuring done
-- Generating done
```

**Step 3: Build**

Invoke the compiler using the generated build files. Compiles `.cpp` files into object files and links them into executables (`cpp_executable_template` and `cpp_executable_template_tests`):

```bash
cmake --build --preset debug-coverage
```

**Step 4: Run tests**

Execute the test binary via CTest. This generates `.gcda` files containing execution counts for each instrumented line:

```bash
ctest --preset debug-coverage --output-on-failure
```

**Step 5: Generate the HTML coverage report**

Run the `coverage` custom target, which:
1. Captures coverage data from `.gcda` files using `lcov`
2. Filters out system headers, tests, and build artifacts
3. Generates an interactive HTML report using `genhtml`
4. Checks coverage against the 80% threshold (fails if below)

```bash
cmake --build --preset debug-coverage --target coverage
```

**Expected output:**

```
[1/1] Generating code coverage report...
Capturing coverage data from src tests
Found gcov version: 13.2.0
...
Overall coverage rate:
  lines......: 85.7% (42 of 49 lines)
  functions..: 100.0% (8 of 8 functions)
Coverage report generated at: /path/to/build/debug-coverage/coverage/html/index.html
-- Coverage: 42/49 lines (85%)
-- Threshold: 80%
-- Coverage check passed: 85% >= 80%
```

**Step 6: Open the report**

```bash
# Linux
xdg-open build/debug-coverage/coverage/html/index.html

# macOS
open build/debug-coverage/coverage/html/index.html
```

The HTML report shows:
- **Directory view** — coverage percentage per directory
- **File view** — coverage percentage per file
- **Line view** — each line colored green (covered), red (uncovered), or white (not instrumented)

### What's Excluded

The coverage report automatically excludes:

| Pattern | Reason |
|---|---|
| `/usr/*` | System headers (not your code) |
| `*/tests/*` | Test files (you're measuring production code coverage) |
| `*/build/*` | Build artifacts |
| `*/external/*` | Vendored third-party code |

### Coverage Threshold

The project enforces a **minimum 80% line coverage** threshold. When you run the coverage target, it will:

1. Generate the coverage report
2. Parse the coverage percentage
3. **Fail if coverage is below 80%**

**Example (coverage passes):**

```bash
cmake --build build/debug --target coverage
```

**Expected output:**

```
[1/1] Generating code coverage report...
...
Overall coverage rate:
  lines......: 85.7% (42 of 49 lines)
  functions..: 100.0% (8 of 8 functions)
Coverage report generated at: /path/to/build/debug/coverage/html/index.html
-- Coverage: 42/49 lines (85%)
-- Threshold: 80%
-- Coverage check passed: 85% >= 80%
```

**Example (coverage fails):**

```bash
cmake --build build/debug --target coverage
```

**Expected output:**

```
[1/1] Generating code coverage report...
...
Overall coverage rate:
  lines......: 65.3% (32 of 49 lines)
  functions..: 75.0% (6 of 8 functions)
Coverage report generated at: /path/to/build/debug/coverage/html/index.html
-- Coverage: 32/49 lines (65%)
-- Threshold: 80%
CMake Error: Code coverage 65% is below the required threshold of 80%. Please add more tests to increase coverage.
```

**Changing the threshold:**

```bash
# Set threshold to 90%
cmake --preset debug-coverage -DCOVERAGE_THRESHOLD=90
```

Or modify `CMakePresets.json` to set it permanently for a preset.

For Codecov integration and viewing coverage trends, see [Codecov Guide](CODECOV.md).

### Typical Workflow

```bash
# 1. Install dependencies (downloads/builds Conan packages like GTest, fmt)
conan install . --build=missing -s build_type=Debug -s compiler.cppstd=23

# 2. Configure (reads CMakeLists.txt, generates build files with --coverage flags)
cmake --preset debug-coverage

# 3. Build (compiles .cpp files and links executables)
cmake --build --preset debug-coverage

# 4. Run tests (executes tests, generates .gcda coverage data files)
ctest --preset debug-coverage --output-on-failure

# 5. Generate report (captures coverage, filters noise, creates HTML, enforces 80% threshold)
cmake --build --preset debug-coverage --target coverage

# 6. View report (opens interactive HTML in browser)
xdg-open build/debug-coverage/coverage/html/index.html  # Linux
open build/debug-coverage/coverage/html/index.html       # macOS
```

---

## Sanitizers

### What They Are

Sanitizers are runtime error detection tools built into GCC and Clang. They instrument your code to catch bugs that are invisible during normal execution — the program runs fine, but the sanitizer detects undefined behavior or memory errors.

### Available Sanitizers

| Sanitizer | Flag | What it catches |
|---|---|---|
| **AddressSanitizer (ASan)** | `-fsanitize=address` | Buffer overflows, use-after-free, double-free, memory leaks, stack-buffer-overflow |
| **UndefinedBehaviorSanitizer (UBSan)** | `-fsanitize=undefined` | Integer overflow, null dereference, misaligned pointers, signed overflow, shift out of bounds |

### How They Work

1. **Compile with `-fsanitize=...` flags** — compiler inserts runtime checks
2. **Run your program** — sanitizers monitor execution
3. **On error** — sanitizer prints a detailed report and aborts the program

### Usage

**Step 1: Configure with sanitizers enabled**

Use Debug build for best error reports:

```bash
conan install . --build=missing -s build_type=Debug
cmake --preset debug -DENABLE_SANITIZERS=ON
```

**Real example:**

```bash
conan install . --build=missing -s build_type=Debug
cmake --preset debug -DENABLE_SANITIZERS=ON
```

**Expected output:**

```
-- Sanitizers enabled (AddressSanitizer + UndefinedBehaviorSanitizer)
-- Configuring done
-- Generating done
```

**Step 2: Build**

```bash
cmake --build --preset debug
```

**Step 3: Run tests**

```bash
ctest --preset debug --output-on-failure
```

### Example: Catching a Buffer Overflow

Suppose you have this bug in your code:

```cpp
void process_data() {
    int buffer[10];
    buffer[15] = 42;  // buffer overflow!
}
```

Without sanitizers, this might "work" (undefined behavior). With ASan:

```bash
ctest --preset debug --output-on-failure
```

**Expected output:**

```
=================================================================
==12345==ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7ffd12345678
WRITE of size 4 at 0x7ffd12345678 thread T0
    #0 0x401234 in process_data() /path/to/src/main.cpp:3
    #1 0x401234 in main /path/to/src/main.cpp:7
    ...

Address 0x7ffd12345678 is located in stack of thread T0 at offset 56 in frame
    #0 0x401234 in process_data() /path/to/src/main.cpp:1

  This frame has 1 object(s):
    [32, 72) 'buffer' (line 2) <== Memory access at offset 56 overflows this variable
```

### Example: Catching Undefined Behavior

```cpp
int compute(int a, int b) {
    return a + b;  // signed integer overflow if a=INT_MAX, b=1
}
```

With UBSan:

```
/path/to/src/main.cpp:2:12: runtime error: signed integer overflow: 2147483647 + 1 cannot be represented in type 'int'
```

### Performance Impact

| Metric | Without Sanitizers | With Sanitizers |
|---|---|---|
| Execution speed | 1x | ~2-3x slower |
| Memory usage | 1x | ~2-3x higher |
| Binary size | 1x | ~2x larger |

**Use sanitizers only for development and testing builds, never for release.**

### Combining with Other Options

Sanitizers can be combined with code coverage and linting using the `debug-full` preset:

```bash
cmake --preset debug-full
```

**Real example:**

```bash
conan install . --build=missing -s build_type=Debug -s compiler.cppstd=23
cmake --preset debug-full
cmake --build --preset debug-full
ctest --preset debug-full --output-on-failure
cmake --build --preset debug-full --target coverage
```

This gives you:
- Runtime bug detection (sanitizers)
- Coverage reporting (coverage)
- Code quality enforcement (linting)

All in one build.

### Typical Workflow

```bash
# 1. Configure with sanitizers
conan install . --build=missing -s build_type=Debug
cmake --preset debug -DENABLE_SANITIZERS=ON

# 2. Build
cmake --build --preset debug

# 3. Run tests (sanitizers abort on first error)
ctest --preset debug --output-on-failure

# 4. Fix any issues reported by sanitizers
# 5. Re-run until all tests pass cleanly
```

---

## Typical Development Workflow

### Daily Development

```bash
# Configure Debug build (once)
conan install . --build=missing -s build_type=Debug
cmake --preset debug

# Build
cmake --build --preset debug

# Run tests
ctest --preset debug --output-on-failure
```

### Before Merging

```bash
# Full check: lint + build + test + coverage + sanitizers
conan install . --build=missing -s build_type=Debug -s compiler.cppstd=23
cmake --preset debug-full
cmake --build --preset debug-full
ctest --preset debug-full --output-on-failure
cmake --build --preset debug-full --target coverage

# Also verify Release build works
conan install . --build=missing -s build_type=Release
cmake --preset release-strict
cmake --build --preset release-strict
ctest --preset release-strict --output-on-failure
```

### CI/CD Pipeline

```bash
# Debug with sanitizers
conan install . --build=missing -s build_type=Debug -s compiler.cppstd=23
cmake --preset debug-sanitizers
cmake --build --preset debug-sanitizers
ctest --preset debug-sanitizers --output-on-failure

# Release
conan install . --build=missing -s build_type=Release
cmake --preset release-strict
cmake --build --preset release-strict
ctest --preset release-strict --output-on-failure
```

---

## Common Issues

### "lcov not found"

**Cause:** `lcov` is not installed.

**Solution:**

```bash
# Ubuntu/Debian
sudo apt-get install lcov

# macOS
brew install lcov
```

### "No rule to make target 'coverage'"

**Cause:** `lcov` or `genhtml` is not installed, so the `coverage` target was not created during configure.

**Solution:**

```bash
# Install lcov (includes genhtml)
sudo apt-get install lcov   # Ubuntu/Debian
brew install lcov            # macOS

# Verify installation
lcov --version

# Re-configure and rebuild
cmake --preset debug-coverage
cmake --build --preset debug-coverage
```

### "Coverage report is empty"

**Cause:** Tests were not run before generating the report.

**Solution:**

```bash
# Run tests first to collect coverage data
ctest --preset debug-coverage --output-on-failure

# Then generate report
cmake --build --preset debug-coverage --target coverage
```

### "Sanitizer error: ASan runtime does not come first"

**Cause:** Another library is conflicting with ASan.

**Solution:**

```bash
# Set environment variable
export LD_PRELOAD=$(clang -print-file-name=libclang_rt.asan-x86_64.so)

# Then run tests
ctest --preset debug --output-on-failure
```

### "Sanitizers not supported on MSVC"

**Cause:** MSVC uses different sanitizer flags.

**Solution:** Sanitizers in this project are GCC/Clang only. For MSVC, use `/fsanitize=address` manually in CMakeLists.txt.

---

## Summary

| Task | Command |
|---|---|
| Run tests | `ctest --preset release` |
| Run tests (verbose) | `ctest --preset release --output-on-failure` |
| Enable coverage | `cmake --preset debug-coverage` |
| Generate coverage report | `cmake --build --preset debug-coverage --target coverage` |
| Enable sanitizers | `cmake --preset debug-sanitizers` |
| Combine all | `cmake --preset debug-full` |

For build configuration details, see [Build Guide](BUILD.md).
For linting and formatting, see [Linting Guide](LINTING.md).
