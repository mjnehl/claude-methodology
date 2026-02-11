# TDD Command

Enforce test-driven development workflow.

## Methodology Integration

Implements TDD approach from `.claude/docs/TESTING.md`:
- TDD is the default for all new code
- Tests serve as specification AND verification
- 80%+ coverage required

## What This Command Does

1. **Scaffold Interfaces** - Define types/interfaces first
2. **Generate Tests First** - Write failing tests (RED)
3. **Implement Minimal Code** - Write just enough to pass (GREEN)
4. **Refactor** - Improve code while keeping tests green (REFACTOR)
5. **Verify Coverage** - Ensure 80%+ test coverage

## TDD Cycle

```
RED → GREEN → REFACTOR → REPEAT

RED:      Write a failing test
GREEN:    Write minimal code to pass
REFACTOR: Improve code, keep tests passing
REPEAT:   Next feature/scenario
```

**Step-completion gate:** After completing each implementation step, check coverage. Address gaps before proceeding. See `.claude/docs/TESTING.md` § "Step-Completion Coverage Gate".

## When to Use

Use `/tdd` when:
- Implementing new features
- Adding new functions/components
- Fixing bugs (write test that reproduces bug first)
- Building critical business logic

## Test Types to Include

**Unit Tests** (Function-level):
- Happy path scenarios
- Edge cases (empty, null, max values)
- Error conditions

**Integration Tests** (Component-level):
- API endpoints
- Database operations
- Component interactions

## Coverage Requirements

- **80% minimum** for all code
- **100% required** for:
  - Financial calculations
  - Authentication logic
  - Security-critical code

## Best Practices

**DO:**
- Write the test FIRST, before any implementation
- Run tests and verify they FAIL before implementing
- Write minimal code to make tests pass
- Aim for 80%+ coverage

**DON'T:**
- Write implementation before tests
- Skip running tests after each change
- Test implementation details (test behavior)

## Related Agent

Invokes the `tdd-guide` agent for detailed TDD workflow.
