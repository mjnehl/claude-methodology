# Testing Strategy

This document describes principles and patterns for testing in AI-driven development. Testing serves as both verification and documentation of expected behavior.

## Core Philosophy

### Why Testing Matters More with AI

AI-generated code requires verification. Tests provide:

- **Confidence** - Does the code actually work?
- **Specification** - What should the code do?
- **Regression protection** - Did new changes break existing behavior?
- **Documentation** - How is the code intended to be used?

Without tests, you're trusting AI output blindly. With tests, you're verifying it.

### The Testing Mindset

```
┌─────────────────────────────────────────────────────────────────┐
│                    Human Responsibility                         │
│  - Define what "correct" means                                  │
│  - Identify edge cases and failure modes                        │
│  - Review test coverage and quality                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AI Responsibility                            │
│  - Implement tests for defined requirements                     │
│  - Generate test cases from specifications                      │
│  - Suggest edge cases human might miss                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Automated Verification                       │
│  - Run tests on every change                                    │
│  - Block merges on test failure                                 │
│  - Report coverage and quality metrics                          │
└─────────────────────────────────────────────────────────────────┘
```

## Principles

### 1. Test Requirements, Not Implementation

Tests should verify *what* the code does, not *how* it does it:

**Good:**
```typescript
test('createUser returns user with hashed password', async () => {
  const user = await createUser({ email: 'test@example.com', password: 'secret' });

  expect(user.email).toBe('test@example.com');
  expect(user.password).not.toBe('secret'); // Password is hashed
  expect(await verifyPassword('secret', user.password)).toBe(true);
});
```

**Less good:**
```typescript
test('createUser calls bcrypt.hash with cost factor 10', async () => {
  // Testing implementation details, not behavior
});
```

Implementation can change; requirements should be stable.

### 2. Test at the Right Level

Different test types answer different questions:

| Test Type | Question Answered | Speed | Isolation |
|-----------|-------------------|-------|-----------|
| Unit | Does this function work correctly? | Fast | High |
| Integration | Do these components work together? | Medium | Medium |
| End-to-end | Does the whole system work? | Slow | Low |

**The testing pyramid:**

```
        ┌─────┐
        │ E2E │        Few, slow, high confidence
        ├─────┤
      ┌─┴─────┴─┐
      │ Integration │   Some, medium speed
      ├───────────┤
    ┌─┴───────────┴─┐
    │     Unit      │   Many, fast, focused
    └───────────────┘
```

Most tests should be unit tests. Integration and E2E tests cover critical paths.

### 3. Tests as Specification

Write tests that serve as documentation:

```typescript
describe('User Authentication', () => {
  describe('login', () => {
    it('succeeds with valid credentials', async () => { /* ... */ });
    it('fails with wrong password', async () => { /* ... */ });
    it('fails with non-existent email', async () => { /* ... */ });
    it('locks account after 5 failed attempts', async () => { /* ... */ });
    it('unlocks account after 15 minutes', async () => { /* ... */ });
  });
});
```

Reading these tests tells you exactly how authentication works.

### 4. Test Edge Cases Explicitly

AI might generate happy-path code. Ensure tests cover:

- **Empty inputs** - Empty strings, empty arrays, null/undefined
- **Boundary values** - Zero, one, max, min
- **Error conditions** - Network failures, invalid data, timeouts
- **Concurrent access** - Race conditions, deadlocks
- **Security cases** - Injection, overflow, unauthorized access

**Prompt Claude:**
> "What edge cases should I test for this function?"

### 5. Keep Tests Fast

Slow tests get skipped. Keep the feedback loop tight:

| Test Suite | Target Time |
|------------|-------------|
| Unit tests | < 10 seconds |
| Integration tests | < 2 minutes |
| Full suite | < 10 minutes |

If tests are slow:
- Mock external services
- Use in-memory databases for unit tests
- Parallelize where possible
- Run slow tests separately (CI only)

## When to Write Tests

### TDD Is the Default

**Checkpoint question:** "Can I describe what this code should do?"

If yes → Write tests first. TDD is the default workflow.

**TDD Workflow:**
```
1. Write failing test that describes expected behavior
2. Ask Claude to implement code that passes
3. Verify test passes
4. Refactor if needed
```

#### Step-Completion Coverage Gate

TDD validates behavior but not coverage. Branch coverage gaps accumulate silently across implementation steps — a 2-branch gap per step becomes a 374-branch gap after 9 steps.

**After completing each implementation step in a multi-step plan:**

```bash
npm test -- --coverage --coverageReporters=text-summary
```

If any threshold is failing or has dropped by more than 1% from the previous step, address it before proceeding. Small gaps (2-5 branches) are trivial to fix in context; large gaps at the end require costly remediation rounds.

