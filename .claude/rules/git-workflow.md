# Git Workflow

## Methodology Integration

Supports verification and ADR requirements from `.claude/docs/CONTRIBUTING.md`.

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Examples:
- `feat: add user authentication flow`
- `fix: resolve race condition in data fetching`
- `docs: update API documentation`

## Pull Request Workflow

When creating PRs:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with verification steps
5. Push with `-u` flag if new branch

## Feature Implementation Workflow

1. **Check ADR Requirement**
   - New component or breaking change? → Write ADR first
   - See `.claude/docs/CONTRIBUTING.md` for criteria

2. **Plan First**
   - Use **architect** agent for complex features
   - Identify dependencies and risks
   - Break down into small, verifiable steps

3. **TDD Approach**
   - Use **tdd-guide** agent
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

4. **Code Review**
   - Use **code-reviewer** agent after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

5. **Verify Before Commit**
   - Run `/verify` command
   - Ensure all checks pass
   - Commit with descriptive message

## Branch Strategy

- `main` - production-ready code
- `feature/*` - new features
- `fix/*` - bug fixes
- `refactor/*` - refactoring work

## Before Pushing

Always verify:
1. All tests pass
2. Build succeeds
3. No linting errors
4. Security checks pass
5. ADR committed (if required)
