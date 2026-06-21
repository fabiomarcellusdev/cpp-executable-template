# Code Quality Guide

This document explains how to use the formatting and linting tools integrated into this project.

---

## Overview

This project enforces code quality through three tools:

| Tool | Purpose | Configuration |
|---|---|---|
| **clang-format** | Code formatting (whitespace, braces, indentation) | `.clang-format` |
| **clang-tidy** | Static analysis (bugs, naming, modernization) | `.clang-tidy` |
| **CMake check-headers** | Enforces `#pragma once` in all headers | `cmake/CheckPragmaOnce.cmake` |

All three are integrated into CMake as custom targets and can be run manually or enforced during builds.

---

## clang-format

### What It Does

`clang-format` automatically formats C++ code according to rules defined in `.clang-format`. It handles:

- Indentation (4 spaces)
- Brace placement (attached/K&R style)
- Line wrapping (100-column limit)
- Pointer/reference alignment (left-aligned: `int* p`)
- Include sorting and grouping
- Whitespace around operators

### Checking Formatting

Checks if files comply with `.clang-format` without modifying them:

```bash
cmake --build build --target format-check
```

**Real example:**

```bash
cmake --build build/release --target format-check
```

**Expected output (clean):**

```
[1/1] Checking code formatting...
```

**Expected output (issues found):**

```
[1/1] Checking code formatting...
src/main.cpp:3:1: warning: code should be clang-formatted [-Wclang-format-warning]
int main() {
^
ninja: build stopped: subcommand failed.
```

The command exits with a non-zero status if any file is unformatted, making it suitable for CI.

### Auto-Fixing Formatting

Applies formatting rules to all source and header files:

```bash
cmake --build build --target format-fix
```

**Real example:**

```bash
cmake --build build/release --target format-fix
```

**Expected output:**

```
[1/1] Fixing code formatting...
```

This modifies files in place. Always review changes with `git diff` after running format-fix.

### Running clang-format Directly

You can also run clang-format without CMake:

```bash
# Check a single file
clang-format --dry-run --Werror src/main.cpp

# Fix a single file
clang-format -i src/main.cpp

# Fix all C++ files
clang-format -i src/*.cpp include/**/*.hpp tests/*.cpp
```

---

## clang-tidy

### What It Does

`clang-tidy` performs static analysis on C++ code. It checks for:

- **Bug-prone patterns** — null dereference, use-after-move, uninitialized variables
- **C++ Core Guidelines** — modern C++ best practices
- **Modernization** — suggests using `auto`, range-based for loops, `nullptr` instead of `NULL`
- **Performance** — unnecessary copies, inefficient containers
- **Readability** — naming conventions (enforced via `.clang-tidy`)
- **Naming conventions** — `snake_case` for functions/variables, `PascalCase` for classes, `UPPER_CASE` for macros

### Running the Linter

```bash
cmake --build build --target lint
```

**Real example:**

```bash
cmake --build build/release --target lint
```

**Expected output (clean):**

```
[1/1] Running clang-tidy...
```

**Expected output (issues found):**

```
[1/1] Running clang-tidy...
/path/to/src/main.cpp:3:5: warning: function 'main' is missing a return type [readability-identifier-naming]
int main() {
    ^
```

### Understanding clang-tidy Output

Each warning includes:
- **File and line number** — where the issue was found
- **Warning message** — description of the problem
- **Check name** — which clang-tidy check triggered it (e.g., `[readability-identifier-naming]`)

### How Lint Knows Which Build Configuration

The lint target uses `compile_commands.json` from whichever build directory you specify:

```bash
cmake --build build/release --target lint   # uses build/release/compile_commands.json
cmake --build build/debug --target lint     # uses build/debug/compile_commands.json
```

**Does lint run on both Release and Debug?**

No. You must specify which build directory to use. Lint analyzes source code structure, not compiled output, so the build type doesn't affect the analysis results. The only difference between Release and Debug `compile_commands.json` is compiler flags (`-O2` vs `-g -O0`), which doesn't change static analysis.

**Running lint once (on either preset) is sufficient.** Running on both is redundant but harmless — it would only catch extremely rare configuration-specific issues.

**Important:** You must configure the project first to generate `compile_commands.json`:

```bash
# Configure (generates compile_commands.json)
cmake --preset release

# Now lint works
cmake --build build/release --target lint
```

### Running clang-tidy Directly

```bash
clang-tidy -p build/release src/main.cpp
```

The `-p` flag points to the directory containing `compile_commands.json`.

---

## Header Checks

### What It Does

Verifies that every header file in `include/` contains `#pragma once` at the top. This prevents multiple inclusion errors and is enforced by `cmake/CheckPragmaOnce.cmake`.

### Running the Check

```bash
cmake --build build --target check-headers
```

**Real example:**

```bash
cmake --build build/release --target check-headers
```

**Expected output (clean):**

```
[1/1] Checking headers for #pragma once...
```

**Expected output (missing pragma once):**

```
[1/1] Checking headers for #pragma once...
CMake Warning at cmake/CheckPragmaOnce.cmake:7:
  Missing #pragma once: /path/to/include/my_project_name/config.hpp
CMake Error: Some headers are missing #pragma once
```

### Fixing Missing `#pragma once`

Add this as the first line of the header file:

```cpp
#pragma once

// rest of header...
```

---

## Available CMake Targets

| Target | Description | Modifies Files? |
|---|---|---|
| `format-check` | Checks formatting without modifying files | No |
| `format-fix` | Auto-fixes formatting in all source and header files | Yes |
| `lint` | Runs clang-tidy static analysis on all source files | No |
| `check-headers` | Verifies all headers contain `#pragma once` | No |