**When modifying an existing file**, check its coverage first:

```bash
npm test -- --coverage --collectCoverageFrom='src/path/to/file.ts' --coverageReporters=text
```

If the file is below 80% branches, write tests for the most critical untested branches as part of your current step — enough to establish a positive trend. Don't add branches to a file without improving its coverage floor.

**Why TDD by default:**
- Forces clear thinking about requirements before coding
- Tests exist as specification, not afterthought
- Catches misunderstandings early
- Aligns with interface-first principle (see APPROACH.md)

### E2E: The Outer Loop (Dual-Loop Testing)

TDD validates components. E2E validates user journeys. Together they form a dual loop:

```
┌──────────────────────────────────────────────────────────┐
│  OUTER LOOP: E2E (Playwright)                            │
│  Validates complete user journeys                        │
│                                                          │
│   ┌──────────────────────────────────────────────────┐   │
│   │  INNER LOOP: TDD (Unit/Integration)              │   │
│   │  Validates individual components                 │   │
│   └──────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

**Critical rule: E2E failures always feed into the TDD loop before being fixed.**

```
E2E fails → Ask: "What unit test should have caught this?"
         → Write that unit test (RED)
         → Fix the code (GREEN)
         → Verify both loops pass
```

This prevents fixing E2E directly without strengthening the unit test suite. The inner loop grows organically from real defects, and the same bug class gets caught at the fast layer next time.

| Scenario | Flow |
|----------|------|
| New feature | TDD first → implement → E2E validates the journey |
| E2E failure | E2E detects → write missing unit test → fix → both pass |
| Bug report | Write E2E to reproduce → unit test to isolate → fix → both pass |

**When to write E2E tests:**
- After completing a user story that touches a critical journey
- When a bug is found through manual testing (reproduce with E2E first)
- Before major releases or phase milestones

**E2E is on by default.** Projects where E2E doesn't apply (CLI-only tools, libraries, pure backend services) should explicitly opt out in their `CLAUDE.md`:

```markdown
## Testing
E2E: not applicable — [reason, e.g., "CLI-only project, no UI"]
```

**What counts as a "critical journey"?** User-facing flows from acceptance criteria. Examples:
- Authentication (login, logout, registration)
- Core CRUD operations end-to-end
- Multi-step workflows (checkout, onboarding)
- Data integrity across operations (create → modify → verify persisted)

### Test-After Is the Exception

Test-after requires justification. Valid reasons:

- **Exploratory spike** - Deliberately throwaway code to learn
- **Genuinely fuzzy requirements** - You truly can't describe expected behavior yet
- **Learning a new domain** - Building understanding before specification

**Critical rule:** If test-after code is kept (not thrown away), tests must be written in the same session before work is considered complete.

**Test-After Workflow:**
```
1. Acknowledge this is exploratory (spike)
2. Implement to learn
3. BEFORE completing: Either delete OR write tests
4. No untested code survives the session
```

### Always Test:

- Public API surfaces
- Business-critical logic
- Security-sensitive code
- Code that's failed before (regression tests)

### Skip Tests For:

- Throwaway prototypes
- Generated boilerplate (if generator is tested)
- Simple pass-through code
- Third-party library wrappers (test your usage, not the library)

## Agent Support for Testing

Use specialized agents for testing workflows:

| Agent | Purpose |
|-------|---------|
| **tdd-guide** | Enforces TDD workflow, writes tests first |
| **e2e-runner** | Playwright E2E testing specialist |

**Commands:**
- `/tdd` - Start test-driven development workflow
- `/test-coverage` - Analyze and improve test coverage
- `/e2e` - Run E2E test suite with agent support

The tdd-guide agent should be used **proactively** for new features and bug fixes.

## Working with Claude on Tests

### Generating Tests

**Be specific about what to test:**
> "Write unit tests for the `validateEmail` function. Cover valid emails, invalid formats, empty input, and very long strings."

**Provide context:**
> "Here's the function: [code]. Write tests that verify the documented behavior in the JSDoc comments."

**Request edge cases:**
> "What edge cases am I missing in these tests? [existing tests]"

### Reviewing AI-Generated Tests

Check for:

- **Meaningful assertions** - Not just "it doesn't throw"
- **Independence** - Tests don't depend on each other
- **Clarity** - Test names describe what's being tested
- **Coverage** - Happy path AND error cases
- **Realistic data** - Not just "test" and "example"

**Red flag:**
```typescript
test('it works', () => {
  const result = doThing();
  expect(result).toBeDefined(); // Too vague
});
```

**Better:**
```typescript
test('calculateTotal sums line items and applies tax', () => {
  const result = calculateTotal([
    { price: 10.00, quantity: 2 },
    { price: 5.00, quantity: 1 }
  ], { taxRate: 0.08 });

  expect(result.subtotal).toBe(25.00);
  expect(result.tax).toBe(2.00);
  expect(result.total).toBe(27.00);
});
```

### Test-Driven Prompting

Use tests to specify behavior to Claude:

> "Implement a function that passes these tests: [paste tests]"

This gives Claude:
- Clear requirements
- Expected input/output
- Edge cases to handle
- Immediate verification

## Test Organization

### Directory Structure

```
src/
├── users/
│   ├── user.service.ts
│   ├── user.service.test.ts      # Unit tests next to code
│   └── user.repository.ts
├── orders/
│   └── ...
tests/
├── integration/
│   ├── user-orders.test.ts       # Cross-module integration
│   └── api.test.ts               # API integration tests
└── e2e/
    └── checkout-flow.test.ts     # Full user journey tests
