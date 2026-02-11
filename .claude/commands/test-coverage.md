# Test Coverage Command

Analyze test coverage and generate missing tests.

## Methodology Integration

Supports coverage requirements from `.claude/docs/TESTING.md`:
- 80% minimum coverage for all code
- 100% for critical paths

## Instructions

1. Run tests with coverage: `npm test --coverage`

2. Analyze coverage report

3. Identify files below 80% coverage threshold

4. For each under-covered file:
   - Analyze untested code paths
   - Generate unit tests for functions
   - Generate integration tests for APIs

5. Verify new tests pass

6. Show before/after coverage metrics

7. Ensure project reaches 80%+ overall coverage

## Focus Areas

When generating tests, prioritize:
- Happy path scenarios
- Error handling
- Edge cases (null, undefined, empty)
- Boundary conditions

## Output Format

```
COVERAGE REPORT
===============

Before: 65%
After:  83%

Files Improved:
- src/utils.ts: 45% -> 92%
- src/api.ts: 70% -> 88%

Tests Added: 12
All Tests Passing: YES

Coverage Target (80%): MET
```

## Related Command

Use `/tdd` to write new code with tests from the start.
