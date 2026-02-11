# Code Review Command

Comprehensive security and quality review of uncommitted changes.

## Methodology Integration

Implements code review guidance from `.claude/docs/CONTRIBUTING.md`.

## Instructions

1. Get changed files: `git diff --name-only HEAD`

2. For each changed file, check for:

**Security Issues (CRITICAL):**
- Hardcoded credentials, API keys, tokens
- SQL injection vulnerabilities
- XSS vulnerabilities
- Missing input validation
- Insecure dependencies
- Path traversal risks

**Code Quality (HIGH):**
- Functions > 50 lines
- Files > 800 lines
- Nesting depth > 4 levels
- Missing error handling
- console.log statements
- TODO/FIXME comments
- Missing JSDoc for public APIs

**Best Practices (MEDIUM):**
- Mutation patterns (use immutable instead)
- Missing tests for new code (see TESTING.md)
- Accessibility issues (a11y)

3. Generate report with:
   - Severity: CRITICAL, HIGH, MEDIUM, LOW
   - File location and line numbers
   - Issue description
   - Suggested fix

4. Block commit if CRITICAL or HIGH issues found

## Methodology Alignment

Also check:
- Does code follow patterns in `docs/patterns/`?
- Are there decisions that need an ADR?
- Is documentation updated?
- Were tests written (TDD per TESTING.md)?

Never approve code with security vulnerabilities!
