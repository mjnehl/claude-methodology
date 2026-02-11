# Verification Command

Run comprehensive verification on current codebase state.

## Methodology Integration

Implements verification requirements from `.claude/docs/CONTRIBUTING.md`:
- Run verification after each significant change
- All checks must pass before commits/PRs

## Instructions

Execute verification in this exact order:

1. **Build Check**
   - Run the build command for this project
   - If it fails, report errors and STOP

2. **Type Check**
   - Run TypeScript/type checker
   - Report all errors with file:line

3. **Lint Check**
   - Run linter
   - Report warnings and errors

4. **Test Suite**
   - Run all unit/integration tests
   - Report pass/fail count
   - Report coverage percentage (target: 80% per TESTING.md)

5. **E2E Tests** (only for `full` and `pre-pr` modes)
   - Run Playwright E2E suite if it exists (`npx playwright test`)
   - Report pass/fail count
   - If E2E fails: note which journey failed and remind to feed into TDD loop
   - Skip gracefully if no E2E suite is configured

6. **Security Scan**
   - Search for console.log in source files
   - Check for hardcoded secrets

7. **Git Status**
   - Show uncommitted changes
   - Show files modified since last commit

## Output

Produce a concise verification report:

```
VERIFICATION: [PASS/FAIL]

Build:    [OK/FAIL]
Types:    [OK/X errors]
Lint:     [OK/X issues]
Tests:    [X/Y passed, Z% coverage]
E2E:      [OK/X failures/SKIPPED] (full/pre-pr only)
Secrets:  [OK/X found]
Logs:     [OK/X console.logs]

Ready for PR: [YES/NO]
```

If any critical issues, list them with fix suggestions.

## Arguments

$ARGUMENTS can be:
- `quick` - Only build + types (fastest, use during active development)
- `full` - All checks including E2E (default)
- `pre-commit` - Build + types + lint + unit tests (no E2E)
- `pre-pr` - All checks including E2E + security scan (most thorough)
