# CI Caching Guide

This document explains how GitHub Actions caching works in this project's CI pipeline.

---

## How CI Jobs Run

Each CI job starts on a **fresh virtual machine** with:
- No previous build artifacts
- No installed tools (except GitHub-provided defaults)
- No cached data in the filesystem

Data only persists between runs through:
- **Caches** (dependency caching)
- **Artifacts** (explicit upload/download)
- **External storage** (GitHub Packages, etc.)

---

## Conan Dependency Caching

This project caches Conan packages (`~/.conan2`) to speed up builds.

### Cache Key Structure

The cache key includes:
- **OS** (e.g., `ubuntu-latest`, `macos-latest`)
- **Compiler** (e.g., `gcc`, `clang`)
- **Preset** (e.g., `release-strict`, `debug-sanitizers`)
- **Conanfile hash** (automatically invalidates when dependencies change)

Example: `conan-ubuntu-latest-gcc-release-strict-<hash>`

### Cache Behavior

- **Persistence:** 7 days after last access
- **Scope:** Repository and branch (main branch caches are available to PRs)
- **Invalidation:** Automatic when `conanfile.txt` or `conanfile.py` changes

### Why CC/CXX Must Be Passed to Conan

The cache key includes the compiler (gcc/clang), so Conan must actually use that compiler when building packages. Without setting `CC` and `CXX`:

- Conan detects the system default compiler (usually gcc on Ubuntu)
- Both gcc and clang cache keys end up storing identical gcc-built packages
- You waste cache storage and risk compiler mismatches

By setting `CC`/`CXX` for Conan steps, each cache key contains packages built with the correct compiler, keeping the cache segmentation accurate and meaningful.

See [CI Compiler Configuration](CI.md) for details on CC/CXX.

---

## Cache Hit Scenarios

### Best Scenarios (High Hit Rate)

1. **Frequent commits without dependency changes** — Every build hits the cache
2. **PRs targeting main** — Reuse caches created by main branch builds
3. **Stable dependency periods** — Weeks without updating dependencies

### Worst Scenarios (Cache Misses)

- Modifying `conanfile.txt` or `conanfile.py`
- First build on a new branch that diverged before dependencies were cached
- After 7 days of inactivity (cache expires)

---

## Benefits

- **Time savings:** 1-5+ minutes per job (skips downloading/building dependencies)
- **Cost reduction:** Fewer CI minutes consumed
- **Network efficiency:** Reduced external API calls

---

## Summary

| Aspect | Behavior |
|---|---|
| Cache persistence | 7 days after last access |
| Cache scope | Repository + branch |
| Invalidation | Automatic on conanfile changes |
| Best use case | Stable dependencies with frequent builds |
| Time saved | 1-5+ minutes per job |

For more information on the CI pipeline, see `.github/workflows/ci.yml`.
