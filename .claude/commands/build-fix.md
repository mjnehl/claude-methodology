# Build and Fix Command

Incrementally fix TypeScript and build errors with minimal changes.

## Instructions

1. Run build: `npm run build` or equivalent

2. Parse error output:
   - Group by file
   - Sort by severity

3. For each error:
   - Show error context (5 lines before/after)
   - Explain the issue
   - Propose minimal fix
   - Apply fix
   - Re-run build
   - Verify error resolved

4. Stop if:
   - Fix introduces new errors
   - Same error persists after 3 attempts
   - User requests pause

5. Show summary:
   - Errors fixed
   - Errors remaining
   - New errors introduced

## Related Agent

For detailed build error resolution, invoke the `build-error-resolver` agent.

## Key Principles

- **Minimal diffs** - Fix only what's broken
- **No refactoring** - Don't improve code style
- **No architecture changes** - Only fix errors
- **One at a time** - Fix one error, verify, repeat

Fix one error at a time for safety!
