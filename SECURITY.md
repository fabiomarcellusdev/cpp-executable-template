# Security Policy

## Supported Versions

This project is a template repository. Security updates are applied to the latest version only.

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| Older   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please report it responsibly.

### How to Report

**Preferred method:** Use GitHub's private vulnerability reporting feature:
1. Go to the repository's **Security** tab
2. Click **"Report a vulnerability"**
3. Provide detailed information about the vulnerability
4. Submit the report

**Alternative:** If the GitHub feature is unavailable, email the maintainer directly (contact information should be in the repository's README or profile).

### What to Include

- Description of the vulnerability
- Steps to reproduce (if applicable)
- Potential impact
- Suggested fix (if you have one)

### What to Expect

- **Acknowledgment:** We will acknowledge receipt of your report within 48 hours
- **Assessment:** We will assess the vulnerability and determine its severity within 7 days
- **Resolution:** We will work to address the issue and provide updates on our progress
- **Disclosure:** Once resolved, we will coordinate disclosure with you

### Disclosure Policy

- We will not disclose the vulnerability publicly until a fix is available
- We will credit reporters in security advisories (unless anonymity is requested)
- We follow responsible disclosure principles

## Security Best Practices for Users

When using this template:

1. **Update dependencies regularly** - Run `conan install . --build=missing` to get the latest dependency versions
2. **Keep tools updated** - Use current versions of CMake, Conan, clang-format, and clang-tidy
3. **Review CI/CD workflows** - Ensure GitHub Actions workflows use pinned versions and follow security best practices
4. **Enable branch protection** - Require status checks and reviews before merging to main
5. **Use secret scanning** - Enable GitHub's secret scanning to prevent accidental credential commits

## Scope

This security policy applies to:
- The template repository itself
- CMake configuration files
- CI/CD workflows
- Documentation

It does not apply to:
- Projects created from this template (those have their own security policies)
- Third-party dependencies managed by Conan (report issues to upstream maintainers)
