# E2E Command

Generate and run end-to-end tests with Playwright.

## Methodology Integration

E2E tests are part of the test pyramid in `.claude/docs/TESTING.md`:
- Few E2E tests for critical user journeys
- Run slower than unit/integration tests

## What This Command Does

1. **Generate Test Journeys** - Create Playwright tests for user flows
2. **Run E2E Tests** - Execute tests across browsers
3. **Capture Artifacts** - Screenshots, videos, traces on failures
4. **Identify Flaky Tests** - Quarantine unstable tests

## When to Use

Use `/e2e` when:
- **After completing a user story that touches a critical journey** (primary trigger)
- **When a bug is found through manual testing** (reproduce with E2E first)
- Verifying multi-step flows work end-to-end
- Before major releases or phase milestones
- Preparing for production deployment

Do NOT defer E2E to "later." Write them when the journey is complete.

## How It Works

The e2e-runner agent will:

1. Analyze user flow and identify test scenarios
2. Generate Playwright test using Page Object Model pattern
3. Run tests across multiple browsers
4. Capture failures with screenshots, videos, and traces
5. Generate report with results and artifacts

## Test Artifacts

**On All Tests:**
- HTML Report with timeline and results
- JUnit XML for CI integration

**On Failure Only:**
- Screenshot of the failing state
- Video recording of the test
- Trace file for debugging

## Quick Commands

```bash
# Run all E2E tests
npx playwright test

# Run specific test file
npx playwright test tests/e2e/auth.spec.ts

# Run in headed mode (see browser)
npx playwright test --headed

# Debug test
npx playwright test --debug

# View report
npx playwright show-report
```

## Best Practices

- Use Page Object Model for maintainability
- Use data-testid attributes for selectors
- Wait for API responses, not arbitrary timeouts
- Test critical user journeys end-to-end

## Dual-Loop Integration

If an E2E test fails, feed it into the TDD loop before fixing — never fix E2E directly. See `.claude/docs/TESTING.md` § "E2E: The Outer Loop" for the full workflow.

## Related Agent

Invokes the `e2e-runner` agent for detailed test generation.
