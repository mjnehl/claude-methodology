# Testing Requirements

## Methodology Integration

Aligns with coverage requirements from `.claude/docs/TESTING.md`:
- 80% minimum coverage for all code
- 100% for critical paths

## Test Types (ALL required)

1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (Playwright)

## Test-Driven Development

MANDATORY for new features: RED → GREEN → REFACTOR. Use the **tdd-guide** agent, which enforces the full workflow. See `.claude/docs/TESTING.md` § "TDD Is the Default" for principles.

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation (no shared state)
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)
5. Check for async timing issues

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first
- **e2e-runner** - Playwright E2E testing specialist

## Test Organization

```
tests/
├── unit/           # Fast, isolated tests
├── integration/    # API and database tests
└── e2e/           # Playwright browser tests
```

## What to Test

- Happy path scenarios
- Error handling and edge cases
- Boundary conditions (null, undefined, empty, max values)
- Authentication and authorization
- Data validation

## What NOT to Test

- Implementation details (test behavior, not internals)
- Third-party library internals
- Simple getters/setters without logic
