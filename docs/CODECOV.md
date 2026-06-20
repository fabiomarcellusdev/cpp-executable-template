# Codecov Integration Guide

This document explains how to set up and use Codecov for code coverage reporting in this project.

---

## What is Codecov?

[Codecov](https://codecov.io) is a code coverage reporting service that:
- Tracks coverage trends over time
- Shows coverage changes in pull requests
- Provides detailed coverage reports
- Is free for public repositories

---

## Setup Instructions

### 1. Sign Up for Codecov

1. Go to [https://codecov.io](https://codecov.io)
2. Click **"Sign Up"**
3. Choose **"Sign up with GitHub"**
4. Authorize Codecov to access your GitHub account

### 2. Enable Your Repository

1. After signing in, click **"Add new repository"**
2. Find your repository in the list
3. Click **"Enable"**
4. Codecov will now track coverage for this repository

### 3. (Optional) Add Codecov Token

For public repositories, the token is optional but recommended for reliability:

1. In Codecov, go to your repository settings
2. Copy the **Repository Upload Token**
3. In your GitHub repository, go to **Settings → Secrets and variables → Actions**
4. Click **"New repository secret"**
5. Name: `CODECOV_TOKEN`
6. Value: paste the token from Codecov
7. Click **"Add secret"**

**Note:** For public repos, the GitHub Action will auto-detect the token, so this step is optional.

---

## How It Works

### Local Coverage

When you run the `debug-full` preset locally:

```bash
cmake --preset debug-full
cmake --build --preset debug-full
ctest --preset debug-full
cmake --build --preset debug-full --target coverage
```

The coverage target will:
1. Generate coverage data
2. Create an HTML report at `build/debug-full/coverage/html/index.html`
3. **Check if coverage meets the 80% threshold** (fails if below)

### CI Coverage

In GitHub Actions, the `debug-full` preset job will:
1. Build and test with coverage enabled
2. Generate the coverage report
3. **Upload to Codecov** (only on Linux + Clang to avoid duplicates)
4. **Fail if coverage is below 80%**

---

## Coverage Threshold

The project enforces a **minimum 80% line coverage** threshold.

### Where It's Enforced

1. **Locally**: The `cmake --build --preset debug-full --target coverage` command will fail if coverage is below 80%
2. **In CI**: The GitHub Actions job will fail if coverage is below 80%

### Changing the Threshold

To change the threshold, modify the `COVERAGE_THRESHOLD` CMake variable:

**Locally:**
```bash
cmake --preset debug-full -DCOVERAGE_THRESHOLD=90
```

**In CI:** Edit `.github/workflows/ci.yml` and add the variable to the CMake configure step.

**In CMakePresets.json:** Add to the `debug-full` preset:
```json
{
    "name": "debug-full",
    "cacheVariables": {
        "ENABLE_SANITIZERS": "ON",
        "ENABLE_COVERAGE": "ON",
        "ENABLE_LINTING": "ON",
        "COVERAGE_THRESHOLD": "90"
    }
}
```

---

## Viewing Coverage Reports

### Codecov Dashboard

1. Go to [https://codecov.io](https://codecov.io)
2. Select your repository
3. View:
   - **Overall coverage percentage**
   - **Coverage trends** (graphs over time)
   - **File-by-file coverage**
   - **PR coverage changes**

### Pull Request Comments

Codecov automatically comments on PRs with:
- Coverage change (e.g., "Coverage increased by 2.3%")
- Files with decreased coverage
- Link to detailed report

### Local Reports

Open the HTML report in your browser:

```bash
# Linux
xdg-open build/debug-full/coverage/html/index.html

# macOS
open build/debug-full/coverage/html/index.html
```

---

## Troubleshooting

### "Coverage check passed" but CI fails

**Cause:** CI might be using a different coverage file path.

**Solution:** Check the Codecov upload step in `.github/workflows/ci.yml` to ensure the path matches your build directory.

### "Could not parse coverage data"

**Cause:** Coverage file is empty or malformed.

**Solution:**
1. Ensure tests ran successfully: `ctest --preset debug-full`
2. Check that `.gcda` files were generated in `build/debug-full/`
3. Re-run the coverage target

### Codecov not showing coverage

**Cause:** Token not configured or upload failed.

**Solution:**
1. Check GitHub Actions logs for the "Upload coverage to Codecov" step
2. Ensure the repository is enabled in Codecov
3. (Optional) Add `CODECOV_TOKEN` secret to GitHub

### Coverage percentage seems wrong

**Cause:** Coverage excludes tests, external code, and system headers.

**Solution:** This is intentional. The coverage percentage only measures your production code in `src/`, not test code or dependencies.

---

## Best Practices

1. **Run coverage locally before pushing:**
   ```bash
   cmake --build --preset debug-full --target coverage
   ```

2. **Check PR coverage comments:** Codecov will warn you if your PR decreases coverage

3. **Aim for meaningful coverage:** Don't just write tests to hit 80% — write tests that verify behavior

4. **Review coverage reports:** Use the HTML report to find untested code paths

5. **Update threshold as needed:** If 80% is too easy/hard, adjust it in `CMakePresets.json`

---

## Summary

| Task | Command |
|---|---|
| Generate coverage locally | `cmake --build --preset debug-full --target coverage` |
| View HTML report | `open build/debug-full/coverage/html/index.html` |
| Check threshold | Automatic (fails if < 80%) |
| View Codecov dashboard | [https://codecov.io](https://codecov.io) |
| Change threshold | `cmake --preset debug-full -DCOVERAGE_THRESHOLD=90` |

For more information on testing and sanitizers, see [Testing Guide](TESTING.md).
