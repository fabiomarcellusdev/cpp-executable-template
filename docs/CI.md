# CI Compiler Configuration

This document explains how compilers are configured in the CI pipeline.

---

## What are CC and CXX?

**CC** and **CXX** are standard environment variables that tell build tools which compilers to use:

- **CC** — Path to the C compiler (e.g., `gcc`, `clang`)
- **CXX** — Path to the C++ compiler (e.g., `g++`, `clang++`)

These variables are recognized by:
- CMake
- Make
- Conan
- Most Unix-based build systems

---

## How This Project Uses CC/CXX

The CI matrix tests multiple compilers across different operating systems:

| OS | Compiler | CC | CXX |
|---|---|---|---|
| ubuntu-latest | gcc | gcc | g++ |
| ubuntu-latest | clang | clang | clang++ |
| macos-latest | clang | clang | clang++ |

The workflow sets these variables for all build steps:

```yaml
env:
  CC: ${{ matrix.compiler == 'gcc' && 'gcc' || 'clang' }}
  CXX: ${{ matrix.compiler == 'gcc' && 'g++' || 'clang++' }}
```

---

## Why This Matters

Setting CC/CXX ensures:
1. **Consistent compiler selection** — All tools (Conan, CMake, etc.) use the same compiler
2. **Correct cache segmentation** — Dependencies are built with the intended compiler
3. **Reproducible builds** — Same inputs produce same outputs regardless of system defaults

For more information on caching, see [CI Caching Guide](CI_CACHING.md).
