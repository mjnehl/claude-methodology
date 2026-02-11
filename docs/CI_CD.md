# CI/CD Guide

Reusable CI/CD patterns for projects using this methodology. Validated on the to-do-system project (GitHub Actions, Dependabot, branch protection).

## Two-Tier Workflow Pattern

Split CI into two parallel jobs:

```
Push/PR ──► check (fast)     ──► ✅ Required for merge
       └──► e2e   (PRs only) ──► ✅ Required for merge (if applicable)
```

| Job | Runs On | Contains | Why |
|-----|---------|----------|-----|
| **check** | Every push + PR | Lint, typecheck, unit tests, coverage upload | Fast feedback on every change |
| **e2e** | PRs only | Playwright browser tests, report upload on failure | Slow but validates user journeys before merge |

**Why two jobs, not one?** Pushes to feature branches get fast feedback (~1 min). E2E only runs when merging matters (PR). Both jobs run in parallel on PRs — neither blocks the other.

**Projects without E2E** use a single `check` job. See `TESTING.md` for E2E opt-out guidance.

## GitHub Actions Template

### Complete `ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  check:
    name: Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'

      - run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npx tsc --noEmit

      - name: Unit tests
        run: npm test -- --coverage

      - name: Upload coverage
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
          retention-days: 7

  e2e:
    name: E2E Tests
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'

      - run: npm ci

      # Cache Playwright browsers, but always install system deps
      # (system deps change with OS updates — caching them causes failures)
      - name: Cache Playwright browsers
        uses: actions/cache@v4
        with:
          path: ~/.cache/ms-playwright
          key: playwright-${{ hashFiles('package-lock.json') }}

      - name: Install Playwright
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npx playwright test

      - name: Upload Playwright report
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

### Key Decisions

| Decision | Rationale |
|----------|-----------|
| `npm ci` not `npm install` | Deterministic installs from lockfile; fails if lockfile is out of sync |
| `.nvmrc` for Node version | Single source of truth; works locally (nvm) and in CI (setup-node) |
| E2E on PRs only | Too slow for every push; PRs are the integration gate |
| Coverage uploaded `always()` | Available even when tests fail — helps diagnose what's untested |
| Playwright report on `failure()` only | Only useful for debugging; saves artifact storage |
| Cache browsers, always install system deps | Browser binaries are large and stable; system deps are small and OS-dependent |

### Playwright CI Configuration

In `playwright.config.ts`, detect CI and adjust:

```typescript
const isCI = !!process.env.CI  // GitHub Actions sets CI=true automatically

export default defineConfig({
  forbidOnly: isCI,        // Fail if test.only left in code
  retries: isCI ? 2 : 0,  // Retry flakes in CI, not locally
  workers: isCI ? 1 : undefined,  // Single worker in CI for stability
  webServer: {
    command: 'npm run dev',
    port: 3000,
    reuseExistingServer: !isCI,  // Fresh server in CI, reuse locally
  },
})
```

For test authoring patterns (Page Object Model, selectors, flaky test quarantine), see `TESTING.md` and the **e2e-runner** agent.

## Branch Protection

Set up via GitHub CLI after CI is green:

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field "required_status_checks[strict]=true" \
  --field "required_status_checks[contexts][]=check" \
  --field "enforce_admins=false" \
  --field "required_pull_request_reviews=null" \
  --field "restrictions=null"
```

| Setting | Value | Why |
|---------|-------|-----|
| `strict: true` | Branch must be up-to-date before merge | Prevents "works separately but breaks together" |
| Required check: `check` | The fast job gates merges | E2E is also required if the project has it |
| `enforce_admins: false` | Admins can bypass in emergencies | Solo dev needs escape hatch; teams may want `true` |

Add `e2e` to required checks for projects with E2E tests.

## Dependabot Configuration

### `dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      framework:
        patterns: ["react", "react-dom", "react-native", "@types/react*"]
      runtime:
        patterns: ["expo", "expo-*", "@expo/*"]
      testing:
        patterns: ["jest", "jest-*", "@testing-library/*", "playwright", "@playwright/*"]
      linting:
        patterns: ["eslint", "eslint-*", "@typescript-eslint/*", "prettier"]
    ignore:
      # Add breaking majors here as you discover them — see Lessons Learned
      - dependency-name: "example-package"
        update-types: ["version-update:semver-major"]

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Grouping Strategy

Groups reduce PR noise by bundling related dependencies:

| Group | Contents | Rationale |
|-------|----------|-----------|
| framework | React, React DOM, types | Must stay in sync |
| runtime | Expo, Expo modules | Tightly coupled versions |
| testing | Jest, Testing Library, Playwright | Test infra changes together |
| linting | ESLint, Prettier, TS-ESLint | Lint config changes together |

**Trade-off:** If one package in a group has a breaking update, the whole group PR fails. When this happens, add an ignore rule for the breaking package and let the rest of the group update.

## Dependabot Lessons Learned

Hard-won patterns from real triage:

### First Run Opens 10-15 PRs at Once

Triage order:
1. **GitHub Actions bumps** — safest, merge first (e.g., `actions/checkout` v3→v4)
2. **Grouped patches/minors** — usually safe, review CI results
3. **Close peer dependency conflicts** — Dependabot can't resolve these; close and add ignore rules
4. **Investigate major bumps individually** — check changelogs before merging

### 0.x Packages Need Minor Bumps Blocked Too

Semver treats 0.x as unstable — breaking changes come in minor bumps:

```yaml
ignore:
  - dependency-name: "some-0x-package"
    update-types: ["version-update:semver-major", "version-update:semver-minor"]
```

### Framework-Specific Preset Breakage

Jest major bumps often break framework-specific presets (e.g., `jest-expo` doesn't support Jest 30 yet). Add ignore rules preemptively for the framework test runner:

```yaml
ignore:
  - dependency-name: "jest"
    update-types: ["version-update:semver-major"]
```

### Dependabot Reopens Closed PRs

Closing a Dependabot PR is temporary — it reopens when Dependabot rebases. **Ignore rules are the only permanent fix.** When you close a Dependabot PR, always add the corresponding ignore rule to `dependabot.yml` in the same session.

### Grouped Package Failures

When one package in a group breaks CI:
1. Check which package caused the failure
2. Add an ignore rule for that package's major version
3. Close the group PR — Dependabot will reopen with the remaining packages

## Verification Integration

CI/CD integrates with the methodology verification loop:

| Verification Level | CI Role |
|-------------------|---------|
| `/verify quick` | Not in CI — local only |
| `/verify pre-commit` | Not in CI — local only |
| `/verify full` | Maps to the `check` job |
| `/verify pre-pr` | Maps to `check` + `e2e` jobs |

Branch protection enforces that `check` (and optionally `e2e`) passes before merge. This makes CI the automated enforcement of `/verify pre-pr`.

## Relationship to Other Docs

| Document | Connection |
|----------|------------|
| `TESTING.md` | Test strategy and E2E authoring patterns; CI runs what TESTING.md defines |
| `ENVIRONMENTS.md` | CI environment setup; GitHub Actions services for integration tests |
| `BOOTSTRAP.md` | New project setup includes CI workflow creation |
| `CONTRIBUTING.md` | CI enforces verification requirements from the change process |
