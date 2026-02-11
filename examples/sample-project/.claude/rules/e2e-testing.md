# E2E Testing Rules

## Methodology Integration

Implements dual-loop testing from `.claude/docs/TESTING.md`. E2E is the outer loop that validates user journeys; TDD is the inner loop that validates components.

## E2E Is On by Default

Every project with a UI should have E2E tests. Projects where E2E doesn't apply must explicitly opt out in `CLAUDE.md`:

```markdown
## Testing
E2E: not applicable — [reason, e.g., "CLI-only project"]
```

If `CLAUDE.md` doesn't opt out and the project has a UI, treat E2E as required.

## When to Write E2E Tests

- **After completing a user story that touches a critical journey**
- **When a bug is found through manual testing** (reproduce with E2E first)
- **Before major releases or phase milestones** (review coverage)

Do NOT defer E2E to "later" or "end of phase." Write them when the journey is complete.

## Dual-Loop Rule (CRITICAL)

When an E2E test fails, **never fix it directly without strengthening unit tests.** Always ask: "What unit test should have caught this?" then follow the TDD loop. See `.claude/docs/TESTING.md` § "E2E: The Outer Loop" for the full workflow.

## What to Test

Focus on **critical user journeys** — user-facing flows from acceptance criteria:

- Authentication flows (login, logout, registration)
- Core CRUD operations end-to-end
- Multi-step workflows (checkout, onboarding, wizards)
- Data integrity across operations (create → modify → verify persisted)
- Cross-cutting concerns (sync, permissions, notifications)

## What NOT to Test with E2E

- Individual component behavior (use unit tests)
- API contract validation (use integration tests)
- Edge cases in business logic (use unit tests)
- Styling and layout (use visual regression tools if needed)

## Patterns

### Page Object Model

Always use Page Object Model for maintainability. See the `e2e-runner` agent for a full example.

### Selectors

Prefer `data-testid` attributes. Avoid selectors coupled to implementation:

```typescript
// GOOD
page.locator('[data-testid="submit-button"]')

// BAD
page.locator('.btn-primary.mt-4')
page.locator('div > form > button:nth-child(2)')
```

### Waiting

Wait for specific conditions, never arbitrary timeouts:

```typescript
// GOOD
await page.waitForResponse(r => r.url().includes('/api/data'))
await expect(page.locator('[data-testid="result"]')).toBeVisible()

// BAD
await page.waitForTimeout(3000)
```

## Flaky Tests

Quarantine flaky tests immediately. Do not let them erode trust in the suite:

```typescript
test('flaky: complex interaction', async ({ page }) => {
  test.fixme(true, 'Flaky — tracking in Issue #123')
})
```

Investigate and fix quarantined tests within the same phase.

## Verification Integration

- `/verify quick` and `/verify pre-commit` — skip E2E (too slow)
- `/verify full` and `/verify pre-pr` — include E2E
- E2E failures block PR readiness