```

### Naming Conventions

```typescript
// File: user.service.test.ts

describe('UserService', () => {
  describe('createUser', () => {
    it('creates user with valid data', () => {});
    it('throws ValidationError for invalid email', () => {});
    it('hashes password before storing', () => {});
  });

  describe('findByEmail', () => {
    it('returns user when found', () => {});
    it('returns null when not found', () => {});
  });
});
```

### Test Utilities

Create helpers for common patterns:

```typescript
// tests/helpers.ts

export function createTestUser(overrides = {}) {
  return {
    id: 'test-user-id',
    email: 'test@example.com',
    name: 'Test User',
    ...overrides
  };
}

export function mockDatabase() {
  return {
    query: jest.fn(),
    transaction: jest.fn(),
    // ...
  };
}
```

## Environment-Specific Testing

See `ENVIRONMENTS.md` for full environment setup patterns.

### Unit Tests

Run against mocks, no external dependencies:

```typescript
// Mock the database
const mockDb = { findUser: jest.fn() };
const service = new UserService(mockDb);

// Test in isolation
mockDb.findUser.mockResolvedValue({ id: '1', name: 'Test' });
const user = await service.getUser('1');
expect(user.name).toBe('Test');
```

### Integration Tests

Run against real (local) services. See `ENVIRONMENTS.md` for:
- Spinning up isolated test environments
- Using `COMPOSE_PROJECT_NAME` for isolation
- Cleanup patterns

### CI Testing

Each CI run gets an isolated environment. See `ENVIRONMENTS.md` for GitHub Actions service configuration patterns.

## Coverage Guidelines

### What to Measure

- **Line coverage** - Which lines were executed
- **Branch coverage** - Which conditionals were tested
- **Function coverage** - Which functions were called

### Coverage Targets

| Code Type | Target |
|-----------|--------|
| Business logic | 80%+ |
| Utilities | 90%+ |
| API handlers | 70%+ |
| Generated code | 0% (generator is tested) |

### Branch Coverage Checklist

TDD naturally covers happy paths and key error cases but consistently misses secondary branches. When writing tests, check for these patterns in your code:

| Pattern | What TDD covers | What it misses |
|---------|----------------|----------------|
| `catch (e) { e instanceof Error ? e : new Error(String(e)) }` | Throwing an Error | Throwing a string/number/object |
| `value ?? defaultValue` | When value is present | When value is null/undefined |
| `if (array.length === 0) return` | Non-empty array | Empty array early return |
| `input.field !== undefined` in update functions | Setting the field | Not setting the field (skip branch) |
| `result.success ? result.data : fallback` | Success case | Failure case |
| `typeof x === 'function' && x()` | When x is a function | When x is not a function |

Use this checklist during the step-completion coverage gate (see "Step-Completion Coverage Gate" above). If coverage is below threshold, these patterns are the most likely gaps.

### Coverage Anti-Patterns

**Don't:**
- Chase 100% coverage at the expense of test quality
- Write tests just to increase coverage numbers
- Exclude files to game metrics

**Do:**
- Focus coverage on critical paths
- Review uncovered code for test gaps
- Use coverage to find blind spots, not as a target

## Relationship to Other Docs

| Document | Connection |
|----------|------------|
| `APPROACH.md` | Tests are core to the verification mindset |
| `CONTRIBUTING.md` | Tests must pass before completing changes |
| `ENVIRONMENTS.md` | Testing environments are isolated per branch |
| `patterns/*.md` | Some patterns have specific testing approaches |

## When to Write an ADR

Testing-related ADRs are appropriate for:

- Choosing a testing framework
- Significant changes to test strategy
- Adding new test types (e.g., contract tests, load tests)
- Changing coverage requirements

Not needed for:

- Adding tests to existing code
- Fixing broken tests
- Routine test maintenance