---

## Pre-commit Hooks

### What They Are

Pre-commit hooks run automatically before each `git commit`. This project uses [pre-commit](https://pre-commit.com/) with these hooks:

| Hook | What it does |
|---|---|
| `trailing-whitespace` | Removes trailing whitespace from all files |
| `end-of-file-fixer` | Ensures files end with exactly one newline |
| `check-yaml` | Validates YAML syntax |
| `check-added-large-files` | Prevents committing large files |
| `check-merge-conflict` | Detects unresolved merge conflict markers |
| `clang-format` | Formats C++ files according to `.clang-format` |

### Installation

```bash
pip install pre-commit
pre-commit install
```

**Real example:**

```bash
pip install pre-commit
pre-commit install
```

**Expected output:**

```
pre-commit installed at .git/hooks/pre-commit
```

### How It Works

After installation, every `git commit` triggers the hooks:

```bash
git add src/main.cpp
git commit -m "Add feature"
```

**Expected output:**

```
Trim Trailing Whitespace..............................Passed
Fix End of Files......................................Passed
Check Yaml............................................Passed
Check for added large files...........................Passed
Check for merge conflicts.............................Passed
clang-format..........................................Passed
[main abc1234] Add feature
 1 file changed, 10 insertions(+)
```

If any hook fails, the commit is blocked. For example, if clang-format finds issues:

```
clang-format..........................................Failed
- hook id: clang-format
- files were modified by this hook
```

The files are auto-fixed. You just need to `git add` the modified files and commit again.

### Running Manually

Run all hooks on all files (useful before pushing):

```bash
pre-commit run --all-files
```

**Real example:**

```bash
pre-commit run --all-files
```

**Expected output:**

```
Trim Trailing Whitespace..............................Passed
Fix End of Files......................................Passed
Check Yaml............................................Passed
Check for added large files...........................Passed
Check for merge conflicts.............................Passed
clang-format..........................................Passed
```

### Updating Hooks

```bash
pre-commit autoupdate
```

---

## Enforcing During Build

### The `ENABLE_LINTING` Option

When enabled, the build fails if any formatting or linting issues are detected:

```bash
cmake --preset release -DENABLE_LINTING=ON
cmake --build --preset release
```

**Real example:**

```bash
cmake --preset release -DENABLE_LINTING=ON
cmake --build --preset release
```

**What happens when `ENABLE_LINTING=ON`:**

1. **Before compilation:** `clang-format --dry-run` checks all source files. Build fails if any file is unformatted.
2. **During compilation:** `clang-tidy` runs on every compilation unit. Build fails on any warning.
3. **Before compilation:** `#pragma once` is verified for all headers. Build fails if any header is missing it.

**When to use:**

- CI/CD pipelines (ensures no unformatted code merges)
- Strict development workflows (catches issues immediately)

**When NOT to use:**

- Quick prototyping (slows down iteration)
- When actively refactoring (formatting changes frequently)

---

## Naming Conventions

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

---

## Typical Development Workflow

### Daily Development

1. **Write code** in your editor/IDE
2. **Save files** — your editor may auto-format on save if configured
3. **Run format-fix** to ensure consistent formatting:
   ```bash
   cmake --build build/release --target format-fix
   ```
4. **Run lint** to catch issues early:
   ```bash
   cmake --build build/release --target lint
   ```
5. **Fix any warnings** reported by lint
6. **Commit** — pre-commit hooks run clang-format as a safety net:
   ```bash
   git add .
   git commit -m "Add feature"
   ```

### Before Pushing

Run all checks to ensure CI will pass:

```bash
# Format check
cmake --build build/release --target format-check

# Lint
cmake --build build/release --target lint

# Header check
cmake --build build/release --target check-headers

# Build
cmake --build --preset release

# Test
ctest --preset release

# Pre-commit on all files
pre-commit run --all-files
```

### CI/CD Pipeline

In CI, enforce everything:

```bash
cmake --preset release -DENABLE_LINTING=ON
cmake --build --preset release
ctest --preset release --output-on-failure
```

---

## Common Issues

### "clang-format not found"

**Cause:** `clang-format` is not installed.

**Solution:**

```bash
# Ubuntu/Debian
sudo apt-get install clang-format

# macOS
brew install clang-format

# Verify
clang-format --version
```

### "clang-tidy not found"

**Cause:** `clang-tidy` is not installed.

**Solution:**

```bash
# Ubuntu/Debian
sudo apt-get install clang-tidy

# macOS
brew install llvm  # includes clang-tidy

# Verify
clang-tidy --version
```

### "compile_commands.json not found"

**Cause:** Project was not configured with CMake.

**Solution:**

```bash
cmake --preset release
```

### "pre-commit: command not found"

**Cause:** `pre-commit` is not installed.

**Solution:**

```bash
pip install pre-commit
pre-commit install
```

---

## Summary

| Task | Command |
|---|---|
| Check formatting | `cmake --build build/release --target format-check` |
| Auto-fix formatting | `cmake --build build/release --target format-fix` |
| Run linter | `cmake --build build/release --target lint` |
| Check headers | `cmake --build build/release --target check-headers` |
| Enforce during build | `cmake --preset release -DENABLE_LINTING=ON` |
| Install pre-commit | `pip install pre-commit && pre-commit install` |
| Run all hooks | `pre-commit run --all-files` |

For build configuration details, see [Build Guide](BUILD.md).
For testing, coverage, and sanitizers, see [Testing Guide](TESTING.md).
